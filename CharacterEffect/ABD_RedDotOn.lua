UndefineClass('ABD_RedDotOn')
DefineClass.ABD_RedDotOn = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	OnAdded = function (self, obj)
		ABD_Flashlight:ToggleWeaponLight(obj,true, "Dot")
	end,
	OnRemoved = function (self, obj)
		ABD_Flashlight:ToggleWeaponLight(obj,false, "Dot")
	end,
	HideOnBadge = true,
}

