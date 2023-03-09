function onCreate()
{
	var stageDir:String = 'data/stages/mallEvil/images';

	spawnGirlfriend(true);
	PlayState.defaultCamZoom = 1.1;
	PlayState.cameraSpeed = 1.3;

	var bg:FNFSprite = new FNFSprite(-400, -500).loadGraphic(Paths.image('evilBG', stageDir));
	bg.antialiasing = true;
	bg.scrollFactor.set(0.2, 0.2);
	bg.active = false;
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();
	add(bg);

	var evilTree:FNFSprite = new FNFSprite(300, -300).loadGraphic(Paths.image('evilTree', stageDir));
	evilTree.antialiasing = true;
	evilTree.scrollFactor.set(0.2, 0.2);
	add(evilTree);

	var evilSnow:FNFSprite = new FNFSprite(-200, 700).loadGraphic(Paths.image("evilSnow", stageDir));
	evilSnow.antialiasing = true;
	add(evilSnow);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	boyfriend.setPosition(1050, 400);
	dad.setPosition(50, 120);
	gf.setPosition(650, 100);
}
