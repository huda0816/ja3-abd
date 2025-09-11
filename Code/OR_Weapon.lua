local ABD_Original_Firearm_GetOverwatchConeParam = Firearm.GetOverwatchConeParam


function Firearm:GetOverwatchConeParam(param)
	if param ~= "MaxRange" and param ~= "MinRange" and param ~= "Angle" then
		return ABD_Original_Firearm_GetOverwatchConeParam(self, param)
	end

	return IsKindOfClasses(self, "Shotgun", "MachineGun") and self.WeaponRange or MulDivRound(self.WeaponRange, 125, 100)
end

function CombatBadge:LayoutEnemy()
	local combat = self.combat
	self.idName:SetText(self.context.current_archetype)

	if combat then
		--self.idLeftText:SetVisible(true)
		self.idMercIcon:SetVisible(true)
		self:UpdateLevelIndicator()
		self.idNameStripe:SetBackground(GetColorWithAlpha(GameColors.Enemy, 205))
		
		self.idStatusEffectsContainer:SetVisible(true)
		
		local hpBar = self.idBar
		hpBar:SetVisible(true)
		hpBar:SetColorPreset("enemy")

		if self.unit.villain then
			hpBar:SetMinWidth(100)
			hpBar:SetMaxWidth(100)
		else
			hpBar:SetMinWidth(80)
			hpBar:SetMaxWidth(80)
		end

		self:SetTransp(127)
	elseif self.context:IsMarkedForStealthAttack() then
		self.idMercIcon:SetVisible(false)
		self:UpdateLevelIndicator()
		self.idNameStripe:SetBackground(GameColors["DarkB"])
		self.idStatusEffectsContainer:SetVisible(false)
		self.idBar:SetVisible(false)

		self:SetTransp(127)
	else
		self:LayoutNPC()
		self:SetTransp(0)
	end
	
	self:UpdateEnemyVisibility()
	self:UpdateActive()
end
