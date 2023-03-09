function loadAnimations()
{
	addByPrefix('idle', "idle spirit_", 24, false);
	addByPrefix('singUP', "up_", 24, false);
	addByPrefix('singRIGHT', "right_", 24, false);
	addByPrefix('singLEFT', "left_", 24, false);
	addByPrefix('singDOWN', "spirit down_", 24, false);

	addOffset('idle', -220, -280);
	addOffset('singUP', -220, -240);
	addOffset('singRIGHT', -220, -280);
	addOffset('singLEFT', -200, -280);
	addOffset('singDOWN', 170, 110);

	setGraphicSize(get('width') * 6);
	characterData.antialiasing = false;
	characterData.assetModifier = 'pixel';
	characterData.missColor = [174, 181, 229];

	playAnim('idle');

	setCamOffsets(100, 50);
	setOffsets(-150, 0);
	setBarColor([255, 60, 110]);
}
