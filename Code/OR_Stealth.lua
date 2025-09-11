-- local ABD_Original_IsIlluminated = IsIlluminated

-- function IsIlluminated(target, voxels, sync, step_pos)
-- 	--if step_pos is present, use it for all pos checks and use the target for all unit checks
-- 	if not IsValid(target) or not target:IsValidPos() then return end
-- 	if not GameState.Night and not GameState.Underground then
-- 		return true
-- 	end

-- 	if ABD:GetGameVar("darkness.lightning") then
-- 		return true
-- 	end


-- 	if ABD_Flashlight:IsInFlashLightCone(target) then
-- 		return true
-- 	end

-- 	return ABD_Original_IsIlluminated(target, voxels, sync, step_pos)
-- end

function IsIlluminated(target, voxels, sync, step_pos)
	--if step_pos is present, use it for all pos checks and use the target for all unit checks
	if not IsValid(target) or not target:IsValidPos() then return end
	if not GameState.Night and not GameState.Underground then
		return true
	end

	if ABD:GetGameVar("darkness.lightning") then
		return true
	end

	if ABD_Flashlight:IsInFlashLightCone(target) then
		return true
	end

	local env_factors = GetVoxelStealthParams(step_pos or target)
	--if sync then NetUpdateHash("IsIlluminated", target, target:GetPos(), env_factors, table.unpack(voxels)) end
	if env_factors ~= 0 and band(env_factors, const.vsFlagIlluminated) ~= 0 then
		return true
	end
	-- If the weapon ignores dark it also generates light (in theory)
	if IsKindOf(target, "Unit") then
		if target:HasStatusEffect("ABD_FlashlightOn") then
			return true
		end
		-- local _, __, weapons = target:GetActiveWeapons()
		-- for i, w in ipairs(weapons) do
		-- 	if w:HasComponent("IgnoreInTheDark") then
		-- 		return true
		-- 	end
		-- end
	end

	if next(g_DistToFire) == nil then
		return
	end

	if not voxels then
		if IsKindOf(target, "Unit") then
			voxels = step_pos and target:GetVisualVoxels(step_pos) or target:GetVisualVoxels()
		else
			local x, y, z = WorldToVoxel(target)
			voxels = {point_pack(x, y, z)}
		end
	end
	return AreVoxelsInFireRange(voxels)
end
