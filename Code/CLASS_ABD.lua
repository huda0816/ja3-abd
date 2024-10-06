MapVar("mv_ABD_BushCache", {})
MapVar("mv_ABD_Weather", "")

DefineClass.ABD = {
	--props	
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

function ABD:IsInBush(unit, vegClasses)
	local pos = unit:GetPos()

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
	
	return "RainHeavy"

	-- local sectorId = gv_CurrentSectorId

	-- mv_ABD_Weather = mv_ABD_Weather or ""

	-- if mv_ABD_Weather and mv_ABD_Weather ~= "" then
	-- 	return mv_ABD_Weather
	-- end

	-- local weather = GetCurrentSectorWeather(sectorId) or "ClearSky"

	-- mv_ABD_Weather = weather

	-- return weather
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
