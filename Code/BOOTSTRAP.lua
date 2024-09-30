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
	print("OptionsApply")
end

function OnMsg.PostNewMapLoaded()
	ABD_Darkness:ApplyLightmodel('store')
end

function OnMsg.OpenPDA()
	print("OpenPDA")
	ABD:ClearGameVar("darkness.lightness")
	ABD_Darkness:ResetLightmodel()
end

function OnMsg.ClosePDA()
	print("ClosePDA")
	ABD_Darkness:ApplyLightmodel()
end

function OnMsg.SelectedObjChange()
	ABD_Darkness:MaybeSwitchToNightvision(SelectedObj)
end

function OnMsg.ItemAdded()
	ABD_Darkness:MaybeSwitchToNightvision(SelectedObj)
end


