function eventTrigger(params)
{
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer) || timer <= 0)
		timer = 0.6;

	switch (params[1])
	{
		case 'dad', 'dadOpponent', 'opponent', '1':
			if (PlayState.opponent.animOffsets.exists(params[0]))
			{
				PlayState.opponent.playAnim(params[0], true);
				PlayState.opponent.specialAnim = true;
				PlayState.opponent.heyTimer = timer;
			}
		case 'gf', 'girlfriend', 'spectator', '2':
			if (PlayState.gf.animOffsets.exists(params[0]))
			{
				PlayState.gf.playAnim(params[0], true);
				PlayState.gf.specialAnim = true;
				PlayState.gf.heyTimer = timer;
			}
		default:
			if (PlayState.boyfriend.animOffsets.exists(params[0]))
			{
				PlayState.boyfriend.playAnim(params[0], true);
				PlayState.boyfriend.specialAnim = true;
				PlayState.boyfriend.heyTimer = timer;
			}
	}
}

function returnDescription()
	return
		"Plays an animation on a Character,\nValue 1: Animation to play.\nValue 2: Character (bf, gf, dad, defaults to dad)\nValue 3: time it takes to finish the animation,\nleave it blank for 0.6s";

function returnValue3()
	return true;
