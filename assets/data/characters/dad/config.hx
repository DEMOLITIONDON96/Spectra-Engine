function loadAnimations()
{
	addByPrefix('idle', 'Dad idle dance', 24);
	addByPrefix('singUP', 'Dad Sing note UP', 24, false);
	addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
	addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
	addByPrefix('singLEFT', 'dad sing note left', 24, false);

	addOffset('idle', 0, 0);
	addOffset('singUP', -9, 51);
	addOffset('singDOWN', 2, -29);
	addOffset('singLEFT', -9, 10);
	addOffset('singRIGHT', -2, 27);

	playAnim('idle');
	set('antialiasing', true);
	setBarColor([175, 102, 206]);
	setOffsets(0, 0);
}
