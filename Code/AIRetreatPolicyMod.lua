DefineClass.AIRetreatPolicyMod = {
	__parents = { "AIPositioningPolicy", },
	__generated_by_class = "ClassDef",

	properties = {
		{
			id = "optimal_location",
			editor = "bool",
			default = true,
			read_only = true,
			no_edit = true,
		},
		{
			id = "end_of_turn",
			editor = "bool",
			default = true,
			read_only = true,
			no_edit = true,
		},
		{
			id = "Weight",
			editor = "number",
			default = 100,
			scale = "%",
		},
		{
			id = "Required",
			editor = "bool",
			default = true,
		},
	},
}

function AIRetreatPolicyMod:EvalDest(context, dest, grid_voxel)
	local vx, vy = point_unpack(grid_voxel)
	local markers = context.entrance_markers or MapGetMarkers("Entrance")
	context.entrance_markers = markers

	local score = 0

	local direction, sectorId = HUDA_GetBestRetreatSectorBySide("enemy1")

	local exitZone = HUDA_GetBestExitZoneInteractable(direction)

	local finalMarkers = {}

	if exitZone then
		for index, value in ipairs(markers) do
			if value.exit_zone_interactable and exitZone.handle == value.exit_zone_interactable.handle then
				table.insert(finalMarkers, value)
			end
		end
	end

	for _, marker in ipairs(finalMarkers) do
		context.entrance_marker_dir = context.entrance_marker_dir or {}
		local marker_dir = context.entrance_marker_dir[marker]
		if not marker_dir then
			marker_dir = marker:GetVisualPos() - context.unit:GetVisualPos()
			marker_dir = marker_dir:SetZ(0)
			if marker_dir:Len() > 0 then
				marker_dir = SetLen(marker_dir, guim)
			end
			context.entrance_marker_dir[marker] = marker_dir
		end

		-- Calculate distance-based score for proximity to marker
		local voxel_world_x, voxel_world_y, voxel_world_z = VoxelToWorld(vx, vy, 0)
		local marker_pos = marker:GetVisualPos()
		local dx = voxel_world_x - marker_pos:x()
		local dy = voxel_world_y - marker_pos:y()
		local distance = sqrt(dx * dx + dy * dy)

		-- Higher score for closer positions (inverse distance scoring)
		-- Max distance for scoring (adjust as needed)
		local max_scoring_distance = 20 * guim
		local distance_score = 0
		if distance <= max_scoring_distance then
			distance_score = (max_scoring_distance - distance) / max_scoring_distance * guim
		end
		score = score + distance_score

		if marker:IsVoxelInsideArea(vx, vy) then
			-- score based on direction
			for _, enemy_dir in pairs(context.enemy_dir) do
				local dot = Dot2D(marker_dir, enemy_dir) / guim
				score = score + guim - dot
			end
		end
	end

	return score / Max(1, #(context.enemies or empty_table))
end

function AIRetreatPolicyMod:GetEditorView()
	return "Retreat Mod"
end