function UnitProperties:SelectArchetype(proto_context)
	local archetype
	local func = empty_func

	if self.current_archetype == "StrategicRetreat" then
		return
	end

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


		-- archetype = "Illuminator"

		-- archetype = "StrategicRetreat";

		if not ABD:IsPlayerControlled(self) and not archetype or archetype == "Scout_LastLocation" then
			local cacheTable = GetTargetsAndMore(self)

			if (HUDA_CheckStrategicRetreat(self)) then
				self.current_archetype = "StrategicRetreat"
				print("Archetype", self.session_id, self.current_archetype)
				return
			end

			if HUDA_CheckTacticalRetreat(self, cacheTable) then
				archetype = "TacticalRetreat"
			end

			if not archetype and g_Combat and g_Combat.current_turn == 1 and HUDA_CheckSeekCover(self, cacheTable, true) then
				archetype = "SeekCover"
			end

			-- archetype = "Scout_LastLocation" == archetype and "SeekCover" or archetype

			if not archetype then
				if self.archetype ~= "Brute" and self.archetype ~= "Medic" then
					if HUDA_CheckSpecialTurret(self, cacheTable) then
						if self.AIKeywords and table.find(self.AIKeywords, "Sniper") then
							archetype = "SpecialTurret_Sniper"
						else
							archetype = "SpecialTurret"
						end
					end

					if HUDA_CheckSeekCover(self, cacheTable) then
						archetype = "SeekCover"
					end
				end
			end
		end

		-- print("Archetype", archetype, self.archetype)

		self.current_archetype = archetype or func(self, proto_context) or self.archetype or "Assault"
	end
	print("Archetype", self.session_id, self.current_archetype)
end

function HUDA_GetWeaponRange(unit)
	local weapon, wep2 = unit:GetActiveWeapons()

	if IsKindOf(weapon, "MeleeWeapon") then
		local tiles = unit.body_type == "Large animal" and 2 or 1
		local range = (2 * tiles + 1) * const.SlabSizeX / 2
		return range
	elseif IsKindOf(weapon, "Firearm") then
		local max_range = weapon.WeaponRange * const.SlabSizeX
		return 15 * max_range / 10
	end
end
