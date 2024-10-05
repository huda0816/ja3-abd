UndefineClass('ABD_Filters')
DefineClass.ABD_Filters = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	unit_reactions = {
		PlaceObj('UnitReaction', {
			Event = "OnCalcSightModifier",
			Handler = function (self, target, value, observer, other, step_pos, darkness)
				value =  ABD_Darkness:ModifySightRadiusModifier(self,target,value,observer,other,step_pos,darkness)
				value = ABD_Camo:ModifySightRadiusModifier(self,target,value,observer,other,step_pos,darkness)
				return value
			end,
		}),
	},
	Description = T(149413334248, --[[ModItemCharacterEffectCompositeDef ABD_Filters Description]] "Hidden Modifiers"),
	HideOnBadge = true,
}

