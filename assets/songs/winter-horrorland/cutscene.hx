function songCutscene()
{
	var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
	add(blackScreen);
	blackScreen.scrollFactor.set();
	camHUD.visible = false;

	game.camFollowPos.y = -2050;

	new FlxTimer().start(0.1, function(tmr:FlxTimer)
	{
		remove(blackScreen);
		FlxG.sound.play(Paths.sound('events/week5/Lights_Turn_On'));
		game.camFollow.x += 200;
		FlxG.camera.focusOn(game.camFollow.getPosition());
		FlxG.camera.zoom = 1.5;

		new FlxTimer().start(0.8, function(tmr:FlxTimer)
		{
			camHUD.visible = true;
			remove(blackScreen);
			FlxTween.tween(FlxG.camera, {zoom: PlayState.defaultCamZoom}, 2.5, {
				ease: FlxEase.quadInOut,
				onComplete: function(twn:FlxTween)
				{
					game.startCountdown();
				}
			});
		});
	});
}
