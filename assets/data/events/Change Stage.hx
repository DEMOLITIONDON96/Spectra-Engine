function loadedEventAction(params)
{
	var newStage:Stage = new Stage(params[0]);
	PlayState.stageMap.set(params[0], newStage);
}

function eventTrigger(params)
{
	var timer:Float = Std.parseFloat(params[1]);
	if (Math.isNaN(timer))
		timer = 0.0001;

	new FlxTimer().start(timer, function(tmr:FlxTimer)
	{
		PlayState.stageBuild.setStage(params[0]);
		game.repositionChars();

		PlayState.curStage = params[0];

		if (PlayState.stageMap.get(params[0]) != null)
			PlayState.stageMap.remove(params[0]);
	});
}

function returnDescription()
	return "Sets the current Stage to a new one\nValue 1: New Stage\nValue 2: Delay to Change Stages (in Milliseconds)";
