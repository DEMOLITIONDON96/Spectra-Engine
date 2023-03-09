function loadAnimations()
{
	addByPrefix('idle', 'BF IDLE', 24, false);
	addByPrefix('singUP', 'BF UP NOTE', 24, false);
	addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
	addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
	addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
	addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
	addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);
	addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
	addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);

	addOffset('idle', 0, 0);
	addOffset('singUP', 0, 0);
	addOffset('singDOWN', 0, 0);
	addOffset('singLEFT', 0, 0);
	addOffset('singRIGHT', 0, 0);
	addOffset('singUPmiss', 0, 0);
	addOffset('singDOWNmiss', 0, 0);
	addOffset('singLEFTmiss', 0, 0);
	addOffset('singRIGHTmiss', 0, 0);

	playAnim('idle');

	setGraphicSize(get('width') * 6);
	characterData.antialiasing = false;
	characterData.assetModifier = 'pixel';
	characterData.missColor = [174, 181, 229];

	if (!isPlayer)
		characterData.flipX = true;

	set('width', get('width') - 100);
	set('height', get('width') - 100);

	setOffsets(220, 150);
	setCamOffsets(0, 0);

	setBarColor([123, 214, 246]);
	setDeathChar('bf-pixel-dead', 'fnf_loss_sfx', 'gameOver-pixel', 'gameOverEnd-pixel');
}
