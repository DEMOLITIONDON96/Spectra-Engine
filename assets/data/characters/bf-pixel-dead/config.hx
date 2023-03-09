function loadAnimations()
{
	addByPrefix('firstDeath', "BF Dies pixel", 24, false);
	addByPrefix('deathLoop', "Retry Loop", 24, true);
	addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

	addOffset("firstDeath", 9, 24);
	addOffset("deathConfirm", -22, 12);
	addOffset("deathLoop", -22, 12);

	setGraphicSize(get('width') * 6);

	characterData.antialiasing = false;
	characterData.assetModifier = 'pixel';
	characterData.flipX = true;

	setOffsets(0, 305);
}
