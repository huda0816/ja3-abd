GameVar("gv_ABD", {})

function OnMsg.ZuluGameLoaded()
	ABD:Init()
end

function OnMsg.ExplorationStart()
	ABD_Noise:Init()
end

function OnMsg.ExplorationEnd()
	ABD_Noise:Done()
end

function OnMsg.CombatStarting()
	ABD_Noise:Done()
end

function OnMsg.CombatEnded()
	ABD_Noise:Init()
end

function OnMsg.OptionsApply()
	ABD:Print("OptionsApply")
end

function OnMsg.PostNewMapLoaded()
	ABD_Darkness:ApplyLightmodel('store')
end

function OnMsg.OpenPDA()
	ABD:Print("OpenPDA")
	ABD:ClearGameVar("darkness.lightness")
	ABD_Darkness:ResetLightmodel()
end

function OnMsg.ClosePDA()
	ABD:Print("ClosePDA")
	ABD_Darkness:ApplyLightmodel()
end

function OnMsg.SelectedObjChange()
	ABD_Darkness:MaybeSwitchToNightvision(SelectedObj)
end

function OnMsg.ItemAdded()
	ABD_Darkness:MaybeSwitchToNightvision(SelectedObj)
end

function OnMsg.ABD_PlayFX(actionFXClass, actionFXMoment, actor, target, action_pos, action_dir)
	ABD_Noise:HandleFXNoise(actionFXClass, actor)

	if actionFXClass == "Explosion" then
		ABD:Print("Explosion")
		ABD_Dynamics:NoiseTresholdAlert(actor, 30, "Explosion", actor)
		--TODO: Push Unit alert
	end

	if actionFXClass == "LightningStrike" then
		ABD_Darkness:IlluminateMap()
	end
end

function OnMsg.ExplorationTick()
	ABD_Camo:UpdateAllConcealment()
end

function OnMsg.UnitMovementStart(unit)
	ABD_Camo:UpdateConcealment(unit)
end

function OnMsg.UnitStanceChanged(unit)
	ABD_Camo:UpdateConcealment(unit)
end

function OnMsg.UnitMovementDone(unit)
	ABD_Camo:UpdateConcealment(unit)
end

