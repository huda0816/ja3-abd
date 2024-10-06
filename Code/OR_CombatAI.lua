function AIPickScoutLocation(unit)
	local AIScoutLocationSearchRadius = 5 * guim

	-- pick a new position around alive enemy randomly, prefer non-hidden enemies
	local enemies = GetAllEnemyUnits(unit)
	
	if #enemies == 0 then
		return
	end

	local targets
	local nearest, nearby = {}, {}
	for _, enemy in ipairs(enemies) do
		local dist = unit:GetDist(enemy)
		if dist <= AIScoutLocationSearchRadius then
			nearest[#nearest + 1] = enemy
			targets = nearest
		elseif dist <= 2*AIScoutLocationSearchRadius then
			nearby[#nearby + 1] = enemy
			targets = targets or nearby
		end
	end
	targets = targets or enemies
	local enemy = table.interaction_rand(enemies, "Combat")
	
	local ux, uy, uz = enemy:GetGridCoords()
	local px, py, pz = VoxelToWorld(ux, uy, uz)
	local r = AIScoutLocationSearchRadius
	local bbox = box(px - r, py - r, 0, px + r + 1, py + r + 1, MapSlabsBBox_MaxZ)
	
	local dests, dest_added = {}, {}
	local function push_dest(x, y, z, dests, dest_added, ux, uy, uz)
		local gx, gy, gz = WorldToVoxel(x, y, z)
		
		if not IsCloser(gx, gy, gz, ux, uy, uz, AIScoutLocationSearchRadius) then
			return
		end
				
		local world_voxel = point_pack(x, y, z)
		if not dest_added[world_voxel] then
			dests[#dests + 1] = world_voxel
			dest_added[world_voxel] = true
		end		
	end
	
	ForEachPassSlab(bbox, push_dest, dests, dest_added, ux, uy, uz)
	
	if #dests > 0 then
		local voxel = table.interaction_rand(dests, "Combat")
		local x, y, z = point_unpack(voxel)
		return point(x, y, z)
	end	
end