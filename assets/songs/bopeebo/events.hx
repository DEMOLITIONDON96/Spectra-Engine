function beatHit(curBeat)
{
	if (curBeat % 8 == 7)
	{
		playHey("gf", 0.6);
		playHey("bf", 0.6);
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
