function OnMsg.UnitMovementDone(unit)
	ABD_Flashlight:CheckMovementEnd(unit)
end

function OnMsg.UnitMovementStart(unit)
	unit:SetIK("AimIK")
end

function OnMsg.UnitSwappedWeapon(unit)
	ABD_Flashlight:ResetLightstatus(unit)
end

function OnMsg.OnCombatActionEnd(action, unit)
	if action == "ABD_FaceDirection" then
		ABD_Flashlight:CheckMovementEnd(unit)
	end
end

DefineClass.ABD_Flashlight = {
	flashLightRange = 16000,
	flashLightAngle = 10,
	lightTypes = {
		{
			type = "Flashlight",
			icon = "Mod/D55GHCb/icons/flashlight.png",
		},
		{
			type = "Dot",
			icon = "Mod/D55GHCb/icons/reddot.png",
		}
	}
}

function ABD_Flashlight:IsInFlashLightCone(unit)
	-- Performing an attack or something
	if not IsValid(unit) or not IsKindOf(unit, "Unit") or unit:IsDead() then
		return false
	end

	local units = g_Units
	local is = false

	for i, other in ipairs(units) do
		if other.retreating then goto continue end
		if other.command == "ExitCombat" then goto continue end
		if other:IsDead() then goto continue end

		local hasMod, turnedOn = self:HasLightMod(other, "Flashlight")

		if not hasMod or not turnedOn then
			goto continue
		end

		local dist = other:GetDist(unit)

		if dist > self.flashLightRange then
			goto continue
		end

		local seesUnit = HasVisibilityTo(other, unit)

		if not seesUnit then
			goto continue
		end

		local angle_to_object = AngleDiff(CalcOrientation(other, unit), other:GetOrientationAngle())

		if abs(angle_to_object) > self.flashLightAngle * 60 then
			goto continue
		end

		is = true
		break

		::continue::
	end

	return is
end

function ABD_Flashlight:AI_AddFlashlight(unit)
	local currentSlot = unit.current_weapon

	local items = unit:GetEquippedWeapons(currentSlot)

	for i, item in ipairs(items) do
		if item.components and item.components.Side and item.components.Side ~= "" then
			Inspect(item)
			return
		end

		local componentSlot = table.find_value(item.ComponentSlots, "SlotType", "Side")

		if not componentSlot then
			return
		end

		for i, component in ipairs(componentSlot.AvailableComponents) do
			if component == "Flashlight" then
				item:SetWeaponComponent("Side", "Flashlight")
				return
			end
		end
	end
end

function ABD_Flashlight:HasLightMod(unit, lightModType, weapons)
	local items = weapons or GetUnitWeapons(unit)

	lightModType = string.lower(lightModType or "Flashlight")

	for i, item in ipairs(items) do
		if item.components and item.components.Side then
			local lowerSide = string.lower(item.components.Side)
			if string.find(lowerSide, lightModType) then
				return true, unit.weapon_light_fx and true or false
			end
		end
	end

	return false
end

function ABD_Flashlight:PlayTurnOnFx(unit, weapon)
	local visual = weapon and weapon.visual_obj
	if not visual then return end

	local flashDot = false

	for slot, component_id in sorted_pairs(weapon.components) do
		if string.find(string.lower(component_id), "flashlight") and string.find(string.lower(component_id), "dot") then
			flashDot = true
		end

		local component = WeaponComponents[component_id]
		if component and component.EnableAimFX then
			local fx_actor
			for _, descr in ipairs(component and component.Visuals) do
				if descr:Match(weapon.class) then
					fx_actor = visual.parts[descr.Slot]
					if fx_actor then
						break
					end
				end
			end

			local action = "TurnOn"

			if flashDot then
				if unit:HasStatusEffect("ABD_FlashlightOn") then
					action = "TurnOnFl"
				elseif unit:HasStatusEffect("ABD_RedDotOn") then
					action = "TurnOnRd"
				end
			end

			fx_actor = fx_actor or visual
			PlayFX(action, "start", fx_actor)
			unit.weapon_light_fx = unit.weapon_light_fx or {}
			unit.weapon_light_fx[#unit.weapon_light_fx + 1] = fx_actor
		end
	end
end

function ABD_Flashlight:ToggleWeaponLight(unit, enable, type)
	if enable and not unit.combat_behavior then
		self:AimLight(unit)
	elseif not unit.combat_behavior then
		unit.aim_action_id = nil
		if unit:IsInterruptable() then
			unit:SetCommand("Idle")
		end
	end

	for _, fx_actor in ipairs(unit.weapon_light_fx) do
		PlayFX("TurnOn", "end", fx_actor)
	end
	unit.weapon_light_fx = false

	if enable and unit.visible and not unit:CanQuickPlayInCombat() then
		local weapon1, weapon2 = unit:GetActiveWeapons()
		self:PlayTurnOnFx(unit, weapon1)
		self:PlayTurnOnFx(unit, weapon2)
	end
end

function ABD_Flashlight:AimLight(unit)
	local weapon
	local aimIK = unit:CanAimIK(weapon)
	local stance = unit.stance
	unit:AttachActionWeapon(nil)
	local aim_anim = unit:GetAimAnim(nil, stance)
	unit:SetIK("LookAtIK", false)
	unit:SetFootPlant(true, nil, stance)
	local cur_anim = unit:GetStateText()
	unit.aim_action_id = "aim_flashlight"
	if cur_anim ~= aim_anim then
		unit:SetState(aim_anim, const.eKeepComponentTargets)
	end
	if aimIK then
		if not unit.aim_rotate_cooldown_time or GameTime() - unit.aim_rotate_cooldown_time >= 0 then
			unit:SetIK("AimIK")
		end
	else
		unit:SetIK("AimIK", false)
	end
end

function ABD_Flashlight:CheckMovementEnd(unit)
	if unit:HasStatusEffect("ABD_FlashlightOn") or unit:HasStatusEffect("ABD_RedDotOn") and not unit.combat_behavior then
		self:AimLight(unit)
	end
end

function ABD_Flashlight:ResetLightstatus(unit)
	if unit:HasStatusEffect("ABD_FlashlightOn") then
		unit:RemoveStatusEffect("ABD_FlashlightOn")
	end
	if unit:HasStatusEffect("ABD_RedDotOn") then
		unit:RemoveStatusEffect("ABD_RedDotOn")
	end
end

function ABD_Flashlight:HandleLightToggle(unit, type)
	local active = type == "Flashlight" and "ABD_FlashlightOn" or "ABD_RedDotOn"
	local alt = type == "Flashlight" and "ABD_RedDotOn" or "ABD_FlashlightOn"

	if unit:HasStatusEffect(active) then
		unit:RemoveStatusEffect(active)
	else
		if unit:HasStatusEffect(alt) then
			unit:RemoveStatusEffect(alt)
		end
		unit:AddStatusEffect(active)
	end
end

function ABD_Flashlight:SetDirection(unit, target)
	local orientation = CalcOrientation(unit, target)

	-- unit:SetAngle(orientation)

	if g_Combat then
		unit:AnimatedRotation(orientation)
		-- Sleep(50)
		-- self:CheckMovementEnd(unit)
	else
		CreateGameTimeThread(function()
			unit:AnimatedRotation(orientation)
			-- self:CheckMovementEnd(unit)
			-- Sleep(100)
		end)
	end

	SetInGameInterfaceMode(g_Combat and "IModeCombatMovement" or "IModeExploration")

	-- self:CheckMovementEnd(unit)
end

function ABD_GetAttackParams(weapon, attacker)
	local params = {
		attacker = attacker,
		weapon = weapon,
		used_ammo = 1,
		damage_mod = 100,
		attribute_bonus = 0,
		dont_destroy_covers = true
	}
	params.step_pos = attacker:GetPos()
	params.stance = attacker.stance
	params.cone_angle = 5 * 60
	if weapon.emplacement_weapon then
		params.min_distance_2d = 1
	end
	params.min_range = 1
	params.max_range = 1
	return params
end
