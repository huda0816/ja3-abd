DefineClass.ABD_AI = {
	__parents = { "ABD" },
}

function ABD_AI:GetArchetype(unit, proto_context)
	local archetype
	local func = empty_func

	if unit.current_archetype == "StrategicRetreat" then
		return unit.current_archetype
	end

	local emplacement = g_Combat and g_Combat:GetEmplacementAssignment(unit)
	if unit.retreating then
		archetype = "Deserter"
	elseif unit:HasStatusEffect("Panicked") then
		archetype = "Panicked"
	elseif unit:HasStatusEffect("Berserk") then
		archetype = "Berserk"
	elseif emplacement then
		assert(unit.CanManEmplacements)
		archetype = "EmplacementGunner"
		proto_context.target_interactable = emplacement
	elseif unit.command == "Reposition" and unit.RepositionArchetype then
		archetype = unit.RepositionArchetype
	end

	-- check for scout archetype first
	local can_scout = not archetype
	can_scout = can_scout and (not g_Encounter or g_Encounter:CanScout())
	can_scout = can_scout and unit.script_archetype ~= "GuardArea"
	if can_scout then
		local enemies = unit:GetVisibleEnemies()
		if #enemies == 0 then
			unit.last_known_enemy_pos = unit.last_known_enemy_pos or AIPickScoutLocation(unit)
			if unit.last_known_enemy_pos then
				archetype = "Scout_LastLocation"
			end
		end
	end

	if not archetype then
		for _, descr in pairs(g_Pindown) do
			if descr.target == unit then
				if unit:Random(100) < unit.PinnedDownChance then
					archetype = "PinnedDown"
				end
				break
			end
		end
	end
	local template = UnitDataDefs[unit.unitdatadef_id]
	func = template and template.PickCustomArchetype or unit.PickCustomArchetype


	-- TODO archetype = "Illuminator"

	if not self:IsPlayerControlled(unit) and not archetype or archetype == "Scout_LastLocation" then
		local cacheTable = self:GetTargetsAndMore(unit)

		if (self:CheckStrategicRetreat(unit)) then
			return "StrategicRetreat"
		end

		if self:CheckTacticalRetreat(unit, cacheTable) then
			archetype = "TacticalRetreat"
		end

		if not archetype and g_Combat and g_Combat.current_turn == 1 and self:CheckSeekCover(unit, cacheTable, true) then
			archetype = "SeekCover"
		end

		-- archetype = "Scout_LastLocation" == archetype and "SeekCover" or archetype

		if not archetype then
			if unit.archetype ~= "Brute" and unit.archetype ~= "Medic" then
				if self:CheckSpecialTurret(unit, cacheTable) then
					if unit.AIKeywords and table.find(unit.AIKeywords, "Sniper") then
						archetype = "SpecialTurret_Sniper"
					else
						archetype = "SpecialTurret"
					end
				end

				if self:CheckSeekCover(unit, cacheTable) then
					archetype = "SeekCover"
				end
			end
		end
	end

	return archetype or func(unit, proto_context) or unit.archetype or "Assault"
end

function ABD_AI:GetTargetsAndMore(unit, pos)
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
	local closeAllies = {}
	local distances = {}

	local allAllies = unit.team.units

	for _, ally in ipairs(allAllies) do
		if ally ~= unit and not ally:IsDead() then
			local dist = unit:GetDist2D(ally)

			if dist < 20 * const.SlabSizeX then
				table.insert(closeAllies, ally)
			end
		end
	end

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
	cacheTable.closeAllies = closeAllies
	cacheTable.numOfAllAllies = #allAllies - 1
	cacheTable.powerBalance = #visibleEnemies - #closeAllies

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

	cacheTable.covers, cacheTable.hasGoodCover = self:GetCoversToEnemies(unit, visibleEnemies)

	return cacheTable
end

function ABD_AI:GetCoversToEnemies(unit, enemies)
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

function ABD_AI:CheckStrategicRetreat(unit)
	local sectorId = gv_CurrentSectorId
	local sector = gv_Sectors[sectorId]

	if not sector then
		return false
	end

	if sector.Side ~= "enemy1" then
		return false
	end

	if sector.GuardPost then
		return false
	end

	if sector.Mine then
		return false
	end

	if sector.CustomConflictDescriptor then
		return false
	end

	if g_SectorEncounters and g_SectorEncounters[sectorId] then
		return false
	end

	local excludedAffiliations = { "Thugs", "SuperSoldiers" }

	if self:ArrayContains(excludedAffiliations, unit.Affiliation) then
		return false
	end

	local excludedSectors = { "L12", "L18", "L17", "G8", "A2", "A8", "H12", "L9" }

	if sectorId and self:ArrayContains(excludedSectors, sectorId) then
		return false
	end

	if sectorId and IsSectorUnderground(sectorId) then
		return false
	end

	if unit.species ~= "Human" or unit.villain or unit.ImportantNPC or unit.infected or unit.group == "NPC" then
		return false
	end

	local enemies = table.ifilter(GetAllAlliedUnits(unit), function(k, v)
		return not v:IsDead()
	end)

	local allies = table.ifilter(GetAllEnemyUnits(unit), function(k, v)
		return not v:IsDead()
	end)

	if unit:HasStatusEffect("Heroic") or unit:HasStatusEffect("Panicked") or unit:HasStatusEffect("Berserk") or unit:HasStatusEffect("ZombiePerk") then
		return false
	end
	
	if #enemies > 2 or #enemies > (#allies + 1) then
		return false
	end
	-- make a simple roll with an 80% chance to retreat
	local roll = InteractionRand(100, 'strategicretreat')
	if roll > 80 then
		return false
	end

	return true
end

function ABD_AI:CheckTacticalRetreat(unit, cacheTable)
	-- if cacheTable.hasGoodCover and cacheTable.anyEnemyGoodAttack then
	-- 	return false
	-- end

	local numOfCloseAllies = cacheTable.closeAllies and #cacheTable.closeAllies or 0
	local numOfVisibleEnemies = cacheTable.enemies and #cacheTable.enemies or 0

	if numOfCloseAllies < 1 then
		-- adding some randomness so not every unit will retreat in the same situation the more enemies the higher the chance
		local retreatChance = 40 + (cacheTable.hasGoodCover and cacheTable.anyEnemyGoodAttack and -20 or 0) +
			(numOfVisibleEnemies - (numOfCloseAllies + 1)) * 15
		local roll = InteractionRand(100, 'tacticalretreat')

		if roll < retreatChance then
			return true
		end
	end

	return false
end

function ABD_AI:CheckSeekCover(unit, cacheTable, firstTurn)
	local powerBalance = cacheTable.powerBalance

	if cacheTable.anyEnemyGoodAttack and powerBalance < 0 then
		return true
	end

	if not cacheTable.anyEnemyGoodAttack and not firstTurn then
		return false
	end

	if cacheTable.anyGoodAttack then
		return false
	end

	local closestDistToUncoveredEnemy = nil
	local closestDistToAnyEnemy = nil

	for i, dist in ipairs(cacheTable.distances) do
		if (not closestDistToUncoveredEnemy or dist < closestDistToUncoveredEnemy) and cacheTable.covers[i] < 50 then
			closestDistToUncoveredEnemy = dist
		end
		if not closestDistToAnyEnemy or dist < closestDistToAnyEnemy then
			closestDistToAnyEnemy = dist
		end
	end

	if closestDistToAnyEnemy < 6 * const.SlabSizeX then
		return false
	end

	if unit:IsThreatened(nil, "pindown") and not cacheTable.hasGoodCover and closestDistToAnyEnemy > 4 * const.SlabSizeX then
		return true
	end

	if cacheTable.anyEnemyGoodAttack and not cacheTable.hasGoodCover and not cacheTable.anyGoodAttack then
		return true
	end

	local activeWeaponRange = self:GetWeaponRange(unit)

	if closestDistToUncoveredEnemy and closestDistToUncoveredEnemy < activeWeaponRange then
		return true
	end

	return false
end

function ABD_AI:CheckSpecialTurret(unit, cacheTable)
	-- if unit.archetype == "Brute" or unit.archetype == "Medic" then
	-- 	return false
	-- end

	if not cacheTable.anyGoodAttack then
		return false
	end

	if not cacheTable.hasGoodCover then
		return false
	end

	-- if the balance of power is heavy with the player move
	-- if cacheTable.anyEnemyGoodAttack then
	-- 	return false
	-- end

	if unit:IsUnderBombard() or unit:IsUnderTimedTrap() or unit:IsThreatened(nil, "pindown") or unit:HasStatusEffect("Burning") or unit:HasStatusEffect("Choking") then
		return false
	end

	return true
end
