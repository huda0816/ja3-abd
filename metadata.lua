return PlaceObj('ModDef', {
	'title', "Altered Battle Dynamics",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "JA3_CommonLib",
			'title', "JA3_CommonLib",
			'version_major', 1,
			'version_minor', 1,
		}),
	},
	'id', "D55GHCb",
	'author', "permanent666",
	'version', 1368,
	'lua_revision', 233360,
	'saved_with_revision', 350233,
	'code', {
		"Code/BOOTSTRAP.lua",
		"CharacterEffect/ABD_Alerted.lua",
		"CharacterEffect/ABD_Filters.lua",
		"CharacterEffect/ABD_Concealed.lua",
		"Code/CLASS_ABD_Dynamics.lua",
		"Code/CLASS_ABD.lua",
		"Code/OR_Unit.lua",
		"InventoryItem/FlareAmmo.lua",
		"InventoryItem/FlareStick.lua",
		"Code/CLASS_ABD_Camo.lua",
		"Code/OR_UnitAwareness.lua",
		"Code/CLASS_ABD_Noise.lua",
		"Code/OR_Stealth.lua",
		"Code/OR_CombatAction.lua",
		"Code/OR_Weapon.lua",
		"Code/SETUP_Terrain.lua",
		"Code/OR_ClassDef-Zulu.lua",
		"Code/CLASS_ABD_AI.lua",
		"Code/OR_ClassDef-AI.lua",
		"Code/CLASS_ABD_Darkness.lua",
		"Code/OR_ActionFX.lua",
		"Code/OR_CombatAI.lua",
	},
	'default_options', {},
	'has_data', true,
	'saved', 1728342615,
	'code_hash', 7776361352468286783,
	'affected_resources', {
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "Skirmisher",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "StrategicRetreat",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "TacticalRetreat",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "SeekCover",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "Soldier",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "SpecialTurret",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "SpecialTurret_Sniper",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "CharacterEffectCompositeDef",
			'Id', "ABD_Alerted",
			'ClassDisplayName', "Character effect",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "CharacterEffectCompositeDef",
			'Id', "ABD_Filters",
			'ClassDisplayName', "Character effect",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ConstDef",
			'Id', "SightModHiddenProne",
			'ClassDisplayName', "Constant",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ConstDef",
			'Id', "SightModStealthStatDiff",
			'ClassDisplayName', "Constant",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "CharacterEffectCompositeDef",
			'Id', "ABD_Concealed",
			'ClassDisplayName', "Character effect",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "InventoryItemCompositeDef",
			'Id', "FlareAmmo",
			'ClassDisplayName', "Inventory item",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "InventoryItemCompositeDef",
			'Id', "FlareStick",
			'ClassDisplayName', "Inventory item",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ConstDef",
			'Id', "CamoSightPenalty",
			'ClassDisplayName', "Constant",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ConstDef",
			'Id', "UnawareSightRange",
			'ClassDisplayName', "Constant",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ConstDef",
			'Id', "DarknessSightMod",
			'ClassDisplayName', "Constant",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ConstDef",
			'Id', "SightModMinValue",
			'ClassDisplayName', "Constant",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ActionFXLight",
			'Id', "6346654985964621069",
			'ClassDisplayName', "ActionFX Light",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ActionFXLight",
			'Id', "3259676871936435544",
			'ClassDisplayName', "ActionFX Light",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ActionFXLight",
			'Id', "ZZs1MYjR",
			'ClassDisplayName', "ActionFX Light",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "AIArchetype",
			'Id', "Illuminator",
			'ClassDisplayName', "AI Archetype",
		}),
		PlaceObj('ModResourcePreset', {
			'Class', "ParticleSystemPreset",
			'Id', "Wpn_Flashlight_LightCone",
			'ClassDisplayName', "Particle system",
		}),
	},
})