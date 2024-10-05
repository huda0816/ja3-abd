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
		'Id', "HUDA_Alerted",
		'object_class', "CharacterEffect",
		'Conditions', {
			PlaceObj('CheckExpression', {
				Expression = function (self, obj) return not obj.team or not obj.team.neutral end,
				param_bindings = false,
			}),
		},
		'DisplayName', T(672319676530, --[[ModItemCharacterEffectCompositeDef HUDA_Alerted DisplayName]] "Alerted"),
		'Description', T(101697038965, --[[ModItemCharacterEffectCompositeDef HUDA_Alerted Description]] "This character is alerted and shoots on sight"),
		'OnAdded', function (self, obj)
			--obj:AddStatusEffectImmunity("Unaware", "alerted")
			--obj:AddStatusEffectImmunity("Surprised", "alerted")
			--obj:AddStatusEffectImmunity("Suspicious", "alerted")
			--obj.pending_aware_state = "aware"
			Msg("UnitAwarenessChanged", obj)
		end,
		'OnRemoved', function (self, obj)  end,
		'Icon', "UI/Hud/Status effects/suspicious",
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
	PlaceObj('ModItemCode', {
		'name', "CLASS_ABD_Darkness",
		'CodeFileName', "Code/CLASS_ABD_Darkness.lua",
	}),
	PlaceObj('ModItemCode', {
		'name', "OR_ActionFX",
		'CodeFileName', "Code/OR_ActionFX.lua",
	}),
}