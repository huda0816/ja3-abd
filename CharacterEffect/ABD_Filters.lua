UndefineClass('ABD_Filters')
DefineClass.ABD_Filters = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	unit_reactions = {
		PlaceObj('UnitReaction', {
			Event = "OnCalcSightModifier",
			Handler = function (self, target, value, observer, other, step_pos, darkness)
				return ABD_Darkness:ModifySightRadiusModifier(self,target,value,observer,other,step_pos,darkness)
			end,
		}),
	},
	Description = T(541869531536, --[[ModItemCharacterEffectCompositeDef ABD_Filters Description]] "Hidden Modifiers"),
	HideOnBadge = true,
}

