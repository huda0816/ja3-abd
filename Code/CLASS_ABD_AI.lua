g_HUDA_PosCache = {}
g_HUDA_DistCache = {}

function OnMsg.NewCombatTurn()
	g_HUDA_PosCache = {}
	g_HUDA_DistCache = {}
end

function OnMsg.CombatEnd()
	-- check how many enemies are left
	HUDA_RetreatEnemies()
end

AppendClass.SatelliteSector = {
	properties = {
		{
			id = "ABD_retreating_units",
			name = "Retreating Units",
			editor = "table",
			default = {},
		},
		{
			id = "ABD_alerted",
			name = "Alerted",
			editor = "bool",
			default = false,
		}
	}
}

function HUDA_RetreatEnemies()
	local enemies = 0
	local alliesAndPlayers = 0

	for _, unit in ipairs(g_Units) do
		if not ABD:IsPlayerControlled(unit) and not unit.retreating and not unit:IsDead() then
			enemies = enemies + 1
		elseif ABD:IsPlayerControlled(unit) or unit:IsDead() then
			alliesAndPlayers = alliesAndPlayers + 1
		end
	end

	-- if enemies < 3 and enemies * 2 < alliesAndPlayers then
	local direction, sectorId = HUDA_GetBestRetreatSectorBySide("enemy1")

	local exitZone = HUDA_GetBestExitZoneInteractable(direction)

	SnapCameraToObj(exitZone)

	for _, unit in ipairs(g_Units) do
		if not ABD:IsPlayerControlled(unit) and not unit.retreating and not unit:IsDead() then
			unit:SetCommandParamValue("AdvanceTo", "move_anim", "Run")
			unit:SetCommand("AdvanceTo", exitZone:GetHandle())
		end
	end
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

	print("Close Allies", #closeAllies)

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

function HUDA_CheckStrategicRetreat(unit)
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

	if HUDA_ArrayContains(excludedAffiliations, unit.Affiliation) then
		return false
	end

	local excludedSectors = { "L12", "L18", "L17", "G8", "A2", "A8", "H12", "L9" }

	if sectorId and HUDA_ArrayContains(excludedSectors, sectorId) then
		return false
	end

	if sectorId and IsSectorUnderground(sectorId) then
		return false
	end

	if unit.species ~= "Human" or unit.villain or unit.ImportantNPC or unit.infected or unit.group == "NPC" then
		return false
	end

	local enemies = table.ifilter(g_Units, function(k, v)
		return unit.CurrentSide == "enemy1"
	end)

	local allies = table.ifilter(g_Units, function(k, v)
		return unit.CurrentSide == "player1"
	end)

	if unit:HasStatusEffect("Heroic") or unit:HasStatusEffect("Panicked") or unit:HasStatusEffect("Berserk") or unit:HasStatusEffect("ZombiePerk") then
		return false
	end

	if #enemies > 2 or #enemies > #allies then
		return false
	end
	-- make a simple roll with an 80% chance to retreat
	local roll = InteractionRand(100, 'strategicretreat')
	if roll > 80 then
		return false
	end

	return true
end

function HUDA_CheckTacticalRetreat(unit, cacheTable)
	-- if cacheTable.hasGoodCover and cacheTable.anyEnemyGoodAttack then
	-- 	return false
	-- end

	local numOfCloseAllies = cacheTable.closeAllies and #cacheTable.closeAllies or 0
	local numOfVisibleEnemies = cacheTable.enemies and #cacheTable.enemies or 0

	print("Close Allies", numOfCloseAllies, "Visible Enemies", numOfVisibleEnemies)

	if numOfCloseAllies < 1 then
		-- adding some randomness so not every unit will retreat in the same situation the more enemies the higher the chance
		local retreatChance = 40 + (cacheTable.hasGoodCover and cacheTable.anyEnemyGoodAttack and -20 or 0) +
			(numOfVisibleEnemies - (numOfCloseAllies + 1)) * 15
		local roll = InteractionRand(100, 'tacticalretreat')

		print("Tactical Retreat Roll", roll, "<", retreatChance)

		if roll < retreatChance then
			return true
		end
	end

	return false
end

function HUDA_CheckSeekCover(unit, cacheTable, firstTurn)
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

	local activeWeaponRange = HUDA_GetWeaponRange(unit)

	if closestDistToUncoveredEnemy and closestDistToUncoveredEnemy < activeWeaponRange then
		return true
	end

	return false
end

function HUDA_CheckSpecialTurret(unit, cacheTable)
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

	print(unit.session_id, "SpecialTurret")

	return true
end

function HUDA_GetBestRetreatSectorBySide(side)
	local bestSector
	local bestSectorId
	local sectorScores = {}
	local sectorId = gv_CurrentSectorId

	local currentSector = gv_Sectors[gv_CurrentSectorId]

	local cardinalSectors = HUDA_GetCardinalSectors(sectorId, side)

	local bestSector
	local bestSectorId
	local sectorScores = {}


	for direction, cardinal_sector_id in pairs(cardinalSectors) do
		local sector = gv_Sectors[cardinal_sector_id]

		local score = 0

		if sector.Side == side then
			score = score + 100
		end

		if sector.City == currentSector.City then
			score = score + 50
		end

		if not sector.ally_and_militia_squads or #sector.ally_and_militia_squads == 0 then
			score = score + 25
		end

		sectorScores[direction] = score
	end

	for direction, score in pairs(sectorScores) do
		if not bestSector or score > sectorScores[bestSector] then
			bestSector = direction
			bestSectorId = cardinalSectors[direction]
		end
	end

	return bestSector, bestSectorId
end

-- this is a retreat function for AI units
-- best sectors are:
-- controlled by same side
-- same city
-- or empty sectors if no controlled sectors are available
function HUDA_GetBestRetreatSector(unit)
	local sector = ABD:GetUnitSector(unit)
	if not sector then return nil end
	local sector_id = sector.Id
	local side = unit.team.side

	return HUDA_GetBestRetreatSectorBySide(side)
end

function HUDA_GetCardinalSectors(sector_id, side)
	local directions = { "down", "up", "right", "left" }
	local sectors = {}
	local i = 1
	ForEachSectorCardinal(sector_id, function(sector_id)
		sectors[directions[i]] = sector_id
		i = i + 1
	end)
	return sectors
end

function HUDA_GetBestExitZoneInteractable(direction)
	local bestExitZone = false
	MapForEach("map", "ExitZoneInteractable", function(o)
		if not bestExitZone then
			bestExitZone = o
			return
		end
		local ox, oy = o:GetPosXYZ()

		local bx, by = bestExitZone:GetPosXYZ()

		if direction == "down" then
			if oy < by then
				bestExitZone = o
			end
		elseif direction == "up" then
			if oy > by then
				bestExitZone = o
			end
		elseif direction == "left" then
			if ox < bx then
				bestExitZone = o
			end
		elseif direction == "right" then
			if ox > bx then
				bestExitZone = o
			end
		end
	end)

	return bestExitZone
end

function OnMsg.CombatStart()
	local combat = g_Combat

	if not combat then
		return
	end

	local direction, sectorId = HUDA_GetBestRetreatSectorBySide("enemy1")

	local exitZone = HUDA_GetBestExitZoneInteractable(direction)

	g_Combat.exitZone = exitZone
end

function OnMsg.TurnStart(team)
	local team = g_Teams and g_Teams[team]

	if not team or team.side ~= "enemy1" then
		return
	end

	local direction, sectorId = HUDA_GetBestRetreatSectorBySide("enemy1")

	local exitZone = HUDA_GetBestExitZoneInteractable(direction)

	for index, unit in ipairs(team.units) do
		if not unit.current_archetype or unit.current_archetype ~= "StrategicRetreat" or unit:IsDead() or unit.retreating then
			goto continue
		end

		local distance = unit:GetDist(exitZone)

		if distance < 15 * const.SlabSizeX then
			HUDA_Softdespawn(unit)
		end

		::continue::
	end
end

function HUDA_Softdespawn(unit)
	unit:AutoRemoveCombatEffects()
	unit:InterruptPreparedAttack()
	unit:RemoveEnemyPindown()

	--remove crosshair on despawned unit
	local dlg = GetInGameInterfaceModeDlg()
	local crosshair = dlg and dlg.crosshair
	if crosshair and crosshair.context.target == unit then
		dlg:RemoveCrosshair("Despawn")
		if g_Combat then
			if g_Combat:ShouldEndCombat() then
				g_Combat:EndCombatCheck(true)
			else
				SetInGameInterfaceMode("IModeCombatMovement")
			end
		else
			SetInGameInterfaceMode("IModeExploration", { suppress_camera_init = true })
		end
	end

	if not unit:IsAmbientUnit() then unit:SyncWithSession("map") end

	local sectorId = gv_CurrentSectorId

	print("Softdespawn unit", unit.session_id, "to sector", sectorId)

	local sector = gv_Sectors[sectorId]

	sector.ABD_retreating_units = sector.ABD_retreating_units or {}

	table.insert(sector.ABD_retreating_units, unit.session_id)

	--unit:RemoveAllStatusEffects()
	if SelectedObj == unit then
		SelectObj()
	end
	local cameraFollowTarget = cameraTac.GetFollowTarget()
	if cameraFollowTarget == unit then
		cameraTac.SetFollowTarget(false)
	end

	unit.current_archetype = nil

	DoneObject(unit)

	local squad = gv_Squads[unit.Squad]

	if squad then
		squad.Retreat = true
	end

	if g_Combat and not g_AIExecutionController then
		g_Combat:EndCombatCheck("force")
	end
end

function OnMsg.ConflictEnd(sector, bNoVoice, playerAttacking, playerWon, isAutoResolve, isRetreat, fromMap)
	if not playerWon then
		sector.ABD_retreating_units = {}
		return
	end

	local direction, sectorId = HUDA_GetBestRetreatSectorBySide("enemy1")
	local retreatingSquads = {}

	local enemySquads = sector.enemy_squads

	for i, squad in ipairs(enemySquads) do
		local notRetreatingUnits = table.ifilter(gv_UnitData, function(k, v)
			return v.Squad == squad.UniqueId and sector.ABD_retreating_units and
			not table.find(sector.ABD_retreating_units, v.session_id)
		end)

		print("non retreating", #notRetreatingUnits)

		if #notRetreatingUnits == 0 then
			table.insert(retreatingSquads, squad.UniqueId)
			RemoveSquadFromSectorList(squad, squad.CurrentSector)
		end
	end

	local retreatSector = gv_Sectors[sectorId]

	sector.ABD_retreating_units = {}

	if #retreatingSquads > 0 then
		HUDA_MoveSquads(retreatingSquads, retreatSector.City, "retreat", sector.Id, sectorId)
	end
end

function HUDA_MoveSquads(squadIds, city, type, src, dst)
	-- TODO GET_DESTINATION BASED ON TYPE

	for i, squadId in ipairs(squadIds) do
		local routes = DBRoutesCacheDynamic or DBRoutesCacheStatic
		if not routes then return end

		local weights = {}

		local route = GenerateRouteDijkstra(src, dst, false, empty_table, "enemy_guardpost", nil, "enemy1")
		if route then
			route.source = src
			route.dest = dst
			weights[#weights + 1] = { 100, route }
			routes = empty_table
		else
			return
		end

		-- Evaluate route weights.
		for i, route in ipairs(routes) do
			local srcSector = gv_Sectors[route.source]
			local dstSector = gv_Sectors[route.dest]
			if not srcSector.reveal_allowed or srcSector.Side ~= "enemy1" then goto continue end
			if not dstSector.reveal_allowed or dstSector.Side ~= "enemy1" then goto continue end
			if srcSector.no_ddb or dstSector.no_ddb then goto continue end

			-- Sector weights depend on total route length, to prevent only the
			-- long routes from getting picked.
			local weightPerSector = MulDivRound(1, 1000, #route)
			local weight = 0
			local playerSectorsAround = {}
			for i, sId in ipairs(route) do
				local prevSector = route[i - 1]
				local nextSector = route[i + 1]
				local sector = gv_Sectors[sId]

				-- Prefer routes which graze player sectors.
				-- if sector.Side ~= "player1" then
				-- 	weight = weight + weightPerSector
				-- 	ForEachSectorAround(sId, 1, function(sectorAroundId)
				-- 		if sId ~= sectorAroundId and sectorAroundId ~= prevSector and sectorAroundId ~= nextSector then
				-- 			local sectorAround = gv_Sectors[sectorAroundId]
				-- 			if sectorAround.Side == "player1" and not playerSectorsAround[sectorAroundId] then
				-- 				playerSectorsAround[sectorAroundId] = true
				-- 				playerSectorsAround[#playerSectorsAround + 1] = sectorAroundId
				-- 			end
				-- 		end
				-- 	end)
				-- else
				-- 	weight = weight - 100
				-- end

				if sector.Side == "player1" then
					weight = weight - 10000
				end
			end

			local playerSectors = #playerSectorsAround
			if playerSectors <= 2 then
				playerSectors = 0
			end

			weight = weight + weightPerSector * playerSectors * 100
			weight = weight - #route * 2 -- Prefer shorter routes
			weights[#weights + 1] = { weight, route, playerSectors }

			::continue::
		end
		if #weights == 0 then return end

		-- Remove bottom worst
		table.sort(weights, function(a, b) return a[1] > b[1] end)
		if #weights > 4 then
			local halfWeights = #weights / 2
			table.iclear(weights, halfWeights)
		end

		local randomRoute = GetWeightedRandom(weights, xxhash(Game.id, Game.CampaignTime, gv_NextSquadUniqueId))
		if not randomRoute then return end

		local squad = gv_Squads[squadId]
		randomRoute = table.copy(randomRoute)
		randomRoute = { randomRoute } -- Waypointify
		SetSatelliteSquadRoute(squad, randomRoute)
	end
end


function OnMsg.SquadFinishedTraveling(squad)
	if not squad.Retreating then
		return
	end

	squad.Retreating = false

	local current_sector = gv_Sectors[squad.CurrentSector]

	current_sector.ABD_alerted = true
end
