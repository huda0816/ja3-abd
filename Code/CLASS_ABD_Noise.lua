-- TODOs:
-- Improving reaction to sound
-- Adding throw item to distract enemies

MapVar("mv_ABD_SurfaceCache", {})

function ABD_GetTerrainTypes()
	return {
		{
			idx = 1,
			Id = "JGrass",
			type = "Grass",
			noiseType = "Grass",
		},
		{
			idx = 2,
			Id = "JGrass_Mix",
			type = "Grass",
			noiseType = "Grass",
		},
		{
			idx = 3,
			Id = "JMud_Dry",
			type = "Mud",
			noiseType = "Dry",
		},
		{
			idx = 4,
			Id = "JForest_Floor_01",
			type = "Mud",
			noiseType = "Forest",
		},
		{
			idx = 5,
			Id = "JSand",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 6,
			Id = "JGround_Mix",
			type = "Jungle",
			noiseType = "Forest",
		},
		{
			idx = 7,
			Id = "JForest_Floor_02",
			type = "Mud",
			noiseType = "Forest",
		},
		{
			idx = 8,
			Id = "Black",
			type = "Sand",
			noiseType = "Asphalt",
		},
		{
			idx = 9,
			Id = "JForest_Floor_03",
			type = "Mud",
			noiseType = "Forest",
		},
		{
			idx = 10,
			Id = "BeachSand_01",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 11,
			Id = "BeachSand_02",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 12,
			Id = "BeachSand_03",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 13,
			Id = "BeachSand_04",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 14,
			Id = "BeachSand_05",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 15,
			Id = "JMud_Wet",
			type = "Mud",
			noiseType = "Water",
		},
		{
			idx = 16,
			Id = "JMud_01",
			type = "Mud",
			noiseType = "Water",
		},
		{
			idx = 17,
			Id = "JMud_02",
			type = "Water",
			noiseType = "Water",
		},
		{
			idx = 18,
			Id = "JMoss_01",
			type = "Grass",
			noiseType = "Grass",
		},
		{
			idx = 19,
			Id = "Grass_01",
			type = "Grass",
			noiseType = "Grass",
		},
		{
			idx = 20,
			Id = "Skeleton",
			type = "Grass",
			noiseType = "Gravel",
		},
		{
			idx = 21,
			Id = "M_Concrete_01",
			type = "Asphalt",
			noiseType = "Asphalt",
		},
		{
			idx = 22,
			Id = "M_Concrete_02",
			type = "Asphalt",
			noiseType = "Asphalt",
		},
		{
			idx = 23,
			Id = "M_Concrete_03",
			type = "Asphalt",
			noiseType = "Asphalt",
		},
		{
			idx = 24,
			Id = "Dry_cracked",
			type = "Dry",
			noiseType = "Dry",
		},
		{
			idx = 25,
			Id = "Dry_mud",
			type = "Mud",
			noiseType = "Dry",
		},
		{
			idx = 26,
			Id = "Dry_gravelly",
			noiseType = "Gravel"
		},
		{
			idx = 27,
			Id = "New_grass",
			type = "Grass",
			noiseType = "Grass",
		},
		{
			idx = 28,
			Id = "RiverMud_Dry_01",
			type = "Mud",
			noiseType = "Dry",
		},
		{
			idx = 29,
			Id = "RiverMud_01",
			type = "Mud",
			noiseType = "Water",
		},
		{
			idx = 30,
			Id = "RiverSand",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 31,
			Id = "RiverMud_02",
			type = "Mud",
			noiseType = "Water",
		},
		{
			idx = 32,
			Id = "Dry_grass",
			type = "Grass",
			noiseType = "Grass",
		},
		{
			idx = 33,
			Id = "Dry_BurntGround_01",
			type = "Dry",
			noiseType = "Dry",
		},
		{
			idx = 34,
			Id = "Dry_BurntGround_02",
			type = "Dry",
			noiseType = "Dry",
		},
		{
			idx = 35,
			Id = "Dry_stony_01",
			type = "Sand",
			noiseType = "Gravel",
		},
		{
			idx = 36,
			Id = "Dry_cracked_02",
			type = "Dry",
			noiseType = "Dry",
		},
		{
			idx = 37,
			Id = "Dry_rock_01",
			type = "Gravel",
			noiseType = "Gravel",
		},
		{
			idx = 38,
			Id = "Dry_rock_02",
			type = "Gravel",
			noiseType = "Gravel",
		},
		{
			idx = 39,
			Id = "Dry_stony_02",
			type = "Sand",
			noiseType = "Gravel",
		},
		{
			idx = 40,
			Id = "City_Dump_01",
			noiseType = "Gravel",
		},
		{
			idx = 41,
			Id = "City_Tiles01",
			noiseType = "Asphalt",
		},
		{
			idx = 42,
			Id = "CityToxic_01",
			noiseType = "Asphalt",
		},
		{
			idx = 43,
			Id = "CityGravel_01",
			noiseType = "Gravel",
		},
		{
			idx = 44,
			Id = "Dry_sand_01",
			type = "Sand",
			noiseType = "Sand",
		},
		{
			idx = 45,
			Id = "RiverWalkable",
			type = "Water",
			noiseType = "Water",
		},
		{
			idx = 46,
			Id = "RiverPlant_01",
			type = "Water",
			noiseType = "Water",
		},
		{
			idx = 47,
			Id = "RiverImpassable",
			type = "Water",
			noiseType = "Water",
		},
		{
			idx = 48,
			Id = "Farm_01",
			noiseType = "Grass",
		},
		{
			idx = 49,
			Id = "Farm_02",
			noiseType = "Grass",
		},
		{
			idx = 50,
			Id = "Asphalt_01",
			type = "Asphalt",
			noiseType = "Asphalt",
		},
		{
			idx = 51,
			Id = "Asphalt_02",
			type = "Asphalt",
			noiseType = "Asphalt",
		},
		{
			idx = 52,
			Id = "JMud_Dry_02",
			type = "Mud",
			noiseType = "Forest",
		},
		{
			idx = 53,
			Id = "JMud_Mix",
			type = "Mud",
			noiseType = "Forest",
		}
	}
end

DefineClass.ABD_Noise = {
	__parents = { "ABD" },
	terrainNoiseTypeTable = ABD_GetTerrainTypes(),
	surfaceNoiseRangeModifierFallback = 100,
	surfaceNoiseChanceFallback = 10,
	surfaceNoiseTypeStats = {
		Forest = {
			noiseRangeModifier = 150,
			noiseChance = 10
		},
		Grass = {
			noiseRangeModifier = 80,
			noiseChance = 5
		},
		Water = {
			noiseRangeModifier = 140,
			noiseChance = 30
		},
		Sand = {
			noiseRangeModifier = 50,
			noiseChance = 3
		},
		Asphalt = {
			noiseRangeModifier = 100,
			noiseChance = 10
		},
		Dry = {
			noiseRangeModifier = 100,
			noiseChance = 10
		},
		Gravel = {
			noiseRangeModifier = 110,
			noiseChance = 15
		},
		Brick = {
			noiseRangeModifier = 100,
			noiseChance = 10
		},
		Concrete = {
			noiseRangeModifier = 100,
			noiseChance = 10
		},
		Metal = {
			noiseRangeModifier = 110,
			noiseChance = 15
		},
		Planks = {
			noiseRangeModifier = 120,
			noiseChance = 15
		},
		Wood = {
			noiseRangeModifier = 120,
			noiseChance = 15
		},
		Stone = {
			noiseRangeModifier = 100,
			noiseChance = 10
		}
	},
	movementTypeNoiseRadiusFallback = 15,
	movementTypeNoiseRadius = {
		["Walk"] = 15,
		["Run"] = 20,
		["Crouch"] = 10,
		["ClimbLadder"] = 15,
		["Climb"] = 15,
		["Jump"] = 20,
		["Drop"] = 20
	},
	noiseTypeMapping = {
		["StepWalk"] = "Walk",
		["StepRun"] = "Run",
		["StepRunCrouch"] = "Crouch",
		["Anim:nw_LadderClimbOff_End"] = "ClimbLadder",
		["Anim:nw_LadderClimbOff_Start"] = "ClimbLadder",
		["Anim:nw_LadderClimbOn_End"] = "ClimbLadder",
		["Anim:nw_LadderClimbOn_Start"] = "ClimbLadder",
		["MoveClimb"] = "Climb",
		["MoveJump"] = "Jump",
		["MoveDrop"] = "Drop"
	},
	defaultNoiseRadius = 30,
	untraceableChanceModifier = -40,
	stealthyChanceModifier = -40,
	bushChanceModifier = {
		Grass = 20,
		Low = 30,
		Bush = 80
	},
	bushRangeModifier = {
		Grass = 20,
		Low = 30,
		Bush = 50
	},
	hiddenRangeModifier = -25,
	noiseThread = nil,
	debounceStorage = {},
}


function ABD_Noise:Init()
	self.noiseThread = CreateGameTimeThread(ABD_Noise.Thread, self)
end

function ABD_Noise:Done()
	if IsValidThread(self.noiseThread) then
		DeleteThread(self.noiseThread)
		self.noiseThread = nil
	end
end

function ABD_Noise:Thread()
	self.debounceStorage = {}
	local debounceIterator = 0
	while true do
		-- TODO handle noise in combat
		-- assert(g_Exploration and not g_Combat)
		if not GameState.sync_loading and not HasAnyAttackActionInProgress() then
			local units = g_Units

			for i = 1, #units do
				local unit = units[i]

				if unit.is_moving and unit.move_step_fx and self.noiseTypeMapping[unit.move_step_fx] then
					self:HandleNoise(unit, self.noiseTypeMapping[unit.move_step_fx])
				end
			end
		end
		if debounceIterator == 32 then
			self.debounceStorage = {}
			debounceIterator = 0
		end
		debounceIterator = debounceIterator + 1
		Sleep(500)
	end
end

function ABD_Noise:HandleNoise(unit, mappedNoiseType)
	if not unit:IsValidPos() or not IsKindOf(unit, "Unit") then
		return
	end

	local noiseRadius = self:GetNoiseRadius(unit, mappedNoiseType)

	if noiseRadius <= 0 then
		return
	end

	local enemies = GetAllEnemyUnits(unit)
	-- TODO: Maybe also get civilians but they are not cached

	for j = 1, #enemies do
		local enemy = enemies[j]

		if enemy:IsValidPos() then
			local distance = unit:GetDist2D(enemy)

			if distance <= noiseRadius then
				self:DoNoise(unit, enemy, noiseRadius, distance)
			end
		end
	end
end

function ABD_Noise:DoNoise(actor, enemy, noiseRadius, distance)
	self:Log(actor, enemy, noiseRadius, distance)
	self:Effects(actor, enemy, noiseRadius, distance)
end

function ABD_Noise:Effects(actor, enemy, noiseRadius, distance)
	if g_Combat or
		enemy:IsDead() or
		enemy:HasStatusEffect("Unconscious") or
		enemy:HasStatusEffect("Downed") or
		self:IsPlayerControlled(enemy) or
		not enemy:IsInterruptable()
	then
		return
	end

	local noiseRoll = InteractionRand(40, "Noise")

	local closenessPercent = MulDivRound(noiseRadius - distance, 100, noiseRadius)

	if noiseRoll + 30 > closenessPercent then
		enemy:SetCommand("FaceAttackerCommand", actor)
	else
		if enemy.command ~= "GotoSlab" then
			local originalPos = enemy:GetPos()
			enemy:SetCommand("GotoSlab", actor:GetPos(), nil, nil, "Walk")
			for i = 1, 200 do
				if enemy.command ~= "GotoSlab" then
					break
				end
				Sleep(50)

				if i > 100 then
					local returnRoll = InteractionRand(100, "Noise")

					if returnRoll < i - 100 then
						enemy:SetCommand("GotoSlab", originalPos, nil, nil, "Walk")

						break
					end
				end
			end
		end
	end
end

function ABD_Noise:Log(actor, enemy, noiseRadius, distance)
	local angle_to_object = AngleDiff(CalcOrientation(enemy, actor), enemy:GetOrientationAngle())

	local direction = T { 987908907890091, "front" }

	if angle_to_object >= 45 * 60 and angle_to_object < 135 * 60 then
		direction = T { 987908907890092, "right" }
	elseif abs(angle_to_object) >= 135 * 60 then
		direction = T { 987908907890093, "back" }
	elseif angle_to_object <= -45 * 60 and angle_to_object > -135 * 60 then
		direction = T { 987908907890094, "left" }
	end

	local distDiff = noiseRadius - distance

	local closenessPercent = MulDivRound(distDiff, 100, noiseRadius)

	local closeOrFar = T { 9879089078900989, "noise" }

	if closenessPercent < 33 then
		closeOrFar = T { 987908907890097, "faint noise" }
	elseif closenessPercent > 66 then
		closeOrFar = T { 987908907890096, "loud noise" }
	end

	local debugLevel = "debug"

	if self:IsPlayerControlled(enemy) then
		if not self.debounceStorage[enemy.session_id] then
			self.debounceStorage[enemy.session_id] = true
			debugLevel = "important"
		end
	end

	CombatLog(debugLevel,
		T { 99798278968987, "<em><name></em> heard a <intensity> from <em>the <direction></em>", name = enemy:GetDisplayName(), intensity = closeOrFar, direction = direction })
end

function ABD_Noise:GetNoiseRadius(actor, mappedNoiseType)
	if not mappedNoiseType then
		return 0
	end

	local hidden = actor:HasStatusEffect("Hidden")

	local surfaceStats = self:GetSurfaceStats(actor)

	local inBush, highestBush, bushes = self:IsInBush(actor)

	if hidden then
		local noiseChance = surfaceStats.noiseChance

		local modifier = 100

		modifier = HasPerk(actor, "Untraceable") and modifier + self.untraceableChanceModifier or modifier

		modifier = HasPerk(actor, "Stealthy") and modifier + self.stealthyChanceModifier or modifier

		local bushChanceModifier = inBush and self.bushChanceModifier[highestBush] or 0

		modifier = modifier + bushChanceModifier

		noiseChance = MulDivRound(noiseChance, Max(0, modifier), 100)

		local maxRoll = actor.Dexterity

		local noiseRoll = InteractionRand(maxRoll, "Noise")

		if noiseRoll > noiseChance then
			return 0
		end
	end

	local noiseRadius = self.movementTypeNoiseRadius[mappedNoiseType] or self.movementTypeNoiseRadiusFallback

	if noiseRadius == 0 then
		return 0
	end

	local noiseRangeModifier = surfaceStats.noiseRangeModifier

	noiseRangeModifier = inBush and noiseRangeModifier + self.bushRangeModifier[highestBush] or noiseRangeModifier

	noiseRangeModifier = hidden and noiseRangeModifier + self.hiddenRangeModifier or noiseRangeModifier

	if GameState.RainHeavy then
		noiseRangeModifier = noiseRangeModifier + const.EnvEffects.RainNoiseMod
	elseif GameState.RainLight or GameState.DustStorm then
		noiseRangeModifier = noiseRangeModifier + const.EnvEffects.RainNoiseMod / 2
	end

	return MulDivRound(noiseRadius, Max(0, noiseRangeModifier), 100) * const.SlabSizeX
end

function ABD_Noise:GetMovementTypeNoiseRadius(movementType)
	return self.movementTypeNoiseRadius[movementType] or self.movementTypeNoiseRadiusFallback
end

function ABD_Noise:GetDefaultRadius()
	return (const.Combat.NoiseRadius or self.defaultNoiseRadius) * const.SlabSizeX + const.SlabSizeX / 4
end

function ABD_Noise:GetSurfaceStats(unit)
	local surfaceType = self:GetSurfaceType(unit)

	local surfaceStats = self.surfaceNoiseTypeStats[surfaceType]

	if not surfaceStats or surfaceStats == "Default" then
		surfaceStats = {
			noiseRangeModifier = self.surfaceNoiseRangeModifierFallback,
			noiseChance = self.surfaceNoiseChanceFallback
		}
	end

	return surfaceStats
end

function ABD_Noise:GetSurfaceType(unit)
	local pos = unit:GetPos()

	local hashedPos = point_pack(pos)

	mv_ABD_SurfaceCache = mv_ABD_SurfaceCache or {}

	local cachedSurfaceType = mv_ABD_SurfaceCache[hashedPos]

	if cachedSurfaceType then
		return cachedSurfaceType
	end

	local surfaceType = "Default"

	local walkable_slab = const.SlabSizeX and WalkableSlabByPoint(pos) or GetWalkableObject(pos)

	local material

	if walkable_slab then
		material = walkable_slab:GetMaterialType()

		if surfaceType then
			for key, value in pairs(self.surfaceNoiseTypeStats) do
				if string.find(material, key) then
					mv_ABD_SurfaceCache[hashedPos] = key
					return key
				end
			end
		end
	end

	local terrainType = terrain.GetTerrainType(pos)

	if terrainType then
		local terrainStats = self.terrainNoiseTypeTable[terrainType]

		if terrainStats then
			surfaceType = self.surfaceNoiseTypeStats[terrainStats.noiseType] and terrainStats.noiseType or "Default"
		end
	end

	mv_ABD_SurfaceCache[hashedPos] = surfaceType

	if surfaceType == "Default" then
		self:Print("No surface type found for", pos, terrainType, material)
	end

	return surfaceType
end

function ABD_Noise:HandleFXNoise(actionFXClass, actor)
	local mappedNoiseType = self.noiseTypeMapping[actionFXClass.fx_type]

	if not mappedNoiseType then
		return
	end

	self:HandleNoise(actor, mappedNoiseType)
end
