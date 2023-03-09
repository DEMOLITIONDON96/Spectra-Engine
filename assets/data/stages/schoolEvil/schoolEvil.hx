function onCreate()
{
	spawnGirlfriend(true);
	PlayState.defaultCamZoom = 1.05;
	PlayState.cameraSpeed = 1;

	var bg:FNFSprite = new FNFSprite(400, 200);
	bg.frames = Paths.getSparrowAtlas('animatedEvilSchool', 'data/stages/schoolEvil/images');
	bg.animation.addByPrefix('idle', 'background 2', 24);
	bg.animation.play('idle');
	bg.scrollFactor.set(0.8, 0.9);
	bg.antialiasing = false;
	bg.scale.set(6, 6);
	add(bg);
}

function onPostCreate(boyfriend:Character, gf:Character, dad:Character)
{
	var evilTrail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
	evilTrail.changeValuesEnabled(false, false, false, false);
	add(evilTrail);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	boyfriend.setPosition(970, 620);
	dad.setPosition(-75, 165);
	gf.setPosition(580, 430);
}
