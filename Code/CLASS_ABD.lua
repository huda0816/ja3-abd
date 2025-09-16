MapVar("mv_ABD_BushCache", {})
MapVar("mv_ABD_Weather", "")

DefineClass.ABD = {
	debug = true,
}

function ABD:Init()
	self:AddFilters()
end

function ABD:AddFilters()
	for i, unit in ipairs(gv_UnitData) do
		unit:AddStatusEffect("ABD_Filters")
	end

	for i, unit in ipairs(g_Units) do
		unit:AddStatusEffect("ABD_Filters")
	end
end

function ABD:Print(...)
	if self.debug then
		print(...)
	end
end

function ABD:IsInBush(unit, vegClasses)
	local pos = unit:GetPos()

	if not pos then
		return false
	end

	local hashedPos = point_pack(pos)

	mv_ABD_BushCache = mv_ABD_BushCache or {}

	local cached = mv_ABD_BushCache[hashedPos]

	if cached ~= nil then
		if cached == false then
			return false
		else
			return true, cached[1], cached[2]
		end
	end

	local vegTypeHierachy = {
		Bush = 30,
		Low = 20,
		Grass = 10
	}

	vegClasses = vegClasses or {
		"TraverseVegetation",
		"Grass"
	}

	local allBushes = {}

	local entityData = EntityData

	for i, vegClass in ipairs(vegClasses) do
		local bushes = MapGet(pos, 1000, vegClass, function(obj, pos) return pos:InBox(obj) end, pos)

		if #bushes > 0 then
			for i, bush in ipairs(bushes) do
				local bushType = "Grass"

				if vegClass ~= "Grass" then
					local entity = entityData[bush.class]

					bushType = entity and entity.editor_subcategory or "Grass"
				end

				allBushes[bush.class] = bushType
			end
		end
	end

	if not next(allBushes) then
		mv_ABD_BushCache[hashedPos] = false
		return false
	end

	local highestBush = "Grass"

	for class, bushType in pairs(allBushes) do
		bushType = bushType == "Tree" and "Bush" or bushType

		if not highestBush or vegTypeHierachy[bushType] > vegTypeHierachy[highestBush] then
			highestBush = bushType
		end
	end

	mv_ABD_BushCache[hashedPos] = { highestBush, allBushes }

	return true, highestBush, allBushes
end

function ABD:GetSectorWeather()
	local sectorId = gv_CurrentSectorId

	mv_ABD_Weather = mv_ABD_Weather or ""

	if mv_ABD_Weather and mv_ABD_Weather ~= "" then
		return mv_ABD_Weather
	end

	local weather = GetCurrentSectorWeather(sectorId) or "ClearSky"

	mv_ABD_Weather = weather

	return weather
end

function ABD:IsPlayerControlled(unit)
	local unit = gv_UnitData[unit.session_id]
	if not unit then return false end
	local squad = gv_Squads and gv_Squads[unit.Squad]
	if not squad then return false end
	local side = squad.Side
	if side ~= "player1" and side ~= "player2" then
		return false
	end
	return true
end

function ABD:GetUnitSector(unit, id)
	local squad = gv_Squads[unit.Squad]
	if not squad then return nil end
	local sectorId = squad.CurrentSector
	return id and sectorId or sectorId and gv_Sectors[sectorId]
end

function ABD:IsMoving(unit)
	return unit.is_moving
end

function ABD:SetGameVar(key, value)
	gv_ABD = gv_ABD or {}

	local keys = self:GetKeys(key)

	local current = gv_ABD

	for i, k in ipairs(keys) do
		if i == #keys then
			current[k] = value
		else
			current[k] = current[k] or {}
			current = current[k]
		end
	end
end

function ABD:SetStatusEffectWithStacks(unit, effect, stacks)
	local statusEffect = unit:GetStatusEffect(effect)
	if statusEffect then
		local currentStacks = statusEffect.stacks

		if currentStacks == stacks then
			return
		end

		local diff = abs(currentStacks - stacks)

		if currentStacks >= stacks then
			unit:RemoveStatusEffect(effect, currentStacks - diff)
		else
			unit:AddStatusEffect(effect, diff)
		end
	else
		unit:AddStatusEffect(effect, stacks)
	end
end

function ABD:GetGameVar(key)
	gv_ABD = gv_ABD or {}

	local keys = self:GetKeys(key)

	local value = gv_ABD

	for i, k in ipairs(keys) do
		value = value[k]
		if not value then
			return nil
		end
	end

	return value
end

function ABD:ClearGameVar(key)
	self:SetGameVar(key, nil)
end

function ABD:GetKeys(key)
	local keys = {}

	for k in string.gmatch(key, "[^%.]+") do
		table.insert(keys, k)
	end

	return keys
end

function ABD:ArrayContains(array, value)
	for k, v in pairs(array) do
		if v == value then
			return true
		end
	end

	return false
end

function ABD:GetClosestBase(sectorId, affiliation, additionalSpawns, maxDistance)
	local closestBaseSector = nil

	for k, sector in pairs(gv_Sectors) do
		if (sector.Guardpost or additionalSpawns and table.find(additionalSpawns, sector.Id)) and IsEnemySide(sector.Side) and self:GetSectorAffiliation(sector) == affiliation then
			if not closestBaseSector then
				closestBaseSector = sector
			else
				local distance = GetSectorDistance(sectorId, sector.Id)
				local closestDistance = GetSectorDistance(sectorId, closestBaseSector.Id)

				if distance < closestDistance then
					closestBaseSector = sector
				end
			end
		end
	end

	return closestBaseSector
end

function ABD:GetSectorAffiliation(sector)
	sector = type(sector) == "string" and gv_Sectors[sector] or sector

	if not sector then return nil end

	local enemySquads = sector.enemy_squads

	for i, squad in ipairs(enemySquads) do
		for i, unitId in ipairs(squad.units) do
			local unit = gv_UnitData[unitId]

			if unit and unit.Affiliation and table.find({ "Legion", "Army" }, unit.Affiliation) then
				return unit.Affiliation
			end
		end
	end

	return nil
end

function ABD:MoveSquads(squadIds, city, type, src, dst)
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

function ABD:GetCardinalSectors(sector_id, side)
	local directions = { "down", "up", "right", "left" }
	local sectors = {}
	local i = 1
	ForEachSectorCardinal(sector_id, function(sector_id)
		sectors[directions[i]] = sector_id
		i = i + 1
	end)
	return sectors
end

function ABD:GetBestExitZoneInteractable(direction)
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

function ABD:GetWeaponRange(unit)
	local weapon, wep2 = unit:GetActiveWeapons()

	if IsKindOf(weapon, "MeleeWeapon") then
		local tiles = unit.body_type == "Large animal" and 2 or 1
		local range = (2 * tiles + 1) * const.SlabSizeX / 2
		return range
	elseif IsKindOf(weapon, "Firearm") then
		local max_range = weapon.WeaponRange * const.SlabSizeX
		return 15 * max_range / 10
	end
end

-- g_HUDA_PosCache = {}
-- g_HUDA_DistCache = {}

-- function OnMsg.NewCombatTurn()
-- 	g_HUDA_PosCache = {}
-- 	g_HUDA_DistCache = {}
-- end

-- function HUDA_GetCloseUnits(unit, range)
-- 	local enemies = {}
-- 	local allies = {}
-- 	local range = range or 20 --todo different daylight and weather conditions
-- 	local pos

-- 	if g_HUDA_PosCache[unit.session_id] then
-- 		pos = g_HUDA_PosCache[unit]
-- 	else
-- 		pos = unit:GetPos()
-- 		g_HUDA_PosCache[unit.session_id] = pos
-- 	end

-- 	for _, u in ipairs(g_Units) do
-- 		local dist

-- 		g_HUDA_DistCache[u.session_id] = g_HUDA_DistCache[u.session_id] or {}

-- 		g_HUDA_DistCache[unit.session_id] = g_HUDA_DistCache[unit.session_id] or {}

-- 		if g_HUDA_DistCache[u.session_id][unit.session_id] then
-- 			dist = g_HUDA_DistCache[u.session_id][unit.session_id]
-- 		elseif g_HUDA_DistCache[unit.session_id][u.session_id] then
-- 			dist = g_HUDA_DistCache[unit.session_id][u.session_id]
-- 		else
-- 			dist = u:GetDist2D(pos)
-- 			g_HUDA_DistCache[u.session_id][unit.session_id] = dist
-- 			g_HUDA_DistCache[unit.session_id][u.session_id] = dist
-- 		end

-- 		if IsValid(u) and u ~= unit and dist < range * const.SlabSizeX and not u:IsDead() and not u:HasStatusEffect("Unconscious") and not u:HasStatusEffect("Downed") then
-- 			if unit:IsOnEnemySide(u) then
-- 				table.insert(enemies, u)
-- 			elseif unit:IsOnAllySide(u) then
-- 				table.insert(allies, u)
-- 			end
-- 		end
-- 	end

-- 	return enemies, allies
-- end
