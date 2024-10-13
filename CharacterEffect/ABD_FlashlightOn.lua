UndefineClass('ABD_FlashlightOn')
DefineClass.ABD_FlashlightOn = {
	__parents = { "CharacterEffect" },
	__generated_by_class = "ModItemCharacterEffectCompositeDef",


	object_class = "CharacterEffect",
	OnAdded = function (self, obj)
		ABD_Flashlight:ToggleWeaponLight(obj,true)
	end,
	OnRemoved = function (self, obj)
		ABD_Flashlight:ToggleWeaponLight(obj,false)
	end,
	HideOnBadge = true,
}

