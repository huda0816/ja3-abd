local HUDA_OriginalGetSightRadius = Unit.GetSightRadius

function Unit:GetSightRadius(other, base_sight, step_pos)
	local base_sight = base_sight or (self:IsAware() or self:HasStatusEffect("ABD_Alerted")) and const.Combat.AwareSightRange or
		const.Combat.UnawareSightRange

	return HUDA_OriginalGetSightRadius(self, other, base_sight, step_pos)
end