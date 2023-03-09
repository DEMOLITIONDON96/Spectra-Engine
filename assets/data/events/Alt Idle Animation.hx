function eventTrigger(params)
{
	getChar(params[0]).idleSuffix = params[1];
}

function getChar(character:String = "boyfriend")
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
	return target;
}

function returnDescription()
	return
		"Changes the idle animation suffix for the specified character,\nValue 1: Character (bf, gf, dad, defaults to bf).\nValue 2: New Idle Suffix (example: -alt)";
