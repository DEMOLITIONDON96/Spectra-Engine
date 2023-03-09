function songCutscene()
{
	FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'data/stages/school/sounds'));
	new FlxTimer().start(1, function(tmr:FlxTimer)
	{
		game.callTextbox();
	});
}
