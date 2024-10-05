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
	sightRadiusMovingModifier = -20,
	sightRadiusProneModifier = -20
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


end

-- Strategic retreat:
-- If there are max 3 units left and they are outnumbered there is a chance they will retreat
-- Which factors will contribute: Wounded, Ratio between enemy and friendly units friendly sector to retreat to