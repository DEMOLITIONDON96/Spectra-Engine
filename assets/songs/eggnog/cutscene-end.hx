function songEndCutscene()
{
	// make the lights go out
	var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
		-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
	blackShit.scrollFactor.set();
	add(blackShit);
	camHUD.visible = false;
	for (i in 0...PlayState.strumLines.length)
		strumHUD[i].visible = false;

	// oooo spooky
	FlxG.sound.play(Paths.sound('events/week5/Lights_Shut_off'));

	// call the song end
	var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
	{
		game.callDefaultSongEnd();
	}, 1);
}
