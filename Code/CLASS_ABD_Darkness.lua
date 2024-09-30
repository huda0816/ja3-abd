DefineClass.ABD_Darkness = {
	__parents = { "ABD" },
	lunarMonth = 2551442,
	newMoonUnix = 985388400,
	maxDarknessModifier = -70,
	undergroundDarknessModifier = -50,
	minDarknessModifier = 0, -- dusk/dawn
	moonMaxBrightness = 70,
	nightOpsPenaltyReduction = 20,
	nvgBaseModifier = 40,
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
				max = -1500000
			}
		}
	}
}

function ABD_Darkness:GetMoonPercent()
	local time = Game.CampaignTime
	local timeSinceNewMoon = time - self.newMoonUnix
	local percent = Max(1, MulDivRound(timeSinceNewMoon, 100, self.lunarMonth) % 100)
	return MulDivRound(Min(100, percent * 2), self.moonMaxBrightness, 100)
end

function ABD_Darkness:ModifySightRadiusModifier(_, target, value, observer, other, step_pos, darkness)
	-- TODO: There has to be a better way to do this
	if value < 100 then
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

	if HasPerk(observer, "NightOps") then
		penaltyReduce = self.nightOpsPenaltyReduction
	end

	local nvgs = observer:GetItemInSlot("NVG") or observer:GetItemInSlot("Helmet")

	if IsKindOf(nvgs, "NightVisionGoggles") and nvgs.Condition > 0 then
		penaltyReduce = penaltyReduce / 2 + (nvgs.NightVision or self.nvgBaseModifier)
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

function ABD_Darkness:StoreAndApply()
	self:SetGameVar(self.nightvisionActiveStorageKey, nil)

	if not CurrentLightmodel or not CurrentLightmodel[1] or not CurrentLightmodel[1].night then
		return self:ClearGameVar(self.originalStorageKey)
	end

	self:SetGameVar(self.originalStorageKey,
		{
			keyBias = CurrentLightmodel[1].ae_key_bias,
			gamma = CurrentLightmodel[1].gamma,
			grading_lut =
				CurrentLightmodel[1].grading_lut
		})

	self:ApplyLightmodel()
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
				grading_lut = lightModel.grading_lut
			})
	end

	if not nonvcheck and self:CheckNightvisionSwitch(SelectedObj) then
		self:SwitchToNightvision()
		return
	end

	local keyBias
	local gamma

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
	else
		local lightness = self:GetLightness()

		keyBias = MulDivRound(maxKeyBias - minKeyBias, Max(0, 100 - lightness), 100) + minKeyBias
		gamma = MulDivRound(gammaMax - gammaMin, Max(0, 100 - lightness), 100) + gammaMin
	end

	if keyBias ~= lightModel.ae_key_bias or gamma ~= lightModel.gamma or gradingLut ~= lightModel.grading_lut then
		lightModel.ae_key_bias = keyBias
		lightModel.gamma = gamma
		if gradingLut then
			lightModel.grading_lut = gradingLut
		end
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

	local nvgs = unit:GetItemInSlot("NVG") or unit:GetItemInSlot("Helmet")

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

	local lightness = self:GetMoonPercent()

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

		lightness = Max(lightness, dustdawnPercent)
	end

	self:SetGameVar("darkness.lightness", lightness)

	return lightness
end
