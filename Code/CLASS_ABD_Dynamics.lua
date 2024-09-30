function HUDA_GetComRange(unit, ally)
	--commander has a bigger range
	if unit.role == "Commander" then
		return 100
	end

	return 20
end

function HUDA_IsCommanderAllerted(alerted_units)
	for _, unit in ipairs(alerted_units) do
		if unit.role == "Commander" then
			return true
		end
	end
	return false
end

local OriginalPushUnitAlert = PushUnitAlert

function PushUnitAlert(trigger_type, ...)
	if trigger_type == "noise" then
		local actor, radius, soundName, attacker = ...

		print(TDevModeGetEnglishText(soundName))

		radius = actor == attacker and MulDivRound(radius, 150, 100) or radius

		print("Noise alert", TDevModeGetEnglishText(actor.Name or actor.Nick), "radius", radius)

		return OriginalPushUnitAlert(trigger_type, actor, radius, soundName, attacker)
	end

	return OriginalPushUnitAlert(trigger_type, ...)
end