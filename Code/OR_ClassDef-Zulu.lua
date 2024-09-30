function UnitProperties:SelectArchetype(proto_context)
	local archetype
	local func = empty_func

	if IsKindOf(self, "Unit") then
		local emplacement = g_Combat and g_Combat:GetEmplacementAssignment(self)
		if self.retreating then
			archetype = "Deserter"
		elseif self:HasStatusEffect("Panicked") then
			archetype = "Panicked"
		elseif self:HasStatusEffect("Berserk") then
			archetype = "Berserk"
		elseif emplacement then
			assert(self.CanManEmplacements)
			archetype = "EmplacementGunner"
			proto_context.target_interactable = emplacement
		elseif self.command == "Reposition" and self.RepositionArchetype then
			archetype = self.RepositionArchetype
		end

		-- check for scout archetype first
		local can_scout = not archetype
		can_scout = can_scout and (not g_Encounter or g_Encounter:CanScout())
		can_scout = can_scout and self.script_archetype ~= "GuardArea"
		if can_scout then
			local enemies = self:GetVisibleEnemies()
			if #enemies == 0 then
				self.last_known_enemy_pos = self.last_known_enemy_pos or AIPickScoutLocation(self)
				if self.last_known_enemy_pos then
					archetype = "Scout_LastLocation"
				end
			end
		end

		if not archetype then
			for _, descr in pairs(g_Pindown) do
				if descr.target == self then
					if self:Random(100) < self.PinnedDownChance then
						archetype = "PinnedDown"
					end
					break
				end
			end
		end
		local template = UnitDataDefs[self.unitdatadef_id]
		func = template and template.PickCustomArchetype or self.PickCustomArchetype
	end

	-- archetype = "TacticalRetreat"

	if not ABD:IsPlayerControlled(self) and not archetype or archetype == "Scout_LastLocation" then
		local cacheTable = GetTargetsAndMore(self)

		local closestDistToUncoveredEnemy = nil

		for i, dist in ipairs(cacheTable.distances) do
			if (not closestDistToUncoveredEnemy or dist < closestDistToUncoveredEnemy) and cacheTable.covers[i] < 50 then
				closestDistToUncoveredEnemy = dist
			end
		end

		if g_Combat and g_Combat.current_turn == 1 and (not closestDistToUncoveredEnemy or closestDistToUncoveredEnemy > 4 * const.SlabSizeX) then
			archetype = "SeekCover"
		end

		-- archetype = "Scout_LastLocation" == archetype and "SeekCover" or archetype

		if not archetype then
			if self.archetype ~= "Brute" and self.archetype ~= "Medic" then
				
				if cacheTable.anyGoodAttack and cacheTable.hasGoodCover
					and not self:IsUnderBombard()
					and not self:IsUnderTimedTrap()
					and not self:IsThreatened(nil, "pindown")
					and not self:HasStatusEffect("Burning")
					and not self:HasStatusEffect("Choking")
				then
					if self.AIKeywords and table.find(self.AIKeywords, "Sniper") then
						archetype = "SpecialTurret_Sniper"
					else
						archetype = "SpecialTurret"
					end
				end

				if cacheTable.anyGoodAttack and not cacheTable.hasGoodCover and (not closestDistToUncoveredEnemy or closestDistToUncoveredEnemy > 4 * const.SlabSizeX) then
					archetype = "SeekCover"
				end
			end
		end
	end

	print("Archetype", archetype)

	self.current_archetype = archetype or func(self, proto_context) or self.archetype or "Assault"
end