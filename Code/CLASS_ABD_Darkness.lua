-- TODOs:
-- Adding Nightops perk to legion
-- Adding Nightvision Goggles to Army and other units
-- Adding natural nightsight to animals
-- Random drops of NVGs

DefineClass.ABD_Darkness = {
	__parents = { "ABD" },
	lunarMonth = 2551442,
	newMoonUnix = 985388400,
	maxDarknessModifier = -90,
	undergroundDarknessModifier = -50,
	minDarknessModifier = 0, -- dusk/dawn
	moonMaxBrightness = 70,
	nightOpsPenaltyReduction = 20,
	nvgBaseModifier = 50,
	flashLightModifier = 40,
	dawnHour = 4,
	dustHour = 21,
	dustDawnLength = 1,
	originalStorageKey = "darkness.lightmodel.original",
	nightvisionStorageKey = "darkness.lightmodel.nightvision",
	nightvisionActiveStorageKey = "darkness.nightvision.active",
	lightModelMods = {
		nightVision = {
			grading_lut = "Nightvision",
			gamma = {
				min = 0,
				max = 4284041043
			},
			ae_key_bias = {
				min = 0,
				max = -1500000
			}
		},
		night = {
			gamma = {
				min = 4278190080,
				max = 4278190080
			},
			ae_key_bias = {
				min = 0,
				max = -2000000
			}
		}
	},
	affiliationCapabilities = {
		Army = {
			hasNVG = true,
			hasNightOps = false
		},
		Legion = {
			hasNVG = false,
			hasNightOps = true
		}
	},
	weatherMoonEffectivenessFactor = {
		DustStorm = 50,
		Fog = 80,
		RainHeavy = 0,
		RainLight = 0,
	},
	weatherDustDawnModifier = {
		DustStorm = 20,
		Fog = 10,
		RainHeavy = 30,
		RainLight = 20,
	},
}

function ABD_Darkness:GetMoonEffectiveness(weather)
	local time = Game.CampaignTime
	local timeSinceNewMoon = time - self.newMoonUnix
	local percent = Max(1, MulDivRound(timeSinceNewMoon, 100, self.lunarMonth) % 100)

	-- percent has to be multiplied by 2 as it only takes half of the month to go from new moon to full moon
	percent = MulDivRound(Min(100, percent * 2), self.moonMaxBrightness, 100)

	local modifier = self.weatherMoonEffectivenessFactor[weather] or 100

	percent = MulDivRound(percent, modifier, 100)

	return percent
end

function ABD_Darkness:ModifySightRadiusModifier(_, target, value, observer, other, step_pos, darkness)
	if target ~= observer then
		return value
	end

	local nightTime = GameState.Night

	local underGround = GameState.Underground

	if not nightTime and not underGround then
		return value
	end

	local isIlluminated = IsIlluminated(other, nil, nil, step_pos)

	if isIlluminated then
		return value
	end

	local penaltyReduce = 0

	local hasNightOps = HasPerk(observer, "NightOps") or
		self.affiliationCapabilities[observer.Affiliation] and self.affiliationCapabilities[observer.Affiliation]
		.hasNightOps

	if hasNightOps then
		penaltyReduce = self.nightOpsPenaltyReduction
	end

	if self:HasNvgs(observer) then
		penaltyReduce = penaltyReduce / 2 + (nvgs and nvgs.NightVision or self.nvgBaseModifier)
	elseif self:HasFlashlight(observer) then
		penaltyReduce = penaltyReduce / 2 + self.flashLightModifier
	end

	if underGround then
		return value + MulDivRound(self.undergroundDarknessModifier, Max(0, 100 - penaltyReduce), 100)
	end

	local lightness = self:GetLightness()

	local effectiveDarkness = MulDivRound(self.maxDarknessModifier - self.minDarknessModifier, Max(0, 100 - lightness),
		100) + self.minDarknessModifier

	local finalModifier = Max(0, value + MulDivRound(effectiveDarkness, Max(0, 100 - penaltyReduce), 100))

	return finalModifier
end

function ABD_Darkness:HasNvgs(unit)
	local nvgs = unit:GetItemInSlot("NVG") or unit:GetItemInSlot("Head")

	return nvgs and IsKindOf(nvgs, "NightVisionGoggles") and nvgs.Condition > 0 or
		self.affiliationCapabilities[unit.Affiliation] and self.affiliationCapabilities[unit.Affiliation].hasNVG
end

function ABD_Darkness:HasFlashlight(unit)
	local items = unit:GetEquippedWeapons(unit.current_weapon)

	for i, item in ipairs(items) do
		if item.components and item.components.Side and item.components.Side == "Flashlight" then
			return true
		end
	end

	return false
end

function ABD_Darkness:ApplyLightmodel(nonvcheck)
	if not CurrentLightmodel or not CurrentLightmodel[1] or not CurrentLightmodel[1].night then
		return
	end

	local lightModel = CurrentLightmodel[1]

	local storedLightmodel = self:GetGameVar(self.originalStorageKey)

	if not storedLightmodel or storedLightmodel.id ~= CurrentLightmodel[1].id then
		self:SetGameVar(self.originalStorageKey,
			{
				id = lightModel.id,
				keyBias = lightModel.ae_key_bias,
				gamma = lightModel.gamma,
				grading_lut = lightModel.grading_lut,
				shadow = lightModel.shadow
			})
	end

	if not nonvcheck and self:CheckNightvisionSwitch(SelectedObj) then
		self:SwitchToNightvision()
		return
	end

	local keyBias
	local gamma
	local shadow

	local minKeyBias = self.lightModelMods.night.ae_key_bias.min
	local maxKeyBias = self.lightModelMods.night.ae_key_bias.max
	local gammaMin = self.lightModelMods.night.gamma.min
	local gammaMax = self.lightModelMods.night.gamma.max

	local nightTime = GameState.Night

	local underGround = GameState.Underground

	if not nightTime and not underGround then
		return
	end

	local gradingLut = storedLightmodel and storedLightmodel.grading_lut

	if underGround then
		keyBias = maxKeyBias
		gamma = gammaMax
		shadow = 0
	else
		local lightness = self:GetLightness()

		keyBias = MulDivRound(maxKeyBias - minKeyBias, Max(0, 100 - lightness), 100) + minKeyBias
		gamma = MulDivRound(gammaMax - gammaMin, Max(0, 100 - lightness), 100) + gammaMin

		if lightness <= 0 then
			shadow = 0
		end
	end

	if keyBias ~= lightModel.ae_key_bias or gamma ~= lightModel.gamma or gradingLut ~= lightModel.grading_lut or shadow ~= lightModel.shadow then
		lightModel.ae_key_bias = keyBias
		lightModel.gamma = gamma
		if gradingLut then
			lightModel.grading_lut = gradingLut
		end
		lightModel.shadow = shadow
		SetLightmodel(1, lightModel, 0)
	end
end

function ABD_Darkness:MaybeSwitchToNightvision(unit)
	if self:CheckNightvisionSwitch(unit) then
		self:SwitchToNightvision()
	else
		self:SwitchFromNightvision()
	end
end

function ABD_Darkness:CheckNightvisionSwitch(unit)
	if not unit then
		return
	end

	local nvgs = unit:GetItemInSlot("NVG") or unit:GetItemInSlot("Head")

	return IsKindOf(nvgs, "NightVisionGoggles") and nvgs.Condition > 0
end

function ABD_Darkness:SwitchToNightvision()
	if not CurrentLightmodel or not CurrentLightmodel[1] or not CurrentLightmodel[1].night then
		return
	end

	if CurrentLightmodel[1].grading_lut == self.lightModelMods.nightVision.grading_lut then
		return
	end

	local lightModel = CurrentLightmodel[1]

	lightModel.gamma = self.lightModelMods.nightVision.gamma.max

	lightModel.grading_lut = self.lightModelMods.nightVision.grading_lut

	lightModel.ae_key_bias = self.lightModelMods.nightVision.ae_key_bias.max

	SetLightmodel(1, lightModel, 0)
end

function ABD_Darkness:SwitchFromNightvision()
	if not CurrentLightmodel or not CurrentLightmodel[1] or not CurrentLightmodel[1].night then
		return
	end

	if CurrentLightmodel[1].grading_lut ~= self.lightModelMods.nightVision.grading_lut then
		return
	end

	self:ApplyLightmodel('nonvcheck')
end

function ABD_Darkness:ResetLightmodel()
	local storedLightmodel = self:GetGameVar(self.originalStorageKey)

	if storedLightmodel and CurrentLightmodel and CurrentLightmodel[1] then
		local lightModel = CurrentLightmodel[1]

		for k, v in pairs(storedLightmodel) do
			lightModel[k] = v
		end

		SetLightmodel(1, lightModel, 0)
	end
end

function ABD_Darkness:GetLightness()
	if self:GetGameVar("darkness.lightness") then
		return self:GetGameVar("darkness.lightness")
	end

	local weather = self:GetSectorWeather()

	local lightness = self:GetMoonEffectiveness(weather)

	local t = GetTimeAsTable(Game.CampaignTime)

	local isDustOrDawn

	if t.hour >= self.dawnHour and t.hour < self.dawnHour + self.dustDawnLength then
		isDustOrDawn = 'dawn'
	elseif t.hour >= self.dustHour and t.hour < self.dustHour + self.dustDawnLength then
		isDustOrDawn = 'dust'
	end

	if isDustOrDawn then
		local hours = abs(t.hour - (isDustOrDawn == 'dawn' and self.dawnHour or self.dustHour))

		local min = t.min + hours * 60

		local dustdawnPercent = MulDivRound(isDustOrDawn == 'dawn' and min or 60 - min, 100, self.dustDawnLength * 60)

		local weatherModifier = self.weatherDustDawnModifier[weather] or 100

		dustdawnPercent = MulDivRound(dustdawnPercent, weatherModifier, 100)

		dustdawnPercent = MulDivRound(dustdawnPercent,
			self.weatherMoonEffectivenessFactor[self:GetSectorWeather()] or 100, 100)


		lightness = Max(lightness, dustdawnPercent)
	end

	self:SetGameVar("darkness.lightness", lightness)

	return lightness
end

function ABD_Darkness:AI_Illumination(unit)
	local flareGun = self:PrepareAIFlareGun(unit)

	StartCombatAction("FireFlare", unit, 0, {
		free_aim = true,
		target = unit.last_known_enemy_pos
	})
end

function ABD_Darkness:PrepareAIFlareGun(unit)
	local prioSlots = {
		"Handheld A",
		"Handheld B"
	}

	local curWeaponSet = unit.current_weapon

	local flareGun

	for i, slot in ipairs(prioSlots) do
		local items = unit:GetEquippedWeapons(slot, "FlareHandgun")

		if #items > 0 then
			flareGun = items[1]

			flareGun.ammo = flareGun.ammo or PlaceInventoryItem("FlareAmmo")

			flareGun.ammo.Amount = 1

			if slot ~= curWeaponSet then
				unit:SwapActiveWeapon()
			end

			return flareGun
		end
	end

	if not flareGun then
		local items = unit:GetItems()

		for i, item in ipairs(items) do
			if IsKindOf(item, "FlareHandgun") then
				flareGun = item
				break
			end
		end
	end

	if not flareGun then
		flareGun = PlaceInventoryItem("FlareHandgun")
	end

	flareGun.ammo = flareGun.ammo or PlaceInventoryItem("FlareAmmo")

	flareGun.ammo.Amount = 1

	unit:RemoveItem(flareGun)

	local emptySlot

	for i, slot in ipairs(prioSlots) do
		if unit:FindEmptyPosition(slot, flareGun) then
			emptySlot = slot
			break
		end
	end

	if emptySlot then
		unit:AddItem(emptySlot, flareGun)

		if emptySlot ~= curWeaponSet then
			unit:SwapActiveWeapon()
		end

		return flareGun
	end

	--empty current slot for flaregun
	local itemToMove = unit:GetItemInSlot(curWeaponSet)

	if itemToMove then
		local pos, reason = unit:CanAddItem("Inventory", itemToMove)

		if pos then
			local x, y = point_unpack(pos)
			local result = MoveItem({
				item = itemToMove,
				src_container = unit,
				src_slot = curWeaponSet,
				dest_container =
					unit,
				dest_slot = "Inventory",
				dest_x = x,
				dest_y = y
			})
		else
			-- we can't add the item to the inventory, so we remove it
			unit:RemoveItem(itemToMove)
		end
	end

	unit:AddItem(curWeaponSet, flareGun, 1, 1)

	return flareGun
end

function ABD_Darkness:AI_AddFlashlight(unit)
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

function ABD_Darkness:IlluminateMap()
	local thread = CreateGameTimeThread(function(self)
		self:SetGameVar("darkness.lightning", true)

		Sleep(1000)

		self:SetGameVar("darkness.lightning", false)
	end, self)
end

function ABD_Darkness:TestLighting()
	local _, lookat = cameraTac.GetPosLookAt()
	local pos = Rotate(point(30 * guim, 0, 0), AsyncRand(60 * 360))
	pos = (lookat + pos):SetTerrainZ() + point(0, 0, 30 * guim)
	PlayFX("LightningStrike", "start", pos, pos, pos)
end