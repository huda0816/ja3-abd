return {
	PlaceObj('ModItemCode', {
		'name', "BOOTSTRAP",
		'CodeFileName', "Code/BOOTSTRAP.lua",
	}),
	PlaceObj('ModItemAIArchetype', {
		BaseAttackTargeting = set( "Arms", "Legs", "Torso" ),
		BaseAttackWeight = 10,
		BaseMovementWeight = 10,
		Behaviors = {
			PlaceObj('StandardAI', {
				'Weight', 10,
				'OptLocWeight', 1000,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyDealDamage', nil),
					PlaceObj('AIPolicyTakeCover', {
						'visibility_mode', "team",
					}),
				},
				'TakeCoverChance', 50,
			}),
			PlaceObj('PositioningAI', {
				'BiasId', "Flanking",
				'Weight', 500,
				'Fallback', false,
				'RequiredKeywords', {
					"Flank",
				},
				'OptLocWeight', 1000,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyFlanking', {
						'Weight', 1000,
						'Required', true,
						'ReserveAttackAP', true,
					}),
					PlaceObj('AIPolicyDealDamage', nil),
				},
				'TakeCoverChance', 0,
				'VoiceResponse', "AIFlanking",
			}),
		},
		Comment = "Keywords: Flank, Explosives",
		OptLocPolicies = {
			PlaceObj('AIPolicyWeaponRange', {
				'Weight', 300,
				'Required', true,
				'RangeMin', 40,
				'RangeMax', 100,
			}),
			PlaceObj('AIPolicyWeaponRange', {
				'Weight', -5000,
				'RangeMin', 0,
				'RangeMax', 20,
			}),
			PlaceObj('AIPolicyLosToEnemy', {
				'Weight', 300,
				'Required', true,
			}),
		},
		OptLocSearchRadius = 80,
		PrefStance = "Crouch",
		SignatureActions = {
			PlaceObj('AIActionMobileShot', {
				'Priority', true,
				'NotificationText', "",
				'RequiredKeywords', {
					"RunAndGun",
				},
				'action_id', "RunAndGun",
			}),
			PlaceObj('AIActionMobileShot', {
				'Priority', true,
				'NotificationText', "",
				'RequiredKeywords', {
					"MobileShot",
				},
			}),
			PlaceObj('AIActionThrowGrenade', {
				'BiasId', "AssaultGrenadeThrow",
				'Weight', 200,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "AssaultGrenadeThrow",
						'Effect', "disable",
					}),
					PlaceObj('AIBiasModification', {
						'BiasId', "AssaultGrenadeThrow",
						'Value', -50,
						'Period', 0,
						'ApplyTo', "Team",
					}),
				},
				'RequiredKeywords', {
					"Explosives",
				},
				'AllowedAoeTypes', set( "fire", "none", "teargas", "toxicgas" ),
			}),
		},
		TargetScoreRandomization = 10,
		TargetingPolicies = {
			PlaceObj('AITargetingEnemyHealth', {
				'Health', 50,
			}),
			PlaceObj('AITargetingEnemyWeapon', {
				'EnemyWeapon', "Sniper",
			}),
		},
		group = "Default",
		id = "Skirmisher",
	}),
	PlaceObj('ModItemAIArchetype', {
		Behaviors = {
			PlaceObj('RetreatAI', {
				'EndTurnPolicies', {
					PlaceObj('AIPolicyTakeCover', {
						'Weight', 10,
					}),
					PlaceObj('AIPolicyLosToEnemy', {
						'Weight', 300,
						'Invert', true,
					}),
					PlaceObj('AIRetreatPolicy', {
						'Weight', 1000,
						'Required', false,
					}),
				},
				'TakeCoverChance', 0,
			}),
		},
		Comment = "retreat",
		OptLocPolicies = {
			PlaceObj('AIRetreatPolicy', nil),
		},
		OptLocSearchRadius = 80,
		group = "Simplified",
		id = "StrategicRetreat",
	}),
	PlaceObj('ModItemAIArchetype', {
		Behaviors = {
			PlaceObj('PositioningAI', {
				'EndTurnPolicies', {
					PlaceObj('AIPolicyLosToEnemy', {
						'Required', true,
						'Invert', true,
					}),
					PlaceObj('AIPolicyTakeCover', {
						'visibility_mode', "all",
					}),
					PlaceObj('AIPolicyDealDamage', nil),
				},
				'TakeCoverChance', 100,
			}),
			PlaceObj('PositioningAI', {
				'Weight', 1,
				'OptLocWeight', 0,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyTakeCover', {
						'visibility_mode', "all",
					}),
					PlaceObj('AIPolicyDealDamage', nil),
				},
				'TakeCoverChance', 100,
			}),
		},
		FallbackAction = "overwatch",
		OptLocPolicies = {
			PlaceObj('AIPolicyLosToEnemy', {
				'Required', true,
				'Invert', true,
			}),
			PlaceObj('AIPolicyTakeCover', {
				'visibility_mode', "all",
			}),
		},
		OptLocSearchRadius = 40,
		PrefStance = "Crouch",
		group = "Default",
		id = "TacticalRetreat",
	}),
	PlaceObj('ModItemAIArchetype', {
		Behaviors = {
			PlaceObj('PositioningAI', {
				'OptLocWeight', 1000,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyTakeCover', {
						'Weight', 1000,
						'Required', true,
						'visibility_mode', "team",
					}),
					PlaceObj('AIPolicyDealDamage', nil),
					PlaceObj('AIPolicyProximity', {
						'Weight', 500,
						'Required', true,
						'AllyPlannedPosition', true,
						'TargetUnits', "allies",
						'MinScore', 4,
					}),
					PlaceObj('AIPolicyWeaponRange', {
						'Required', true,
						'RangeMin', 40,
						'RangeMax', 100,
					}),
				},
				'TakeCoverChance', 100,
			}),
			PlaceObj('PositioningAI', {
				'Weight', 1,
				'OptLocWeight', 0,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyTakeCover', {
						'visibility_mode', "team",
					}),
				},
				'TakeCoverChance', 100,
			}),
		},
		OptLocPolicies = {
			PlaceObj('AIPolicyTakeCover', {
				'Required', true,
				'visibility_mode', "team",
			}),
			PlaceObj('AIPolicyLosToEnemy', {
				'Required', true,
			}),
			PlaceObj('AIPolicyWeaponRange', {
				'Required', true,
				'RangeMin', 40,
				'RangeMax', 100,
			}),
			PlaceObj('AIPolicyHighGround', {
				'RequiredKeywords', {
					"Sniper",
				},
				'Weight', 50,
			}),
			PlaceObj('AIPolicyWeaponRange', {
				'Weight', -5000,
				'RangeBase', "Absolute",
				'RangeMin', 0,
				'RangeMax', 4,
			}),
		},
		OptLocSearchRadius = 40,
		PrefStance = "Crouch",
		group = "Default",
		id = "SeekCover",
	}),
	PlaceObj('ModItemAIArchetype', {
		BaseAttackTargeting = set( "Torso" ),
		BaseMovementWeight = 10,
		Behaviors = {
			PlaceObj('StandardAI', {
				'BiasId', "Standard",
				'Weight', 150,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyTakeCover', {
						'Weight', 50,
						'visibility_mode', "team",
					}),
					PlaceObj('AIPolicyDealDamage', nil),
				},
				'TakeCoverChance', 50,
			}),
		},
		Comment = "Keywords: Soldier, Sniper, Control, Ordnance, Smoke, Explosives",
		MoveStance = "Crouch",
		OptLocPolicies = {
			PlaceObj('AIPolicyTakeCover', {
				'Weight', 200,
				'visibility_mode', "team",
			}),
			PlaceObj('AIPolicyHighGround', {
				'RequiredKeywords', {
					"Sniper",
				},
			}),
			PlaceObj('AIPolicyWeaponRange', {
				'Weight', 200,
				'RangeMin', 50,
				'RangeMax', 100,
			}),
			PlaceObj('AIPolicyLosToEnemy', {
				'Weight', 300,
			}),
		},
		OptLocSearchRadius = 80,
		PrefStance = "Crouch",
		SignatureActions = {
			PlaceObj('AIAttackSingleTarget', {
				'BiasId', "Autofire",
				'Weight', 150,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "Autofire",
						'Effect', "disable",
						'Period', 0,
						'ApplyTo', "Team",
					}),
				},
				'NotificationText', "",
				'RequiredKeywords', {
					"Soldier",
				},
				'action_id', "AutoFire",
				'AttackTargeting', set( "Torso" ),
			}),
			PlaceObj('AIActionPinDown', {
				'BiasId', "PinDownAttack",
				'Weight', 80,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "PinDownAttack",
						'Value', -50,
						'ApplyTo', "Team",
					}),
				},
				'RequiredKeywords', {
					"Sniper",
				},
			}),
			PlaceObj('AIActionThrowGrenade', {
				'BiasId', "AssaultGrenadeThrow",
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "AssaultGrenadeThrow",
						'Effect', "disable",
					}),
					PlaceObj('AIBiasModification', {
						'BiasId', "AssaultGrenadeThrow",
						'Effect', "disable",
						'Period', 0,
						'ApplyTo', "Team",
					}),
				},
				'RequiredKeywords', {
					"Explosives",
				},
				'self_score_mod', -1000,
				'AllowedAoeTypes', set( "fire", "none", "teargas", "toxicgas" ),
			}),
			PlaceObj('AIActionThrowGrenade', {
				'BiasId', "SmokeGrenade",
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "SmokeGrenade",
						'Effect', "disable",
					}),
					PlaceObj('AIBiasModification', {
						'BiasId', "SmokeGrenade",
						'Effect', "disable",
						'Period', 0,
						'ApplyTo', "Team",
					}),
				},
				'RequiredKeywords', {
					"Smoke",
				},
				'enemy_score', 0,
				'team_score', 100,
				'self_score_mod', 100,
				'MinDist', 0,
				'AllowedAoeTypes', set( "smoke" ),
			}),
			PlaceObj('AIActionHeavyWeaponAttack', {
				'BiasId', "LauncherFire",
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "LauncherFire",
						'Effect', "disable",
						'Period', 0,
					}),
					PlaceObj('AIBiasModification', {
						'BiasId', "LauncherFire",
						'Value', -50,
						'Period', 0,
						'ApplyTo', "Team",
					}),
				},
				'RequiredKeywords', {
					"Ordnance",
				},
				'self_score_mod', -1000,
				'MinDist', 5000,
				'LimitRange', true,
				'MaxTargetRange', 30,
			}),
			PlaceObj('AIActionHeavyWeaponAttack', {
				'BiasId', "RocketFire",
				'Weight', 200,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "RocketFire",
						'Effect', "disable",
					}),
				},
				'RequiredKeywords', {
					"Ordnance",
				},
				'self_score_mod', -1000,
				'MinDist', 5000,
				'action_id', "RocketLauncherFire",
				'LimitRange', true,
				'MaxTargetRange', 30,
			}),
			PlaceObj('AIAttackSingleTarget', {
				'BiasId', "GroinShot",
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "GroinShot",
						'Effect', "disable",
						'Period', 0,
						'ApplyTo', "Team",
					}),
					PlaceObj('AIBiasModification', {
						'BiasId', "GroinShot",
						'Effect', "disable",
					}),
				},
				'RequiredKeywords', {
					"Sniper",
				},
				'Aiming', "Remaining AP",
				'AttackTargeting', set( "Groin" ),
			}),
			PlaceObj('AIConeAttack', {
				'BiasId', "Overwatch",
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "Overwatch",
						'Value', -50,
						'ApplyTo', "Team",
					}),
					PlaceObj('AIBiasModification', {
						'BiasId', "Overwatch",
						'Effect', "disable",
						'Value', -50,
						'Period', 2,
					}),
				},
				'RequiredKeywords', {
					"Soldier",
				},
				'team_score', 0,
				'min_score', 300,
				'action_id', "Overwatch",
			}),
			PlaceObj('AIConeAttack', {
				'BiasId', "SpamOverwatch",
				'Weight', 200,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "SpamOverwatch",
						'Effect', "disable",
						'Value', -50,
						'ApplyTo', "Team",
					}),
				},
				'RequiredKeywords', {
					"Control",
				},
				'team_score', 0,
				'min_score', 100,
				'action_id', "Overwatch",
			}),
		},
		TargetScoreRandomization = 10,
		group = "Default",
		id = "Soldier",
	}),
	PlaceObj('ModItemAIArchetype', {
		BaseAttackTargeting = set( "Arms", "Legs", "Torso" ),
		BaseAttackWeight = 50,
		BaseMovementWeight = 0,
		Behaviors = {
			PlaceObj('HoldPositionAI', {
				'BiasId', "HoldPositionBehavior",
				'Weight', 1000,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyDealDamage', {
						'Required', true,
					}),
				},
				'TakeCoverChance', 80,
			}),
			PlaceObj('PositioningAI', {
				'Weight', 10,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyWeaponRange', {
						'RangeMin', 40,
						'RangeMax', 100,
					}),
				},
			}),
		},
		OptLocPolicies = {
			PlaceObj('AIPolicyLosToEnemy', nil),
		},
		OptLocSearchRadius = 80,
		PrefStance = "Crouch",
		SignatureActions = {
			PlaceObj('AIAttackSingleTarget', {
				'BiasId', "Autofire",
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', {
						'BiasId', "Autofire",
						'Effect', "disable",
					}),
				},
				'NotificationText', "",
				'action_id', "AutoFire",
				'Aiming', "Remaining AP",
				'AttackTargeting', set( "Torso" ),
			}),
			PlaceObj('AIActionMGSetup', nil),
			PlaceObj('AIConeAttack', {
				'BiasId', "Overwatch",
				'team_score', 0,
				'min_score', 300,
				'action_id', "Overwatch",
			}),
			PlaceObj('AIAttackSingleTarget', {
				'Weight', 1000,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', nil),
				},
				'RequiredKeywords', {
					"Sniper",
				},
				'Aiming', "Maximum",
				'AttackTargeting', set( "Arms", "Groin", "Head", "Legs", "Torso" ),
			}),
		},
		TargetScoreRandomization = 10,
		TargetingPolicies = {
			PlaceObj('AITargetingCancelShot', nil),
		},
		group = "Simplified",
		id = "SpecialTurret",
	}),
	PlaceObj('ModItemAIArchetype', {
		BaseAttackTargeting = set( "Arms", "Legs", "Torso" ),
		BaseAttackWeight = 50,
		BaseMovementWeight = 0,
		Behaviors = {
			PlaceObj('HoldPositionAI', {
				'BiasId', "HoldPositionBehavior",
				'Weight', 1000,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyDealDamage', {
						'Required', true,
					}),
				},
				'TakeCoverChance', 80,
			}),
			PlaceObj('PositioningAI', {
				'Weight', 10,
				'EndTurnPolicies', {
					PlaceObj('AIPolicyWeaponRange', {
						'RangeMin', 40,
						'RangeMax', 100,
					}),
				},
			}),
		},
		OptLocPolicies = {
			PlaceObj('AIPolicyLosToEnemy', nil),
		},
		OptLocSearchRadius = 80,
		PrefStance = "Crouch",
		SignatureActions = {
			PlaceObj('AIAttackSingleTarget', {
				'Weight', 1000,
				'OnActivationBiases', {
					PlaceObj('AIBiasModification', nil),
				},
				'RequiredKeywords', {
					"Sniper",
				},
				'Aiming', "Maximum",
				'AttackTargeting', set( "Arms", "Groin", "Head", "Legs", "Torso" ),
			}),
		},
		TargetScoreRandomization = 10,
		TargetingPolicies = {
			PlaceObj('AITargetingCancelShot', nil),
			PlaceObj('AITargetingEnemyWeapon', {
				'EnemyWeapon', "Sniper",
			}),
		},
		group = "Simplified",
		id = "SpecialTurret_Sniper",
	}),
	PlaceObj('ModItemCharacterEffectCompositeDef', {
		'Id', "ABD_Alerted",
		'object_class', "CharacterEffect",
		'Conditions', {
			PlaceObj('CheckExpression', {
				Expression = function (self, obj) return not obj.team or not obj.team.neutral end,
				param_bindings = false,
			}),
		},
		'DisplayName', T(672319676530, --[[ModItemCharacterEffectCompositeDef ABD_Alerted DisplayName]] "Alerted"),
		'Description', T(101697038965, --[[ModItemCharacterEffectCompositeDef ABD_Alerted Description]] "This character is alerted and shoots on sight"),
		'OnAdded', function (self, obj)  end,
		'OnRemoved', function (self, obj)  end,
		'Icon', "Mod/D55GHCb/icons/alerted.png",
		'Shown', true,
	}),
	PlaceObj('ModItemCharacterEffectCompositeDef', {
		'Group', "System",
		'Id', "ABD_Filters",
		'object_class', "CharacterEffect",
		'unit_reactions', {
			PlaceObj('UnitReaction', {
				Event = "OnCalcSightModifier",
				Handler = function (self, target, value, observer, other, step_pos, darkness)
					value =  ABD_Darkness:ModifySightRadiusModifier(self,target,value,observer,other,step_pos,darkness)
					value = ABD_Camo:ModifySightRadiusModifier(self,target,value,observer,other,step_pos,darkness)
					return value
				end,
				param_bindings = false,
			}),
		},
		'Description', T(149413334248, --[[ModItemCharacterEffectCompositeDef ABD_Filters Description]] "Hidden Modifiers"),
		'HideOnBadge', true,
	}),
	PlaceObj('ModItemConstDef', {
		Comment = "sight penalty (as % of base value) for seeing hidden units in prone stance",
		group = "Combat",
		id = "SightModHiddenProne",
	}),
	PlaceObj('ModItemConstDef', {
		Comment = "what percentage of the stat difference (Agility - Wisdom) is applied as a sight modifier to units trying to see a Hidden unit",
		group = "Combat",
		id = "SightModStealthStatDiff",
		scale = "%",
	}),
	PlaceObj('ModItemCharacterEffectCompositeDef', {
		'Id', "ABD_Concealed",
		'object_class', "CharacterEffect",
		'DisplayName', T(121080689484, --[[ModItemCharacterEffectCompositeDef ABD_Concealed DisplayName]] "Concealed"),
		'Description', T(937946970632, --[[ModItemCharacterEffectCompositeDef ABD_Concealed Description]] "Shows the concealment factor of a unit"),
		'type', "Buff",
		'Icon', "Mod/D55GHCb/icons/concealed.png",
		'max_stacks', 5,
		'Shown', true,
	}),
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD_Dynamics",
		'CodeFileName', "Code/CLASS_ABD_Dynamics.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD",
		'CodeFileName', "Code/CLASS_ABD.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_Unit",
		'CodeFileName', "Code/OR_Unit.lua",
	}),
	PlaceObj('ModItemInventoryItemCompositeDef', {
		'Id', "FlareAmmo",
		'object_class', "Ordnance",
		'Repairable', false,
		'Icon', "UI/Icons/Items/FlareBullet",
		'DisplayName', T(253255482100, --[[ModItemInventoryItemCompositeDef FlareAmmo DisplayName]] "Flare Cartridge"),
		'DisplayNamePlural', T(645716581676, --[[ModItemInventoryItemCompositeDef FlareAmmo DisplayNamePlural]] "Flare Cartridges"),
		'Description', T(754505471396, --[[ModItemInventoryItemCompositeDef FlareAmmo Description]] "Ammo for the Flare Gun."),
		'Cost', 100,
		'CanAppearInShop', true,
		'MaxStock', 5,
		'RestockWeight', 30,
		'CategoryPair', "UtilityAmmo",
		'AreaOfEffect', 12,
		'PenetrationClass', 1,
		'Caliber', "Flare",
		'BaseDamage', 0,
		'Noise', 0,
	}),
	PlaceObj('ModItemInventoryItemCompositeDef', {
		'Id', "FlareStick",
		'object_class', "Flare",
		'Repairable', false,
		'Reliability', 100,
		'Icon', "UI/Icons/Weapons/FlareStick",
		'ItemType', "Throwables",
		'DisplayName', T(451057994898, --[[ModItemInventoryItemCompositeDef FlareStick DisplayName]] "Flare Stick"),
		'DisplayNamePlural', T(920388176978, --[[ModItemInventoryItemCompositeDef FlareStick DisplayNamePlural]] "Flare Sticks"),
		'AdditionalHint', T(386599408607, --[[ModItemInventoryItemCompositeDef FlareStick AdditionalHint]] "<bullet_point> Illuminates a large area\n<bullet_point> High mishap chance\n<bullet_point> Silent"),
		'UnitStat', "Explosives",
		'Cost', 200,
		'CanAppearInShop', true,
		'Tier', 2,
		'RestockWeight', 25,
		'CategoryPair', "Grenade",
		'MinMishapChance', 10,
		'MaxMishapChance', 50,
		'MaxMishapRange', 6,
		'CenterUnitDamageMod', 0,
		'CenterObjDamageMod', 0,
		'AreaOfEffect', 6,
		'AreaUnitDamageMod', 0,
		'AreaObjDamageMod', 0,
		'PenetrationClass', 1,
		'BaseDamage', 0,
		'Scatter', 4,
		'AttackAP', 4000,
		'Noise', 0,
		'Entity', "Weapon_MolotovCocktail",
		'ActionIcon', "UI/Icons/Hud/flare",
	}),
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD_Camo",
		'CodeFileName', "Code/CLASS_ABD_Camo.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_UnitAwareness",
		'CodeFileName', "Code/OR_UnitAwareness.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD_Noise",
		'CodeFileName', "Code/CLASS_ABD_Noise.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_Stealth",
		'CodeFileName', "Code/OR_Stealth.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_CombatAction",
		'CodeFileName', "Code/OR_CombatAction.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_Weapon",
		'CodeFileName', "Code/OR_Weapon.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "SETUP_Terrain",
		'CodeFileName', "Code/SETUP_Terrain.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_ClassDef-Zulu",
		'CodeFileName', "Code/OR_ClassDef-Zulu.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD_AI",
		'CodeFileName', "Code/CLASS_ABD_AI.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_ClassDef-AI",
		'CodeFileName', "Code/OR_ClassDef-AI.lua",
	}),
	PlaceObj('ModItemConstDef', {
		group = "Combat",
		id = "CamoSightPenalty",
		scale = "%",
	}),
	PlaceObj('ModItemConstDef', {
		Comment = "Sight radius (in tiles) of units who are not aware of the target unit (either Unaware or target is Hidden)",
		group = "Combat",
		id = "UnawareSightRange",
		value = 16,
	}),
	PlaceObj('ModItemConstDef', {
		Comment = "sight penalty (as % of base value) for seeing units in dark or difficult to see locations",
		group = "EnvEffects",
		id = "DarknessSightMod",
		scale = "%",
	}),
	PlaceObj('ModItemConstDef', {
		Comment = "minimum value for the sight modifier",
		group = "Combat",
		id = "SightModMinValue",
	}),
	PlaceObj('ModItemActionFXLight', {
		Action = "Spawn",
		Actor = "Weapon_FlareStick",
		Attach = true,
		CastShadows = true,
		Color = 4294901760,
		Color0 = 4294901760,
		Color1 = 4294901760,
		Delay = 800,
		DetailLevel = 100,
		EndRules = {
			PlaceObj('ActionFXEndRule', {
				'EndAction', "Flare",
				'EndMoment', "end",
			}),
		},
		FadeIn = 200,
		FadeOutColor = 4294901760,
		GameTime = true,
		Intensity = 14,
		Intensity0 = 18,
		Intensity1 = 24,
		Moment = "start",
		Offset = point(0, 0, 1000),
		Period = 6000,
		Radius = 10000,
		Spot = "Particle",
		StartColor = 4294901760,
		StartIntensity = 10,
		Sync = true,
		Time = 10000000,
		Type = "PointLightFlicker",
		behaviors = {
			PlaceObj('ActionFXBehavior', nil),
		},
		group = "Default",
		handle = "6346654985964621069",
		id = "6346654985964621069",
	}),
	PlaceObj('ModItemActionFXLight', {
		Action = "Spawn",
		Actor = "FlareBullet",
		Attach = true,
		CastShadows = true,
		Color = 4294901760,
		Color0 = 4294901760,
		Color1 = 4294901760,
		Delay = 800,
		DetailLevel = 100,
		FadeIn = 200,
		FadeOutColor = 4294901760,
		GameTime = true,
		Intensity = 14,
		Intensity0 = 30,
		Intensity1 = 40,
		Moment = "start",
		Offset = point(0, 0, 2000),
		Period = 6000,
		Radius = 20000,
		Spot = "Particle",
		StartColor = 4294901760,
		StartIntensity = 10,
		Sync = true,
		Time = 10000000,
		Type = "PointLightFlicker",
		group = "Default",
		handle = "3259676871936435544",
		id = "3259676871936435544",
	}),
	PlaceObj('ModItemActionFXLight', {
		Action = "Spawn",
		Actor = "Weapon_FlareStick_OnGround",
		Attach = true,
		CastShadows = true,
		Color = 4294901760,
		Color0 = 4294901760,
		Color1 = 4294901760,
		DetailLevel = 100,
		EndRules = {
			PlaceObj('ActionFXEndRule', {
				'EndAction', "Flare",
				'EndMoment', "end",
			}),
		},
		FadeIn = 200,
		FadeOutColor = 4294901760,
		GameTime = true,
		Intensity = 14,
		Intensity0 = 18,
		Intensity1 = 24,
		Moment = "start",
		Offset = point(2000, 0, 0),
		Period = 6000,
		Radius = 10000,
		Spot = "Particle",
		StartColor = 4294901760,
		StartIntensity = 10,
		Sync = true,
		Time = 10000000,
		Type = "PointLightFlicker",
		behaviors = {
			PlaceObj('ActionFXBehavior', nil),
		},
		group = "Default",
		handle = "ZZs1MYjR",
		id = "ZZs1MYjR",
	}),
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD_Darkness",
		'CodeFileName', "Code/CLASS_ABD_Darkness.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_ActionFX",
		'CodeFileName', "Code/OR_ActionFX.lua",
	}),
	PlaceObj('ModItemAIArchetype', {
		Behaviors = {
			PlaceObj('CustomAI', {
				'Priority', true,
				'Execute', function (self, unit, context, debug_data)
					ABD_Darkness:AI_Illumination(unit)
				end,
			}),
		},
		group = "Simplified",
		id = "Illuminator",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_CombatAI",
		'CodeFileName', "Code/OR_CombatAI.lua",
	}),
	PlaceObj('ModItemParticleSystemPreset', {
		group = "Default",
		id = "Wpn_Flashlight_LightCone",
		stable_cam_distance = true,
		PlaceObj('ParticleEmitter', {
			'label', "Light Cone",
			'emit_detail_level', 100,
			'emit_fade', range(0, 15000),
			'max_live_count', 1,
			'parts_per_sec', 10000,
			'lifetime_min', 0,
			'lifetime_max', 0,
			'position', point(8000, 0, 0),
			'size_min', 400,
			'size_max', 800,
			'part_emit_modifier', 100000,
			'shader', "Add",
			'texture', "Textures/Particles/Godray.tga",
			'self_illum', 50,
			'softness', 100,
			'far_softness', 100,
			'near_softness', 100,
			'alpha', range(137, 204),
			'outlines', {},
		}, nil, nil),
		PlaceObj('ParticleBehaviorResize', {
			'start_size_min', 8000,
			'start_size_max', 8000,
			'mid_size', 64000,
			'end_size', 128000,
			'size_curve', PackCurveParams(0, 0, 0, 0, 0, 0, 255000, 0, 10),
			'non_square_size', true,
			'start_size2_min', 16000,
			'start_size2_max', 16000,
			'mid_size2', 16000,
			'end_size2', 16000,
			'size_curve2', PackCurveParams(0, 0, 1000, 0, 1000, 0, 255000, 0, 10),
		}, nil, nil),
		PlaceObj('ParticleBehaviorColorize', {
			'start_color_min', RGBA(255, 244, 216, 255),
			'start_color_max', RGBA(255, 244, 216, 255),
		}, nil, nil),
		PlaceObj('FaceAlongConstDir', {
			'direction', point(-1000, 0, 0),
		}, nil, nil),
		PlaceObj('ParticleEmitter', {
			'label', "Lines",
			'bins', set( "B" ),
			'emit_detail_level', 100,
			'max_live_count', 1,
			'parts_per_sec', 10000,
			'lifetime_min', 500,
			'lifetime_max', 500,
			'position', point(50, 0, 0),
			'angle', range(60, 60),
			'size_min', 100,
			'size_max', 100,
			'shader', "Add",
			'texture', "Textures/Particles/White_Soft.tga",
			'softness', 10,
			'far_softness', 100,
			'near_softness', 100,
			'alpha', range(25, 25),
			'outlines', {
				{
					point(96, 3904),
					point(3904, 3904),
					point(3904, 128),
					point(224, 128),
				},
			},
			'texture_hash', 5044350849439443378,
		}, nil, nil),
		PlaceObj('ParticleEmitter', {
			'label', "Lines",
			'bins', set( "B" ),
			'emit_detail_level', 100,
			'max_live_count', 1,
			'parts_per_sec', 10000,
			'lifetime_min', 500,
			'lifetime_max', 500,
			'position', point(50, 0, 0),
			'angle', range(120, 120),
			'size_min', 100,
			'size_max', 100,
			'shader', "Add",
			'texture', "Textures/Particles/White_Soft.tga",
			'softness', 10,
			'far_softness', 100,
			'near_softness', 100,
			'alpha', range(25, 25),
			'outlines', {
				{
					point(96, 3904),
					point(3904, 3904),
					point(3904, 128),
					point(224, 128),
				},
			},
			'texture_hash', 5044350849439443378,
		}, nil, nil),
		PlaceObj('ParticleBehaviorResizeCurve', {
			'bins', set( "B" ),
			'max_size', 50,
			'size_curve', {
				range_y = 10,
				scale = 1000,
				point(0, 1000, 1000),
				point(299, 1000, 1000),
				point(605, 1000, 1000),
				point(1000, 1000, 1000),
			},
			'non_square_size', true,
			'max_size_2', 350,
			'size_curve_2', {
				range_y = 10,
				scale = 1000,
				point(0, 1000, 1000),
				point(322, 1000, 1000),
				point(632, 1000, 1000),
				point(1000, 1000, 1000),
			},
		}, nil, nil),
		PlaceObj('FaceAlongConstDir', {
			'bins', set(),
		}, nil, nil),
		PlaceObj('FaceAlongMovement', {
			'bins', set( "B" ),
			'rotate', true,
		}, nil, nil),
		PlaceObj('ParticleEmitter', {
			'label', "Glow",
			'bins', set( "G" ),
			'emit_detail_level', 100,
			'max_live_count', 1,
			'parts_per_sec', 10000,
			'lifetime_min', 500,
			'lifetime_max', 500,
			'position', point(50, 0, 0),
			'size_min', 150,
			'size_max', 150,
			'shader', "Add",
			'texture', "Textures/Particles/White_Soft.tga",
			'alpha', range(55, 55),
			'outlines', {
				{
					point(96, 3904),
					point(3904, 3904),
					point(3904, 128),
					point(224, 128),
				},
			},
			'texture_hash', 5044350849439443378,
		}, nil, nil),
		PlaceObj('ParticleEmitter', {
			'label', "Halo",
			'bins', set( "H" ),
			'emit_detail_level', 100,
			'max_live_count', 1,
			'parts_per_sec', 10000,
			'lifetime_min', 500,
			'lifetime_max', 500,
			'position', point(50, 0, 0),
			'size_min', 150,
			'size_max', 150,
			'shader', "Add",
			'texture', "Textures/Particles/Halo_Thin.tga",
			'normalmap', "Textures/Particles/flat.norm.tga",
			'alpha', range(75, 75),
			'outlines', {
				{
					point(224, 3856),
					point(3856, 3856),
					point(3856, 224),
					point(224, 224),
				},
			},
			'texture_hash', 2502804124047695963,
		}, nil, nil),
		PlaceObj('FaceDirection', {
			'bins', set( "G", "H" ),
			'direction', point(1000, 0, 0),
		}, nil, nil),
	}),
}