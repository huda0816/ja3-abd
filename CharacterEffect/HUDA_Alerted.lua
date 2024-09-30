UndefineClass('HUDA_Alerted')
DefineClass.HUDA_Alerted = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	Conditions = {
		PlaceObj('CheckExpression', {
			Expression = function (self, obj) return not obj.team or not obj.team.neutral end,
		}),
	},
	DisplayName = T(967146229973, --[[ModItemCharacterEffectCompositeDef HUDA_Alerted DisplayName]] "Alerted"),
	Description = T(671161358848, --[[ModItemCharacterEffectCompositeDef HUDA_Alerted Description]] "This character is alerted and shoots on sight"),
	OnAdded = function (self, obj)
		--obj:AddStatusEffectImmunity("Unaware", "alerted")
		--obj:AddStatusEffectImmunity("Surprised", "alerted")
		--obj:AddStatusEffectImmunity("Suspicious", "alerted")
		--obj.pending_aware_state = "aware"
		Msg("UnitAwarenessChanged", obj)
	end,
	OnRemoved = function (self, obj)  end,
	Icon = "UI/Hud/Status effects/suspicious",
	Shown = true,
}

