package states.substates;

import base.song.Conductor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.Character;
import states.MusicBeatState.MusicBeatSubstate;

class GameOverSubstate extends MusicBeatSubstate
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;

	public static var bfType:String = 'bf-dead';
	public static var deathNoise:String = 'fnf_loss_sfx';
	public static var deathTrack:String = 'gameOver';
	public static var leaveTrack:String = 'gameOverEnd';
	public static var trackBpm:Float = 100;

	public static function resetDeathVariables()
	{
		bfType = 'bf-dead';
		deathNoise = 'fnf_loss_sfx';
		deathTrack = 'gameOver';
		leaveTrack = 'gameOverEnd';
		trackBpm = 100;
	}

	public function new(x:Float, y:Float)
	{
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend();
		bf.setCharacter(x, y + PlayState.boyfriend.height, bfType);
		add(bf);

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		Conductor.changeBPM(trackBpm);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.getPressEvent("accept"))
			endBullshit();

		if (Controls.getPressEvent("back"))
		{
			PlayState.clearStored = true;
			FlxG.sound.music.stop();
			PlayState.deaths = 0;

			if (PlayState.gameplayMode == STORY)
				Main.switchState(this, new states.menus.StoryMenu());
			else
				Main.switchState(this, new states.menus.FreeplayMenu());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music(deathTrack));

		// if (FlxG.sound.music.playing)
		//	Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(leaveTrack));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
