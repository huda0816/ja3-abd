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
		}
	},
	movementTypeNoiseRadiusFallback = 15,

	movementTypeNoiseRadius = {
		["StepRunCrouch"] = 10,
		["StepRun"] = 20,
		["StepWalk"] = 15,
		["Walk"] = 15
	},
	defaultNoiseRadius = 30,
	untraceableChanceModifier = -40,
	stealthyChanceModifier = -40,
	bushChanceModifier = 80,
	bushRangeModifier = 50,
	noiseThread = nil,
	debounceStorage = {}
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
		-- assert(g_Exploration and not g_Combat)
		if not GameState.sync_loading and not HasAnyAttackActionInProgress() then
			local units = g_Units

			for i = 1, #units do
				local unit = units[i]

				if unit:IsValidPos() then
					local noiseDistance = self:GetDistance(unit)

					if noiseDistance > 0 then
						local enemies = GetAllEnemyUnits(unit)

						for j = 1, #enemies do
							local enemy = enemies[j]

							if enemy:IsValidPos() then
								local distance = unit:GetDist2D(enemy)

								if distance <= noiseDistance then
									self:DoNoise(unit, enemy, noiseDistance, distance)
								end
							end
						end
					end
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

function ABD_Noise:DoNoise(ally, enemy, noiseDistance, distance)
	self:Log(ally, enemy, noiseDistance, distance)
	self:Effects(ally, enemy, noiseDistance, distance)
end

function ABD_Noise:Effects(ally, enemy, noiseDistance, distance)
	if g_Combat then
		return
	end

	if not self:IsPlayerControlled(enemy) then
		if enemy:IsInterruptable() then
			-- lets roll a dice to see if the enemy will just turn around or investigate the noise

			local noiseRoll = InteractionRand(40, "Noise")

			local closenessPercent = MulDivRound(noiseDistance - distance, 100, noiseDistance)

			if noiseRoll + 30 > closenessPercent then
				enemy:SetCommand("FaceAttackerCommand", ally)
			else
				if enemy.command ~= "GotoSlab" then
					print("investigate noise", enemy.session_id)
					local originalPos = enemy:GetPos()
					enemy:SetCommand("GotoSlab", ally:GetPos(), nil, nil, "Walk")
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

function ABD_Noise:Log(ally, enemy, noiseDistance, distance)
	local angle_to_object = AngleDiff(CalcOrientation(enemy, ally), enemy:GetOrientationAngle())

	local direction = T { 987908907890091, "front" }

	if angle_to_object >= 45 * 60 and angle_to_object < 135 * 60 then
		direction = T { 987908907890092, "right" }
	elseif abs(angle_to_object) >= 135 * 60 then
		direction = T { 987908907890093, "back" }
	elseif angle_to_object <= -45 * 60 and angle_to_object > -135 * 60 then
		direction = T { 987908907890094, "left" }
	end

	local distDiff = noiseDistance - distance

	local closenessPercent = MulDivRound(distDiff, 100, noiseDistance)

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

function ABD_Noise:GetDistance(ally)
	if not ally.is_moving or not ally.move_step_fx then
		return 0
	end

	local hidden = ally:HasStatusEffect("Hidden")

	local surfaceStats = self:GetSurfaceStats(ally, hidden)

	local inBush

	if hidden then
		local noiseChance = surfaceStats.noiseChance

		local modifier = 100

		modifier = HasPerk(ally, "Untraceable") and modifier + self.untraceableChanceModifier or modifier

		modifier = HasPerk(ally, "Stealthy") and modifier + self.stealthyChanceModifier or modifier

		inBush = self:IsInBush(ally)

		modifier = inBush and modifier + self.bushChanceModifier or modifier

		noiseChance = MulDivRound(noiseChance, Max(0, modifier), 100)

		local noiseRoll = InteractionRand(100, "Noise")

		if noiseRoll > noiseChance then
			return 0
		end
	end

	local movementType = ally.move_step_fx

	local noiseDistance = self.movementTypeNoiseRadius[movementType] or self.movementTypeNoiseRadiusFallback

	if not noiseDistance then
		return 0
	end

	local noiseRangeModifier = surfaceStats.noiseRangeModifier

	inBush = inBush ~= nil and inBush or self:IsInBush(ally)

	noiseRangeModifier = inBush and noiseRangeModifier + self.bushRangeModifier or noiseRangeModifier

	if GameState.RainHeavy then
		noiseRangeModifier = noiseRangeModifier + const.EnvEffects.RainNoiseMod
	elseif GameState.RainLight or GameState.DustStorm then
		noiseRangeModifier = noiseRangeModifier + const.EnvEffects.RainNoiseMod / 2
	end

	return MulDivRound(noiseDistance, Max(0, noiseRangeModifier), 100) * const.SlabSizeX
end

function ABD_Noise:GetDefaultRadius()
	return (const.Combat.NoiseRadius or self.defaultNoiseRadius) * const.SlabSizeX + const.SlabSizeX / 4
end

function ABD_Noise:GetSurfaceStats(unit)
	local surfaceType = self:GetSurfaceType(unit)

	local surfaceStats = self.surfaceNoiseTypeStats[surfaceType]

	if not surfaceStats then
		surfaceStats = {
			noiseRangeModifier = self.surfaceNoiseRangeModifierFallback,
			noiseChance = self.surfaceNoiseChanceFallback
		}
	end

	return surfaceStats
end

function ABD_Noise:GetSurfaceType(unit)
	local pos = unit:GetPos()

	local walkable_slab = const.SlabSizeX and WalkableSlabByPoint(pos) or GetWalkableObject(pos)

	local surfaceType

	if walkable_slab then
		surfaceType = walkable_slab:GetMaterialType()

		if surfaceType then
			for key, value in pairs(self.surfaceNoiseTypeStats) do
				if string.find(surfaceType, key) then
					return key
				end
			end

			return
		end
	else
		surfaceType = terrain.GetTerrainType(pos)
	end

	if surfaceType then
		for key, value in pairs(self.surfaceNoiseTypeStats) do
			if string.find(surfaceType, key) then
				return key
			end
		end
	end

	return nil
end
