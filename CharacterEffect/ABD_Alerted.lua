UndefineClass('ABD_Alerted')
DefineClass.ABD_Alerted = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	Conditions = {
		PlaceObj('CheckExpression', {
			Expression = function (self, obj) return not obj.team or not obj.team.neutral end,
		}),
	},
	DisplayName = T(672319676530, --[[ModItemCharacterEffectCompositeDef ABD_Alerted DisplayName]] "Alerted"),
	Description = T(101697038965, --[[ModItemCharacterEffectCompositeDef ABD_Alerted Description]] "This character is alerted and shoots on sight"),
	OnAdded = function (self, obj)  end,
	OnRemoved = function (self, obj)  end,
	Icon = "Mod/D55GHCb/icons/alerted.png",
	Shown = true,
}

