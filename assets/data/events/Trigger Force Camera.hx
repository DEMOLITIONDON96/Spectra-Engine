function eventTrigger(params)
{
	//
	PlayState.forceZoom[params[0]] = params[1];
}

function returnDescription()
	return
		"Forces the camera to have a different zoom / angle factor\nValue 1: Target [0 = camera zoom,\n1 = hud zoom, 2 = camera angle, 3 = hud angle]\nValue 2: Value to Apply.";
