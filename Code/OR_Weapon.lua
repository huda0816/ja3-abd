local ABD_Original_Firearm_GetOverwatchConeParam = Firearm.GetOverwatchConeParam


function Firearm:GetOverwatchConeParam(param)
	if param ~= "MaxRange" and param ~= "MinRange" and param ~= "Angle" then
		return ABD_Original_Firearm_GetOverwatchConeParam(self, param)
	end

	return IsKindOfClasses(self, "Shotgun", "MachineGun") and self.WeaponRange or MulDivRound(self.WeaponRange, 125, 100)
end