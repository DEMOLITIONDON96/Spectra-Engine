function beatHit(curBeat)
{
	if (curBeat >= 168 && curBeat < 200 && !Init.trueSettings.get('Reduced Movements') && FlxG.camera.zoom < 1.35)
	{
		FlxG.camera.zoom += 0.015;
		for (hud in allUIs)
			hud.zoom += 0.03;
	}
}
