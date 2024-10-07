local ABD_Original_IsIlluminated = IsIlluminated

function IsIlluminated(target, voxels, sync, step_pos)
	--if step_pos is present, use it for all pos checks and use the target for all unit checks
	if not IsValid(target) or not target:IsValidPos() then return end
	if not GameState.Night and not GameState.Underground then
		return true
	end

	if ABD:GetGameVar("darkness.lightning") then
		return true
	end


	if IsInFlashLightCone(target) then
		return true
	end

	return ABD_Original_IsIlluminated(target, voxels, sync, step_pos)
end

function IsInFlashLightCone(unit)
	local flashLightRange = 16000

	-- Performing an attack or something
	if not IsValid(unit) or unit:IsDead() then
		return false
	end

	local units = g_Units
	local is = false

	for i, other in ipairs(units) do
		if other.retreating then goto continue end
		if other.command == "ExitCombat" then goto continue end
		if other:IsDead() then goto continue end

		local dist = other:GetDist(unit)

		if dist > flashLightRange then
			goto continue
		end

		local seesUnit = HasVisibilityTo(other, unit)

		if not seesUnit then
			goto continue
		end

		local angle_to_object = AngleDiff(CalcOrientation(other, unit), other:GetOrientationAngle())
		
		if abs(angle_to_object) > 15 * 60 then
			goto continue
		end

		is = true
		break

		::continue::
	end

	return is
end
