local HUDA_OriginalGetSightRadius = Unit.GetSightRadius

function Unit:GetSightRadius(other, base_sight, step_pos)
	local base_sight = (self:IsAware() or self:HasStatusEffect("HUDA_Alerted")) and const.Combat.AwareSightRange or
		const.Combat.UnawareSightRange

	if other and IsKindOf(other, "Unit") then
		local armor = other:GetItemInSlot("Torso", "Armor")
		local camoArmor = armor and armor.Camouflage
		-- local inBush = HUDA_IsInBush(other)
		
		-- if camoArmor and inBush then
		-- 	base_sight = base_sight / 3
		-- elseif inBush then
		-- 	base_sight = base_sight / 2
		-- end
	end

	return HUDA_OriginalGetSightRadius(self, other, base_sight, step_pos)
end