function eventTrigger(params)
{
	//
	if (params[0] != null)
		PlayState.cameraBumpSpeed = params[0];

	if (params[1] != null)
		PlayState.cameraSpeed = params[1];
}

function returnDescription()
	return "Changes the camera bumping zoom effect\nValue 1: new bump value (defaults to 4)\nValue 2: new camera movement speed.";
