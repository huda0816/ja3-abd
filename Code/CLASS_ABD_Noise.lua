-- TODOs:
-- Improving reaction to sound
-- Adding throw item to distract enemies
-- Sounds climbing

MapVar("mv_ABD_SurfaceCache", {})

DefineClass.ABD_Noise = {
	__parents = { "ABD" },
	terrainNoiseTypeTable = g_ABD_TerrainNoiseTypeTable,
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
	bushChanceModifier = 80,
	bushRangeModifier = 50,
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
	if g_Combat then
		return
	end

	if not self:IsPlayerControlled(enemy) then
		if enemy:IsInterruptable() then
			-- lets roll a dice to see if the enemy will just turn around or investigate the noise

			local noiseRoll = InteractionRand(40, "Noise")

			local closenessPercent = MulDivRound(noiseRadius - distance, 100, noiseRadius)

			if noiseRoll + 30 > closenessPercent then
				enemy:SetCommand("FaceAttackerCommand", actor)
			else
				if enemy.command ~= "GotoSlab" then
					print("investigate noise", enemy.session_id)
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

	local inBush

	if hidden then
		local noiseChance = surfaceStats.noiseChance

		local modifier = 100

		modifier = HasPerk(actor, "Untraceable") and modifier + self.untraceableChanceModifier or modifier

		modifier = HasPerk(actor, "Stealthy") and modifier + self.stealthyChanceModifier or modifier

		inBush = self:IsInBush(actor)

		modifier = inBush and modifier + self.bushChanceModifier or modifier

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

	inBush = inBush ~= nil and inBush or self:IsInBush(actor)

	noiseRangeModifier = inBush and noiseRangeModifier + self.bushRangeModifier or noiseRangeModifier

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
		-- print("No surface type found for", pos, terrainType, material)
	end

	return surfaceType
end

GameVar("gv_ABD_Actions", {})

function ABD_Noise:HandleFXNoise(actionFXClass, actor)
	local mappedNoiseType = self.noiseTypeMapping[actionFXClass.fx_type]

	if not mappedNoiseType then
		return
	end

	self:HandleNoise(actor, mappedNoiseType)
end
