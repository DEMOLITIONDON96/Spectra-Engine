var halloweenBG:FNFSprite;

function onCreate()
{
	PlayState.defaultCamZoom = 1.05;
	PlayState.cameraSpeed = 1;

	halloweenBG = new FNFSprite(-200, -100);
	halloweenBG.frames = Paths.getSparrowAtlas('images/halloween_bg', 'data/stages/spooky');
	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	halloweenBG.animation.play('idle');
	halloweenBG.antialiasing = true;
	add(halloweenBG);
}

function charStagePos(boyfriend:Character, gf:Character, dad:Character)
{
	boyfriend.setPosition(770, 450);
	dad.setPosition(100, 100);
	gf.setPosition(300, 100);
}

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function onBeat(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
{
	if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
	{
		lightningStrikeBeat = curBeat;

		FlxG.sound.play(Paths.soundRandom('sounds/thunder', 'data/stages/spooky', 1, 2));

		if (!Init.trueSettings.get('Disable Flashing Lights'))
			halloweenBG.playAnim('lightning');

		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared'))
		{
			boyfriend.playAnim('scared', true);
			boyfriend.specialAnim = true;
			boyfriend.heyTimer = 0.6;
		}

		if (gf.animOffsets.exists('scared'))
		{
			gf.playAnim('scared', true);
			gf.specialAnim = true;
			gf.heyTimer = 0.6;
		}
	}
}
