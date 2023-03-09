package states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.fonts.Alphabet;
import states.MusicBeatState.MusicBeatSubstate;
import states.menus.*;
import sys.thread.Mutex;
import sys.thread.Thread;

class PauseSubstate extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String>;
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	public static var toOptions:Bool = false;

	var mutex:Mutex;

	public function new(x:Float, y:Float, ?itemStack:Array<String>)
	{
		super();

		if (itemStack == null)
			itemStack = ['Resume', 'Restart Song', 'Exit to options', 'Exit to menu'];

		toOptions = false;

		menuItems = itemStack;

		if (PlayState.gameplayMode == CHARTING)
		{
			if (!menuItems.contains("Back to Charter"))
				menuItems.insert(2, "Back to Charter");
			if (!menuItems.contains("Leave Charter Mode"))
				menuItems.insert(3, "Leave Charter Mode");
		}

		mutex = new Mutex();
		Thread.create(function()
		{
			mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.volume = 0;
			mutex.release();
		});

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song) + ' [${CoolUtil.difficultyString}]';
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDeaths:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDeaths.text += "Blueballed: " + PlayState.deaths;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(Paths.font('vcr'), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		levelInfo.alpha = 0;
		levelDeaths.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = Controls.getPressEvent("ui_up");
		var downP = Controls.getPressEvent("ui_down");
		var accepted = Controls.getPressEvent("accept");

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					Main.switchState(this, new PlayState());
				case "Back to Charter":
					Main.switchState(this, new states.editors.OriginalChartingState());
				case "Leave Charter Mode":
					PlayState.gameplayMode = FREEPLAY;
					Main.switchState(this, new PlayState());
				case "Exit to options":
					toOptions = true;
					Main.switchState(this, new OptionsMenu());
				case "Exit to menu":
					PlayState.clearStored = true;
					PlayState.resetMusic();
					PlayState.deaths = 0;

					if (PlayState.gameplayMode == STORY)
						Main.switchState(this, new StoryMenu());
					else
						Main.switchState(this, new FreeplayMenu());
			}
		}

		if (pauseMusic != null && pauseMusic.playing)
		{
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}
	}

	override function destroy()
	{
		if (pauseMusic != null)
			pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		if (menuItems != null)
			curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;
		}
		//
	}
}
