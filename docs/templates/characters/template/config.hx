function loadAnimations()
{
	addByPrefix('idle', 'Idle', 24, false);
	addByPrefix('singLEFT', 'Left', 24, false);
	addByPrefix('singDOWN', 'Down', 24, false);
	addByPrefix('singUP', 'Up', 24, false);
	addByPrefix('singRIGHT', 'Right', 24, false);

	if (!isPlayer)
	{
		addOffset("idle", 0, -350);
		addOffset("singLEFT", 22, -353);
		addOffset("singDOWN", 17, -375);
		addOffset("singUP", 8, -334);
		addOffset("singRIGHT", 50, -348);
		characterData.camOffsets = [30, 330];
		characterData.offsets = [0, -350];
	}
	else
	{
		addOffset("idle", 0, -10);
		addOffset("singLEFT", 33, -6);
		addOffset("singDOWN", -48, -31);
		addOffset("singUP", -45, 11);
		addOffset("singRIGHT", -61, -14);
		characterData.camOffsets = [0, -5];
		characterData.flipX = false;
	}

	playAnim('idle');
}
