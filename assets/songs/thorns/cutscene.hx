function songCutscene()
{
	for (hud in allUIs)
		hud.visible = false;

	var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
	red.scrollFactor.set();

	var senpaiEvil:FlxSprite = new FlxSprite();
	senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
	senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
	senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
	senpaiEvil.scrollFactor.set();
	senpaiEvil.updateHitbox();
	senpaiEvil.screenCenter();

	add(red);
	add(senpaiEvil);
	senpaiEvil.alpha = 0;
	new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
	{
		senpaiEvil.alpha += 0.15;
		if (senpaiEvil.alpha < 1)
			swagTimer.reset();
		else
		{
			senpaiEvil.animation.play('idle');
			FlxG.sound.play(Paths.sound('Senpai_Dies', 'data/stages/school/sounds'), 1, false, null, true, function()
			{
				remove(senpaiEvil);
				remove(red);
				FlxG.camera.fade(0xFFFFFFFF, 0.01, true, function()
				{
					for (hud in allUIs)
						hud.visible = true;
					game.callTextbox();
				}, true);
			});
			new FlxTimer().start(3.2, function(deadTime:FlxTimer)
			{
				FlxG.camera.fade(0xFFFFFFFF, 1.6, false);
			});
		}
	});
}
