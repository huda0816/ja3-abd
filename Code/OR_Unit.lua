local ABD_Original_SetWeaponLightFx = Unit.SetWeaponLightFx

function Unit:SetWeaponLightFx(enable)
	-- print("silence is golden")
	-- for _, fx_actor in ipairs(self.weapon_light_fx) do
	-- 	PlayFX("TurnOn", "end", fx_actor)
	-- end
	-- self.weapon_light_fx = false
	
	-- if enable and self.visible and not self:CanQuickPlayInCombat() then
	-- 	local weapon1, weapon2 = self:GetActiveWeapons()
	-- 	playTurnOnFx(self, weapon1)
	-- 	playTurnOnFx(self, weapon2)
	-- end	
end

local HUDA_OriginalGetSightRadius = Unit.GetSightRadius

function Unit:GetSightRadius(other, base_sight, step_pos)
	local base_sight = base_sight or (self:IsAware() or self:HasStatusEffect("ABD_Alerted")) and const.Combat.AwareSightRange or
		const.Combat.UnawareSightRange

	return HUDA_OriginalGetSightRadius(self, other, base_sight, step_pos)
end