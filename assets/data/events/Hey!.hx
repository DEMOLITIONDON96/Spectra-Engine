function eventTrigger(params)
{
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer) || timer <= 0)
		timer = 0.6;

	switch (params[0])
	{
		case "bfAndGf", "bfgf", "both", "3":
			playHey("gf", timer);
			playHey("bf", timer);
		case "bfGfDad", "bfGfOpponent", "all", "4":
			playHey("gf", timer);
			playHey("bf", timer);
		default:
			playHey(params[0], timer);
	}
}

function playHey(character:String = "boyfriend", timer:Float = 0.6)
{
	var target:Character = null;
	switch (character)
	{
		case 'dad', 'dadOpponent', 'opponent', '1':
			target = PlayState.opponent;
		case 'gf', 'girlfriend', 'spectator', '2':
			target = PlayState.gf;
		default:
			target = PlayState.boyfriend;
	}

	if (target.animOffsets.exists('hey'))
		target.playAnim('hey', true);
	else if (target.animOffsets.exists('cheer'))
		target.playAnim('cheer', true);
	target.specialAnim = true;
	target.heyTimer = timer;
}

function returnDescription()
	return
		"Plays the \"Hey!\" animation from Bopeebo,\nValue 1: Character (bf, gf, dad, both, all, defaults to bf).\nValue 2: Custom animation duration,\nleave it blank for 0.6s";
