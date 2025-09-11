function OnMsg.Autorun()
	
	local OriginalPushUnitAlert = PushUnitAlert

	function PushUnitAlert(trigger_type, ...)
		if trigger_type == "noise" then
			local actor, radius, soundName, attacker = ...

			ABD_Dynamics:NoiseTresholdAlert(actor, radius, soundName, attacker)

			radius = ABD_Dynamics:AdjustGunshotRadius(actor, radius, soundName, attacker)

			return OriginalPushUnitAlert(trigger_type, actor, radius, soundName, attacker)
		end

		return OriginalPushUnitAlert(trigger_type, ...)
	end

	--- Moving units are easier to detect than stationary units.
	--- Units which are prone or crouched or in cover are harder to detect.

	local lSuspicionTickRate = 100        -- How often to add the tick amount
	local lSuspicionTickAmount = 14       -- The amount to add when hidden
	local lSuspicionTickAmountProjector = 6 -- The amount to add when hidden
	local lSuspicionTickAmountProne = 8   -- The amount to add when hidden and in prone
	local lSuspicionTickAmountNotHidden = 20 -- The amount to add when not hidden
	local lSuspicionTickDownAmount = 2    -- The amount to remove when no unit is in range
	local lSuspicionTickMinDist = const.SlabSizeX *
		2                                 -- If this close to an enemy then frontness doesn't matter (unless hidden or in the dark)
	local lSuspicionTickDistanceModOuter = const.SlabSizeX *
		4                                 -- Past this distance in the sight radius the distance modifier is 100%
	local lCubicInIndex = GetEasingIndex("Cubic in")

	-- MapVar("lastSusUpdate", 0)

	function UpdateSuspicion(alliedUnits, enemyUnits, intermediate_update)
		if GameTime() - lastSusUpdate < lSuspicionTickRate then return end
		--NetUpdateHash("UpdateSuspicion", alliedUnits, enemyUnits, intermediate_update)

		local sneakLights
		if intermediate_update then
			sneakLights = GetSneakProjectorLights()
		end

		local sector = gv_Sectors[gv_CurrentSectorId]
		local anySusUpdated = false
		local susIncreasedBy = {}
		for i, ally in ipairs(alliedUnits) do
			ally.suspicion = ally.suspicion or 0

			-- Performing an attack or something
			if not ally:IsIdleCommand() and not ally:IsInterruptable() then
				goto continue
			end
			if not IsValid(ally) or ally:IsDead() then goto continue end

			local allyDetectionModifier = 100
			if HasPerk(ally, "Untraceable") then
				allyDetectionModifier = allyDetectionModifier - Untraceable:ResolveValue("enemy_detection_reduction")
			end
			if ally:HasStatusEffect("Darkness") then
				allyDetectionModifier = allyDetectionModifier + const.EnvEffects.DarknessDetectionRate
			end

			allyDetectionModifier = Max(0, allyDetectionModifier)

			local raiseSusLargest = 0
			local raiseSusEnemy = false
			local max_sight_radius = MulDivRound(GetMaxSightRadius(), 1200, 1000)

			for i, enemy in ipairs(enemyUnits) do
				if enemy.retreating then goto continue end
				if enemy.command == "ExitCombat" then goto continue end
				if enemy:IsDead() then goto continue end

				local dist = enemy:GetDist(ally)

				if not IsCloser(enemy, ally, max_sight_radius) then
					goto continue
				end
				local seesAlly = HasVisibilityTo(enemy, ally)
				-- try to skip GetSightRadius calculations
				if not seesAlly then
					if raiseSusEnemy or not HasVisibilityTo(ally, enemy) then
						goto continue
					end
				end
				local sightRad, hidden, darkness = enemy:GetSightRadius(ally)

				local inRad = dist <= sightRad
				if inRad then
					if seesAlly then
						-- If in front of any enemy, add a bonus detection %
						-- If in the bsehind plane then have a smaller cut off.
						local angle_to_object = AngleDiff(CalcOrientation(enemy, ally), enemy:GetOrientationAngle())
						if abs(angle_to_object) > 90 * 60 and dist > lSuspicionTickMinDist / 2 then
							goto continue
						end

						-- The larger this is, the closer the ally is to the enemy
						local distFromSightRad = sightRad - dist

						-- Decrease sus the further away you are
						local distanceModifier = false
						if distFromSightRad < lSuspicionTickDistanceModOuter then
							distanceModifier = Lerp(10, 100, distFromSightRad, sightRad)
						else
							distanceModifier = 100
						end

						-- Modify the value based on how in front you are
						local frontnessModifier = false
						local maxDot = (4096 * 4096) * 2
						local dot = cos(angle_to_object) * 4096
						dot = EaseCoeff(lCubicInIndex, dot + 4096 * 4096, maxDot)
						frontnessModifier = Lerp(hidden and 30 or 40, 100, dot, maxDot)

						local closeInTheLight = false
						if hidden and not darkness and dist < lSuspicionTickMinDist and frontnessModifier > 60 then
							closeInTheLight = true
						end

						-- Get the base value based on a variety of factors
						local value = 0
						if hidden and not closeInTheLight then
							if ally.stance == "Prone" then
								value = lSuspicionTickAmountProne
							else
								value = lSuspicionTickAmount
							end
						else
							value = lSuspicionTickAmountNotHidden
						end

						-- Modify EnemyDetectionstats
						local enemyDetectionModifier = 100

						if enemy:HasStatusEffect("Suspicous") or enemy:HasStatusEffect("Surprised") or enemy:HasStatusEffect("HUDA_Alerted") then
							enemyDetectionModifier = enemyDetectionModifier + 20
						end

						value = MulDivRound(value, distanceModifier, 100)
						value = MulDivRound(value, frontnessModifier, 100)
						value = MulDivRound(value, enemyDetectionModifier, 100)
						value = MulDivRound(value, allyDetectionModifier, 100)

						if value > raiseSusLargest then
							raiseSusEnemy = enemy
							raiseSusLargest = value
						end
					end
				elseif not raiseSusEnemy and HasVisibilityTo(ally, enemy) then
					local extraRad = MulDivRound(sightRad, 1200, 1000)
					if dist <= extraRad then
						raiseSusEnemy = enemy
					end
				end

				::continue::
			end

			-- Mod option disable
			if sneakLights and IsMerc(ally) then
				local lightIndex = IsVoxelIlluminatedByObjects(ally:GetPos(), sneakLights)
				local val = lightIndex ~= 0 and lSuspicionTickAmountProjector or 0
				if val > raiseSusLargest then
					raiseSusLargest = val

					local light = sneakLights[lightIndex]
					local originalLight = light and light.original_light
					local projector = originalLight and originalLight:GetParent()
					if projector then
						raiseSusEnemy = projector
					end

					if ally.suspicion + raiseSusLargest >= SuspicionThreshold and ally:HasStatusEffect("Hidden") then
						ally:RemoveStatusEffect("Hidden")
						-- In this specific case we want this status effect to have a removal message.
						-- Copied from AddStatusEffect's floating text.
						CreateMapRealTimeThread(function()
							WaitPlayerControl()
							CreateFloatingText(ally, T { 488962074575, "- <DisplayName>", Hidden }, nil, nil, true)
						end)

						PushUnitAlert("projector", ally, enemyUnits, projector)
					end
				end
			end

			local oldSus = ally.suspicion
			if raiseSusLargest > 0 then
				ally.suspicion = ally.suspicion + raiseSusLargest
				susIncreasedBy[#susIncreasedBy + 1] = { unit = raiseSusEnemy, amount = raiseSusLargest, sees = ally }
			else
				ally.suspicion = ally.suspicion - lSuspicionTickDownAmount
				if raiseSusEnemy then
					susIncreasedBy[#susIncreasedBy + 1] = { unit = raiseSusEnemy, amount = -1, sees = ally }
				end
			end
			ally.suspicion = Clamp(ally.suspicion, 0, SuspicionThreshold)

			if ally.suspicion ~= oldSus and ally.ui_badge then
				local wasZeroNowIsnt = oldSus == 0 and ally.suspicion > 0
				local wasntZeroNowIs = oldSus > 0 and ally.suspicion == 0
				if wasZeroNowIsnt or wasntZeroNowIs then
					ally.ui_badge:UpdateActive()
					anySusUpdated = true
				end
			end

			if ally.suspicion >= SuspicionThreshold then
				if sector.warningStateEnabled and not sector.warningReceived then
					EnterWarningState(enemyUnits, alliedUnits, ally)
					anySusUpdated = true
					break
				else
					TriggerUnitAlert("discovered", ally)
					return
				end
			end

			::continue::
		end

		if anySusUpdated then
			local igi = GetInGameInterfaceModeDlg()
			if igi.crosshair then
				igi.crosshair:UpdateBadgeHiding()
			end
		end

		if not intermediate_update then
			lastSusUpdate = GameTime()
		end

		return susIncreasedBy
	end

	local ABD_Original_PropagateAwareness = PropagateAwareness

	function PropagateAwareness(alerted_units, roles, killed_units)
		ABD_Original_PropagateAwareness(alerted_units, roles, killed_units)
		ABD_Dynamics:PropagateAwareness(alerted_units, roles, killed_units)
	end
end
