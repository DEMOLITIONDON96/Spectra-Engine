function onCreate()
{
	spawnGirlfriend(true);
	PlayState.defaultCamZoom = 0.9;
	PlayState.cameraSpeed = 1;

	var bg:FNFSprite = new FNFSprite(-600, -200).loadGraphic(Paths.image('stageback', 'data/stages/stage/images'));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.9, 0.9);
	bg.active = false;
	add(bg);

	var stageFront:FNFSprite = new FNFSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'data/stages/stage/images'));
	stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
	stageFront.updateHitbox();
	stageFront.antialiasing = true;
	stageFront.scrollFactor.set(0.9, 0.9);
	stageFront.active = false;
	add(stageFront);

	var stageCurtains:FNFSprite = new FNFSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'data/stages/stage/images'));
	stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
	stageCurtains.updateHitbox();
	stageCurtains.antialiasing = true;
	stageCurtains.scrollFactor.set(1.3, 1.3);
	stageCurtains.active = false;
	add(stageCurtains);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	boyfriend.setPosition(770, 450);
	dad.setPosition(100, 100);
	gf.setPosition(300, 100);
}

function onPostCreate(boyfriend:Character, gf:Character, dad:Character)
{
	if (StringTools.startsWith('gf', dad.curCharacter))
	{
		dad.setPosition(gf.x, gf.y);
		gf.visible = false;
	}
}
