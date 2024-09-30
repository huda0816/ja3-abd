--this is just a fix
function AIPolicyProximity:EvalDest(context, dest, grid_voxel)
	local unit = context.unit
	local target_enemies = self.TargetUnits == "enemies"
	local units = target_enemies and context.enemies or context.allies
	local tdist = self.TargetDist

	local score = 0
	local num = 0
	local scale = const.SlabSizeX

	for _, other in ipairs(units) do
		if other ~= unit then
			local upos
			if target_enemies then
				upos = context.enemy_pack_pos_stance[other]
			else
				upos = context.ally_pack_pos_stance[other]
				if self.AllyPlannedPosition and other.ai_context then
					upos = other.ai_context.ai_destination or upos
				end
			end
			local dist = stance_pos_dist(dest, upos) / scale
			if tdist == "total" or tdist == "average" then
				score = score + dist
			else
				assert(tdist == "min")
				if not score or score == 0 or score > dist then
					score = dist
				end
			end
		end
	end

	if tdist == "average" and num > 0 then
		score = score / num
	end

	return score >= self.MinScore and score or 0
end
