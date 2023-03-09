function loadAnimations()
{
	if (StringTools.startsWith(songName, 'roses'))
		getMad();
	else
		setupAnims();

	addOffset('idle', 0, 0);
	addOffset('singUP', 5, 37);
	addOffset('singRIGHT', 0, 0);
	addOffset('singLEFT', 40, 0);
	addOffset('singDOWN', 14, 0);

	setGraphicSize(get('width') * 6);
	characterData.antialiasing = false;
	characterData.assetModifier = 'pixel';
	characterData.missColor = [174, 181, 229];

	playAnim('idle');

	setOffsets(200, 500);
	setCamOffsets(-180, -290);
	setBarColor([255, 170, 111]);
	quickDancer(false);
}

function setupAnims()
{
	addByPrefix('idle', 'Idle', 24, false);
	addByPrefix('singUP', 'Up', 24, false);
	addByPrefix('singLEFT', 'Left', 24, false);
	addByPrefix('singRIGHT', 'Right', 24, false);
	addByPrefix('singDOWN', 'Down', 24, false);
}

function getMad() // cope;
{
	addByPrefix('idle', 'Angry Idle', 24, false);
	addByPrefix('singUP', 'Angry Up', 24, false);
	addByPrefix('singLEFT', 'Angry Left', 24, false);
	addByPrefix('singRIGHT', 'Angry Right', 24, false);
	addByPrefix('singDOWN', 'Angry Down', 24, false);
}
