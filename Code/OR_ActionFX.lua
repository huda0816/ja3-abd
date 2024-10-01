local ABD_Original_PlayFX = PlayFX

function PlayFX(actionFXClass, actionFXMoment, actor, target, action_pos, action_dir)
	Msg("ABD_PlayFX", actionFXClass, actionFXMoment, actor, target, action_pos, action_dir)
	ABD_Original_PlayFX(actionFXClass, actionFXMoment, actor, target, action_pos, action_dir)
end
