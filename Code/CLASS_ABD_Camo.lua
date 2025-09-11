-- TODOs:
-- Introduce Camo value to Armor and Helmet items
-- Make Ghillie suit item
-- Biome specific camo values

MapVar("mv_ABD_SectorTerrain", "")

AppendClass.Unit = {
	properties = {
		ABD_concealment = 0
	}
}

DefineClass.ABD_Camo = {
	__parents = { "ABD" },
	camoConcealmentModifier = 80,
	baseConcealment = {
		LowStandalone = {
			Prone = 20,
			Crouch = 10,
			Standing = 0
		},
		Low = {
			Prone = 40,
			Crouch = 10,
			Standing = 0
		},
		Grass = {
			Prone = 30,
			Crouch = 0,
			Standing = 0
		},
		Bush = {
			Prone = 50,
			Crouch = 40,
			Standing = 10
		}
	},
	concealmentMovementModifier = {
		Open = {
			StepRun = -1000,
			StepWalk = -1000,
			StepRunCrouch = -1000,
			StepRunProne = -1000,
			HiddenStepRunCrouch = -1000,
			HiddenStepRunProne = -1000,
		},
		Grass = {
			StepRun = -1000,
			StepWalk = -1000,
			StepRunCrouch = -1000,
			StepRunProne = -60,
			HiddenStepRunCrouch = -1000,
			HiddenStepRunProne = -30,
		},
		Low = {
			StepRun = -1000,
			StepWalk = -1000,
			StepRunCrouch = -80,
			StepRunProne = -60,
			HiddenStepRunCrouch = -60,
			HiddenStepRunProne = -30,
		},
		LowStandalone = {
			StepRun = -1000,
			StepWalk = -1000,
			StepRunCrouch = -70,
			StepRunProne = -50,
			HiddenStepRunCrouch = -50,
			HiddenStepRunProne = -20,
		},
		Bush = {
			StepRun = -1000,
			StepWalk = -1000,
			StepRunCrouch = -60,
			StepRunProne = -40,
			HiddenStepRunCrouch = -30,
			HiddenStepRunProne = -10,
		}
	},
	concealmentPerkModifiers = {
		Stealthy = 20,
		UntraceAble = 10
	},
	concealmentToSightRadiusModifier = 70
}

function ABD_Camo:GetSectorTerrain(unit)
	if mv_ABD_SectorTerrain and mv_ABD_SectorTerrain ~= "" then
		return mv_ABD_SectorTerrain
	end

	local sector = self:GetUnitSector(unit)

	mv_ABD_SectorTerrain = sector and sector.TerrainType or "Urban"

	return mv_ABD_SectorTerrain
end

-- TODO more cammo items like helmets, ghillie suits etc
-- Get Camo effectivness from the camo itself
function ABD_Camo:GetCamoModifier(unit)
	local armor = unit:GetItemInSlot("Torso", "Armor")

	if not armor or not armor.Camouflage then
		return 0
	end

	return armor.camoConcealmentModifier or self.camoConcealmentModifier
end

function ABD_Camo:GetConcealmentMovementModifier(unit)
	if not unit.is_moving then
		return 0
	end

	local movementType = unit.move_step_fx

	local inBush, highestBush, bushes = self:IsInBush(unit)

	highestBush = inBush and (highestBush == "Low" and #bushes == 1 and "LowStandalone" or highestBush) or "Open"

	movementType = unit:HasStatusEffect("Hidden") and "Hidden" .. movementType or movementType

	return self.concealmentMovementModifier[highestBush][movementType] or 0
end

function ABD_Camo:GetBaseConcealment(unit)
	local inBush, highestBush, bushes = self:IsInBush(unit)

	if not inBush then
		return 0
	end

	highestBush = highestBush == "Low" and #bushes == 1 and "LowStandalone" or highestBush

	local bushBonus = self.baseConcealment[highestBush][unit.stance] or 0

	return Max(bushBonus, 0)
end

function ABD_Camo:GetConcealmentPerkModifiers(unit)
	local concealment = 0

	for perk, value in pairs(self.concealmentPerkModifiers) do
		if unit:HasStatusEffect(perk) then
			concealment = concealment + value
		end
	end

	return concealment
end

function ABD_Camo:UpdateConcealment(unit)
	local concealment = 0

	local concealment = self:GetBaseConcealment(unit)

	concealment = Min(concealment, 100)

	local modifier = 100

	modifier = modifier + self:GetConcealmentMovementModifier(unit)

	modifier = modifier + self:GetConcealmentPerkModifiers(unit)

	modifier = modifier + self:GetCamoModifier(unit)

	modifier = Max(modifier, 0)

	concealment = MulDivRound(concealment, modifier, 100)

	unit.ABD_concealment = concealment

	if unit.ABD_concealment > 0 then
		self:SetStatusEffectWithStacks(unit, "ABD_Concealed", DivRound(unit.ABD_concealment, 20))
	else
		unit:RemoveStatusEffect("ABD_Concealed")
	end
end

function ABD_Camo:UpdateAllConcealment()
	local units = g_Units

	for i, v in ipairs(units) do
		self:UpdateConcealment(v)
	end
end

function ABD_Camo:GetCamoValue(unit)
	-- at the moment only 0 or 1
	local armor = unit:GetItemInSlot("Torso", "Armor")

	return armor and armor.Camouflage and 1 or 0
end

function ABD_Camo:ModifySightRadiusModifier(_, target, value, observer, other, step_pos, darkness)
	if not other or not IsKindOf(other, "Unit") or target ~= observer or not other.ABD_concealment or other.ABD_concealment <= 0 then
		return value
	end

	local concealmentModifier = MulDivRound(other.ABD_concealment, self.concealmentToSightRadiusModifier, 100)

	return Max(0, value - concealmentModifier)
end
