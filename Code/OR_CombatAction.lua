function OnMsg.DataLoaded()
	CombatActions.Overwatch.GetMaxAimRange = function (self, unit, weapon)
		local range = weapon:GetOverwatchConeParam("MaxRange")
		local sight = unit:GetSightRadius() / const.SlabSizeX
		return Max(range, sight)
	end
end