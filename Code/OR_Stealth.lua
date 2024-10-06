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

	

	return ABD_Original_IsIlluminated(target, voxels, sync, step_pos)
end