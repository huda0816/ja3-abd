function OnMsg.TurnStart(team)
	ABD_Dynamics:AlertaAlerta(team)
end

function OnMsg.ConflictEnd(sector, bNoVoice, playerAttacking, playerWon, isAutoResolve, isRetreat, fromMap)
	ABD_Dynamics:StrategicRetreat(sector, playerWon)
end

function OnMsg.SquadFinishedTraveling(squad)
	ABD_Dynamics:FinishedRetreating(squad)
end

function OnMsg.TurnStart(team)
	ABD_Dynamics:CheckForSoftdespawn(team)
end

function OnMsg.TurnStart(team)
	if g_Combat and not g_Combat.exitZone then
		ABD_Dynamics:SetExitAndRetreatZone()
	end
end

function OnMsg.CombatStart()
	ABD_Dynamics:SetExitAndRetreatZone()
end

function OnMsg.ClosePDA()
	ABD_Dynamics:AlertAfterRetreat()
end

AppendClass.SatelliteSector = {
	properties = {
		{
			id = "ABD_retreating_units",
			name = "Retreating Units",
			editor = "table",
			default = {},
		},
		{
			id = "ABD_Alerted",
			name = "Alerted",
			editor = "bool",
			default = false,
		}
	}
}

AppendClass.Combat = {
	properties = {
		{
			id = "exitZone",
			name = "Exit Zone",
			editor = "preset_id",
			preset_class = "Interactable",
			default = false,
		},
		{
			id = "retreatSector",
			name = "Retreat Sector",
			editor = "text",
			default = ""
		}
	}
}

MapVar("mv_ABD_NoiseLevel", 0)

DefineClass.ABD_Dynamics = {
	__parents = { "ABD" },
	comRange = {
		Adonis = 1000,
		Legion = 30,
		Army = 1000,
		Beast = 40,
		Thugs = 30,
		SuperSoldiers = 1000,
		Rebels = 30
	},
	leaderModifier = 50,
	defaultComRange = 20,
	battleNoiseMinTreshold = 300,
	firingModeMultiplier = {
		BurstFire = 200,
		SingleShot = 100,
		AutoFire = 300
	},
	noiseNames = {
		"a gunshot",
		"a grenade"
	},
	retreatSectorBlacklist = {
		"I1",
		"H3",
		"I3"
	}
}

function ABD_Dynamics:GetComRange(unit)
	local affiliation = unit.Affiliation

	local comRange = self.comRange[affiliation] or self.defaultComRange

	local modifier = 100

	if unit.role == "Commander" then
		modifier = modifier + self.leaderModifier
	end

	return MulDivRound(comRange, modifier, 100)
end

--Alert everyone in sight range always
--If reporter ir alive report everyone in comRange
--If alerted unit gets a trait which will itself help propagate the awareness to other units
--If a commander gets alerted he can:
--Send units to a battle, order a retreat, call for reinforcements, call in artillery support
--if the commander is killed units will decide for their own

function ABD_Dynamics:PropagateAwareness(alerted_units, roles, killed_units)
	for _, unit in ipairs(alerted_units) do
		unit:AddStatusEffect("ABD_Alerted")
	end
end

function ABD_Dynamics:AlertaAlerta(team)
	local combatTeam = g_Teams[team]

	if not combatTeam then return end

	if combatTeam.side ~= "enemy1" or combatTeam.side ~= "enemy2" then return end

	local alertedUnits = {}

	for i, unit in ipairs(combatTeam.units) do
		if unit:IsDead() then goto continue end
		if not unit:HasStatusEffect("ABD_Alerted") then goto continue end

		table.insert(alertedUnits, unit)

		::continue::
	end

	for i, unit in ipairs(alertedUnits) do
		if not unit:IsDead() then
			local units = GetAllAlliedUnits(unit)
			local leaderShip = unit.Leadership

			for i, other in ipairs(units) do
				if self:IsPlayerControlled(other) then goto continue end
				if other:HasStatusEffect("ABD_Alerted") then goto continue end
				if other.retreating then goto continue end
				if other.command == "ExitCombat" then goto continue end
				if other:IsDead() then goto continue end

				local dist = other:GetDist(unit)

				local seesUnit = HasVisibilityTo(other, unit)

				if dist > self:GetComRange(unit) and not seesUnit then
					goto continue
				end

				local randRole = InteractionRand(100, 'alertroll')

				if randRole <= Max(leaderShip, 50) or seesUnit then
					other:AddStatusEffect("ABD_Alerted")
				end

				::continue::
			end
		end
	end
end

--the unit will register the noise up to double the normal range of the sound if its gunshots or explosions the more shots or explosions the higher the chance of being allerted

function ABD_Dynamics:AdjustGunshotRadius(actor, radius, soundName, attacker)
	local noiseName = TDevModeGetEnglishText(soundName)

	if table.find(self.noiseNames, noiseName) then
		radius = MulDivRound(radius, 150, 100)
	end

	return radius
end

-- if there is too much noise even outside of the range of the weapons units will be alerted

function ABD_Dynamics:NoiseTresholdAlert(actor, radius, soundName, attacker)
	local noiseName = TDevModeGetEnglishText(soundName)

	if table.find(self.noiseNames, noiseName) then
		mv_ABD_NoiseLevel = mv_ABD_NoiseLevel or 0

		local multiplier = IsKindOf(actor, "Unit") and self.firingModeMultiplier[actor.performed_action_this_turn] or 100

		mv_ABD_NoiseLevel = mv_ABD_NoiseLevel + MulDivRound(radius, multiplier, 100)

		if mv_ABD_NoiseLevel > self.battleNoiseMinTreshold then
			-- there is still a chance that the unit will not be alerted

			local units = g_Units

			for i, unit in ipairs(units) do
				if self:IsPlayerControlled(unit) then goto continue end
				if unit:HasStatusEffect("ABD_Alerted") then goto continue end
				if unit.retreating then goto continue end
				if unit.command == "ExitCombat" then goto continue end
				if unit:IsDead() then goto continue end

				local randRole = InteractionRand(100, 'alertroll')

				if randRole <= Max(unit.Wisdom, 50) then
					self:Print("Alerta Alerta", unit.session_id)
					unit:AddStatusEffect("ABD_Alerted")
				end

				::continue::
			end
		end
	end
end

function ABD_Dynamics:StrategicRetreat(sector, playerWon)
	if not playerWon then
		sector.ABD_retreating_units = {}
		return
	end

	local retreatSectorId

	if g_Combat and g_Combat.retreatSector then
		retreatSectorId = g_Combat.retreatSector
	else
		_, retreatSectorId = self:GetBestRetreatSectorBySide("enemy1")
	end

	local retreatingSquads = {}

	local enemySquads = sector.enemy_squads

	for i, squad in ipairs(enemySquads) do
		local notRetreatingUnits = table.ifilter(gv_UnitData, function(k, v)
			return v.Squad == squad.UniqueId and sector.ABD_retreating_units and
				not table.find(sector.ABD_retreating_units, v.session_id)
		end)

		if #notRetreatingUnits == 0 then
			table.insert(retreatingSquads, squad.UniqueId)
			RemoveSquadFromSectorList(squad, squad.CurrentSector)
		end
	end

	local retreatSector = gv_Sectors[retreatSectorId]

	for i, retreatingUnitId in ipairs(sector.ABD_retreating_units or {}) do
		local unit = gv_UnitData[retreatingUnitId]
		if unit then
			unit.current_archetype = nil
		end
	end

	sector.ABD_retreating_units = {}

	if #retreatingSquads > 0 then
		self:MoveSquads(retreatingSquads, retreatSector.City, "retreat", sector.Id, retreatSectorId)
	end
end

function ABD_Dynamics:FinishedRetreating(squad)
	if not squad.Retreating then
		return
	end

	squad.Retreating = false

	local current_sector = gv_Sectors[squad.CurrentSector]

	current_sector.ABD_Alerted = true
end

function ABD_Dynamics:CheckForSoftdespawn(team)
	local team = g_Teams and g_Teams[team]

	if not team or team.side ~= "enemy1" then
		return
	end

	local exitZone, sectorId

	if g_Combat and g_Combat.exitZone and g_Combat.retreatSector then
		exitZone = g_Combat.exitZone
		sectorId = g_Combat.retreatSector
	else
		local direction

		direction, sectorId = self:GetBestRetreatSectorBySide("enemy1")

		if not direction or not sectorId then
			return
		end

		exitZone = self:GetBestExitZoneInteractable(direction)
	end

	for index, unit in ipairs(team.units) do
		if not unit.current_archetype or unit.current_archetype ~= "StrategicRetreat" or unit:IsDead() or unit.retreating then
			goto continue
		end

		local distance = unit:GetDist(exitZone)

		if distance < 15 * const.SlabSizeX then
			self:SoftdespawnUnit(unit)
		end

		::continue::
	end
end

function ABD_Dynamics:SoftdespawnUnit(unit)
	unit:AutoRemoveCombatEffects()
	unit:InterruptPreparedAttack()
	unit:RemoveEnemyPindown()

	--remove crosshair on despawned unit
	local dlg = GetInGameInterfaceModeDlg()
	local crosshair = dlg and dlg.crosshair
	if crosshair and crosshair.context.target == unit then
		dlg:RemoveCrosshair("Despawn")
		if g_Combat then
			if g_Combat:ShouldEndCombat() then
				g_Combat:EndCombatCheck(true)
			else
				SetInGameInterfaceMode("IModeCombatMovement")
			end
		else
			SetInGameInterfaceMode("IModeExploration", { suppress_camera_init = true })
		end
	end

	if not unit:IsAmbientUnit() then unit:SyncWithSession("map") end

	local sectorId = gv_CurrentSectorId

	self:Print("Softdespawn unit", unit.session_id, "to sector", sectorId)

	local sector = gv_Sectors[sectorId]

	sector.ABD_retreating_units = sector.ABD_retreating_units or {}

	table.insert(sector.ABD_retreating_units, unit.session_id)

	--unit:RemoveAllStatusEffects()
	if SelectedObj == unit then
		SelectObj()
	end
	local cameraFollowTarget = cameraTac.GetFollowTarget()
	if cameraFollowTarget == unit then
		cameraTac.SetFollowTarget(false)
	end

	unit.current_archetype = nil

	DoneObject(unit)

	local squad = gv_Squads[unit.Squad]

	if squad then
		squad.Retreat = true
	end

	if g_Combat and not g_AIExecutionController then
		g_Combat:EndCombatCheck("force")
	end
end

function ABD_Dynamics:SetExitAndRetreatZone()
	local combat = g_Combat

	if not combat then
		return
	end

	local direction, sectorId = self:GetBestRetreatSectorBySide("enemy1")

	local exitZone = self:GetBestExitZoneInteractable(direction)

	g_Combat.exitZone = exitZone

	g_Combat.retreatSector = sectorId
end

function ABD_Dynamics:GetBestRetreatSector(unit)
	local sector = self:GetUnitSector(unit)
	if not sector then return nil end
	local sector_id = sector.Id
	local side = unit.team.side

	return self:GetBestRetreatSectorBySide(side)
end

function ABD_Dynamics:GetBestRetreatSectorBySide(side)
	local sectorId = gv_CurrentSectorId
	local affiliation = self:GetSectorAffiliation(sectorId)

	local currentSector = gv_Sectors[sectorId]

	local cardinalSectors = self:GetCardinalSectors(sectorId, side)

	local bestSector
	local bestSectorId
	local sectorScores = {}

	for direction, cardinal_sector_id in pairs(cardinalSectors) do
		local sector = gv_Sectors[cardinal_sector_id]

		self:Print(cardinal_sector_id, sector.Side, side, affiliation, self:GetSectorAffiliation(sector))

		if not sector or sector.Side ~= side or affiliation ~= self:GetSectorAffiliation(sector) then
			goto continue
		end

		local score = 0

		if table.find(self.retreatSectorBlacklist, cardinal_sector_id) then
			local closestBase = self:GetClosestBase(sectorId, affiliation, nil, nil)
			if closestBase then
				sectorScores[direction] = 10
			end
			goto continue
		end

		if sector.City == currentSector.City then
			score = score + 50
		end

		if not sector.ally_and_militia_squads or #sector.ally_and_militia_squads == 0 then
			score = score + 25
		end

		sectorScores[direction] = score

		::continue::
	end

	if next(sectorScores) then
		for direction, score in pairs(sectorScores) do
			if not bestSector or score > sectorScores[bestSector] then
				bestSector = direction
				bestSectorId = cardinalSectors[direction]
			end
		end
	end
	if not next(sectorScores) then
		local closestBase = self:GetClosestBase(sectorId, affiliation, nil, nil)
		if closestBase then
			local distances = {}

			for direction, cardinal_sector_id in pairs(cardinalSectors) do
				distances[direction] = GetSectorDistance(closestBase.Id, cardinal_sector_id)
			end

			for direction, distance in pairs(distances) do
				if not bestSector or distance < distances[bestSector] then
					bestSector = direction
					bestSectorId = closestBase.Id
				end
			end
		end
	end

	return bestSector, bestSectorId
end

function ABD_Dynamics:AlertAfterRetreat()
	local currentSectorId = gv_CurrentSectorId
	local currentSector = gv_Sectors[currentSectorId]

	if not currentSector then
		return
	end

	if not currentSector.ABD_Alerted then
		return
	end

	local units = g_Units

	for i, unit in ipairs(units) do
		if unit.CurrentSide == "enemy1" and not self:IsPlayerControlled(unit) and not unit.retreating and not unit:IsDead() then
			unit:AddStatusEffect("ABD_Alerted")
		end
	end
end
