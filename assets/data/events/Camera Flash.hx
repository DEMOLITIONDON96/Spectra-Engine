function eventTrigger(params)
{
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer) || timer <= 0)
		timer = 0.6;
	if (params[0] == null)
		params[0] = 'white';
	FlxG.camera.flash(ForeverTools.returnColor(params[0]), timer);
}

function returnDescription()
	return "Flashes the camera with the given color and time,\nValue 1: Color to use for the Flash.\nValue 2: Duration of the Flash.";
