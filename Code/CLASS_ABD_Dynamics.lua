function OnMsg.TurnStart(team)
	ABD_Dynamics:AlertaAlerta(team)
end

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
					-- print("Alerta Alerta", other.session_id)
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

		-- print("Noise Level", mv_ABD_NoiseLevel)

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
					-- print("Alerta Alerta", unit.session_id)
					unit:AddStatusEffect("ABD_Alerted")
				end

				::continue::
			end
		end
	end
end

-- Strategic retreat:
-- If there are max 3 units left and they are outnumbered there is a chance they will retreat
-- Which factors will contribute: Wounded, Ratio between enemy and friendly units friendly sector to retreat to
