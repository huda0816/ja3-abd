local ABD_Original_IsOverwatchAction = IsOverwatchAction

function IsOverwatchAction(actionId)
	return actionId == "ABD_FaceDirection" or ABD_Original_IsOverwatchAction(actionId)
end