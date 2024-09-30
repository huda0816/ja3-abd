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

function ABD:IsInBush(unit)
	local enum_bush_radius = const.AnimMomentHookTraverseVegetationRadius

	local pos = unit:GetPos()

	local bushes = MapGet(pos, enum_bush_radius, "TraverseVegetation", function(obj, pos) return pos:InBox(obj) end, pos)

	return bushes and #bushes > 0
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
