function eventTrigger(params)
{
	var value:Int = Std.parseInt(params[0]);
	if (Math.isNaN(value) || value <= 0)
		speed = 1;
	game.gfSpeed = value;
}

function returnDescription()
	return
		"Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\nWarning: Value must be integer!";
