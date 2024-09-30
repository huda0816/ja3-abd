g_HUDA_PosCache = {}
g_HUDA_DistCache = {}

function OnMsg.NewCombatTurn()
	g_HUDA_PosCache = {}
	g_HUDA_DistCache = {}
end

function HUDA_GetCloseUnits(unit, range)
	local enemies = {}
	local allies = {}
	local range = range or 20 --todo different daylight and weather conditions
	local pos

	if g_HUDA_PosCache[unit.session_id] then
		pos = g_HUDA_PosCache[unit]
	else
		pos = unit:GetPos()
		g_HUDA_PosCache[unit.session_id] = pos
	end

	for _, u in ipairs(g_Units) do
		local dist

		g_HUDA_DistCache[u.session_id] = g_HUDA_DistCache[u.session_id] or {}

		g_HUDA_DistCache[unit.session_id] = g_HUDA_DistCache[unit.session_id] or {}

		if g_HUDA_DistCache[u.session_id][unit.session_id] then
			dist = g_HUDA_DistCache[u.session_id][unit.session_id]
		elseif g_HUDA_DistCache[unit.session_id][u.session_id] then
			dist = g_HUDA_DistCache[unit.session_id][u.session_id]
		else
			dist = u:GetDist2D(pos)
			g_HUDA_DistCache[u.session_id][unit.session_id] = dist
			g_HUDA_DistCache[unit.session_id][u.session_id] = dist
		end

		if IsValid(u) and u ~= unit and dist < range * const.SlabSizeX and not u:IsDead() and not u:HasStatusEffect("Unconscious") and not u:HasStatusEffect("Downed") then
			if unit:IsOnEnemySide(u) then
				table.insert(enemies, u)
			elseif unit:IsOnAllySide(u) then
				table.insert(allies, u)
			end
		end
	end

	return enemies, allies
end

function GetTargetsAndMore(unit, pos)
	local defaultAction = unit:GetDefaultAttackAction("ranged") or unit:GetDefaultAttackAction()

	if defaultAction.group == "FiringModeMetaAction" then
		defaultAction = GetUnitDefaultFiringModeActionFromMetaAction(unit, defaultAction)
	end

	local unitWeapon = defaultAction:GetAttackWeapons(unit)
	if not IsKindOfClasses(unitWeapon, "Firearm", "MeleeWeapon") then return end

	local max_range = defaultAction:GetMaxAimRange(unit, unitWeapon)
	max_range = max_range or unitWeapon.WeaponRange
	max_range = max_range and (max_range * const.SlabSizeX)

	local lof_args = {
		obj = unit,
		action_id = defaultAction.id,
		weapon = unitWeapon,
		range = max_range,
		clamp_to_target = true,
		step_pos = pos or unit:GetOccupiedPos(),
	}

	local cacheTable = {}
	cacheTable.for_unit = unit.session_id
	if not cacheTable.goodAttack then cacheTable.goodAttack = {} end
	table.clear(cacheTable.goodAttack)
	local goodAttackCache = cacheTable.goodAttack
	local anyGoodAttack = false
	local anyEnemyGoodAttack = false
	local distances = {}

	local visibleEnemies = defaultAction:GetTargets({ unit })
	if defaultAction.ActionType == "Ranged Attack" then
		local lof_data = visibleEnemies and #visibleEnemies > 0 and GetLoFData(unit, visibleEnemies, lof_args)
		for i, e in ipairs(visibleEnemies) do
			local lof = lof_data[i]
			lof_data[e] = lof

			local isGoodAttack = false

			local dist = unit:GetDist2D(e)

			table.insert(distances, dist)

			if dist < max_range then
				for i, bodyPartLof in ipairs(lof and lof.lof) do
					local bodyPartGood = not bodyPartLof.stuck and not bodyPartLof.outside_attack_area and
						bodyPartLof.target_los
					if bodyPartGood then
						isGoodAttack = true
						break
					end
				end
			end

			anyGoodAttack = anyGoodAttack or isGoodAttack
			anyEnemyGoodAttack = anyEnemyGoodAttack or (isGoodAttack and unit:IsOnEnemySide(e))
			goodAttackCache[e] = isGoodAttack
		end
		cacheTable.lof_cache = lof_data
		cacheTable.lof_cache_src = {
			attackerId = unit.session_id,
			actionId = defaultAction.id,
			fromPos = pos,
			weapon =
				unitWeapon
		}
	elseif defaultAction.ActionType == "Melee Attack" then
		local targets = GetMeleeAttackTargets(unit)
		if targets and #targets > 0 then
			anyGoodAttack = true
			for i, e in ipairs(targets) do
				if unit:IsOnEnemySide(e) then
					goodAttackCache[e] = true
					anyEnemyGoodAttack = true
				end
			end
		end
	else -- fallback
		cacheTable.lof_cache = false
		cacheTable.lof_cache_src = false
	end
	cacheTable.anyGoodAttack = anyGoodAttack
	cacheTable.anyEnemyGoodAttack = anyEnemyGoodAttack
	cacheTable.enemies = visibleEnemies
	cacheTable.distances = distances

	if not cacheTable.goodAttackObject then cacheTable.goodAttackObject = {} end
	table.clear(cacheTable.goodAttackObject)
	local goodAttackObject = cacheTable.goodAttackObject

	if defaultAction.ActionType == "Ranged Attack" then
		--assert(unit.team.side == "player1") -- Enemy selected ?! (Happens in tests)
		local visibleTraps = g_AttackableVisibility[unit]
		if visibleTraps and #visibleTraps > 0 then
			lof_args.target_spot_group = ""
			local lof_data = GetLoFData(unit, visibleTraps, lof_args)
			for i, lof in ipairs(lof_data) do
				local isGoodAttack = lof and not lof.stuck and not lof.outside_attack_area and lof.los ~= 0
				local obj = visibleTraps[i]
				goodAttackObject[obj] = isGoodAttack
			end
		end
	end

	cacheTable.covers, cacheTable.hasGoodCover = GetCoversToEnemies(unit, visibleEnemies)

	return cacheTable
end

function GetCoversToEnemies(unit, enemies)
	if not enemies or #enemies == 0 then
		return {}, false
	end

	local covers = {}

	local coverScore = 0

	for _, enemy in ipairs(enemies) do
		local cover, any, coverage = unit:GetCoverPercentage(enemy:GetPos())
		if coverage then
			coverScore = coverScore + coverage

			table.insert(covers, coverage)
		end
	end

	local avgCover = DivRound(coverScore, #enemies)

	return covers, avgCover > 60
end