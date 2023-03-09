package states.menus;

import base.dependency.Discord;
import base.song.Song;
import base.utils.ScoreUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.ui.menu.*;
import states.MusicBeatState;

class StoryMenu extends MusicBeatState
{
	var scoreText:FlxText;
	var curDifficulty:Int = 1;

	static var lastDifficulty:String = '';

	var weekCharacters:Array<Array<String>> = [];

	var txtWeekTitle:FlxText;

	static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		super.create();

		// load week data;
		Main.loadGameWeeks(true);

		if (Main.weeks == null)
			return Main.baseGame.forceSwitch(new MainMenu('[JSON ERROR] Weeks not Found!'));

		if (curWeek >= Main.weeks.length)
			curWeek = 0;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		#if DISCORD_RPC
		Discord.changePresence('CHOOSING A WEEK', 'Campaign Story Menu');
		#end

		// freeaaaky
		ForeverTools.resetMenuMusic();

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat(Paths.font("vcr"), 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		var weekID:Int = 0;
		for (i in 0...Main.weeks.length)
		{
			var gameWeek = Main.weeksMap.get(Main.weeks[i]);
			var lockedWeek:Bool = checkProgression(Main.weeks[i]);

			if (!lockedWeek && (!gameWeek.hideOnStory && !gameWeek.hideUntilUnlocked))
			{
				var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, gameWeek.attachedImage);
				weekThing.y += ((weekThing.height + 20) * weekID);
				weekThing.targetY = weekID;
				grpWeekText.add(weekThing);

				weekThing.screenCenter();
				weekThing.antialiasing = true;
				// weekThing.updateHitbox();

				// Needs an offset thingie
				if (lockedWeek)
				{
					var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
					lock.frames = ui_tex;
					lock.animation.addByPrefix('lock', 'lock');
					lock.animation.play('lock');
					lock.ID = i;
					lock.antialiasing = true;
					grpLocks.add(lock);
				}
				weekID++;
			}
		}

		var weekChars = Main.weeksMap.get(Main.weeks[curWeek]).characters;
		for (char in 0...3)
		{
			var list = weekChars[char];
			if (weekChars[char] == null)
				weekChars[char] = 'bf';

			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, list);
			weekCharacterThing.antialiasing = true;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 150);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		//
		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = true;
		difficultySelectors.add(sprDifficulty);

		if (lastDifficulty == '' || lastDifficulty == null)
			lastDifficulty = CoolUtil.defaultDifficulty;

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		add(difficultySelectors);

		// very unprofessional yoshubs!

		changeWeek();
		changeDifficulty();
		updateText();
	}

	inline function checkProgression(week:String):Bool
	{
		// here we check if the target week is locked;
		var weekProgress = Main.weeksMap.get(week);
		return weekProgress.startsLocked;
	}

	override function update(elapsed:Float)
	{
		var lerpVal = Main.framerateAdjust(0.5);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (scoreText != null)
			scoreText.text = "WEEK SCORE:" + lerpScore;

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			base.song.Conductor.songPosition = FlxG.sound.music.time;

		if (grpLocks != null)
		{
			grpLocks.forEach(function(lock:FlxSprite)
			{
				lock.y = grpWeekText.members[lock.ID].y;
			});
		}

		if (!movedBack)
		{
			if (!selectedWeek && (leftArrow != null && rightArrow != null))
			{
				if (Controls.getPressEvent("ui_up"))
					changeWeek(-1);
				else if (Controls.getPressEvent("ui_down"))
					changeWeek(1);

				if (Controls.getPressEvent("ui_right", "pressed"))
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (Controls.getPressEvent("ui_left", "pressed"))
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (Controls.getPressEvent("ui_right"))
					changeDifficulty(1);
				if (Controls.getPressEvent("ui_left"))
					changeDifficulty(-1);
			}

			if (Controls.getPressEvent("accept"))
				selectWeek();
		}

		if (Controls.getPressEvent("back") && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('base/menus/cancelMenu'));
			movedBack = true;
			Main.switchState(this, new MainMenu());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		var lockedWeek:Bool = checkProgression(Main.weeks[curWeek]);

		if (!lockedWeek)
		{
			if (!stopspamming)
			{
				FlxG.sound.play(Paths.sound('base/menus/confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				for (char in grpWeekCharacters.members)
					if (char.character != "" && char.storyChar.heyAnim != null)
						char.animation.play('hey');
				stopspamming = true;
			}

			var gameWeek = Main.weeksMap.get(Main.weeks[curWeek]);
			var weekSongs:Array<String> = [];

			// loop through week songs;
			for (song in 0...gameWeek.songs.length)
				weekSongs.push(gameWeek.songs[song].name);

			PlayState.storyPlaylist = (weekSongs != null ? weekSongs : ['test']);
			PlayState.gameplayMode = STORY;
			selectedWeek = true;

			var song:String = PlayState.storyPlaylist[0];
			var diff:String = '-' + CoolUtil.difficultyFromNumber(curDifficulty);

			if (!sys.FileSystem.exists(Paths.songJson(song, song + '-' + CoolUtil.defaultDifficulty.toLowerCase())))
				CoolUtil.defaultDifficulty = '';

			if (curDifficulty == 1)
				diff = CoolUtil.defaultDifficulty;

			if (song != null && diff != null)
			{
				PlayState.SONG = Song.loadFromJson(song.toLowerCase() + diff, song);
				CoolUtil.difficultyString = CoolUtil.difficultyFromNumber(curDifficulty);

				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = curWeek;
				PlayState.campaignScore = 0;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					Main.switchState(this, new PlayState());
				});
			}
			else
			{
				stopspamming = false;
				selectedWeek = false;
			}
		}
	}

	var difficultyTween:FlxTween;

	function changeDifficulty(change:Int = 0):Void
	{
		var week = Main.weeksMap.get(Main.weeks[curWeek]);
		CoolUtil.difficulties = week.difficulties == null ? CoolUtil.difficultyArray : week.difficulties;
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, CoolUtil.difficulties.length - 1);

		var coolDifficulty:String = CoolUtil.difficulties[curDifficulty];
		var diffGraphic:FlxGraphic = Paths.image('menus/base/storymenu/difficulties/' + CoolUtil.swapSpaceDash(coolDifficulty));

		if (sprDifficulty.graphic != diffGraphic)
		{
			sprDifficulty.loadGraphic(diffGraphic);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 3;
			sprDifficulty.y = leftArrow.y - 15;
			sprDifficulty.alpha = 0;

			if (difficultyTween != null)
				difficultyTween.cancel();
			difficultyTween = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07, {
				onComplete: function(twn:FlxTween)
				{
					difficultyTween = null;
				}
			});
		}
		lastDifficulty = coolDifficulty;

		intendedScore = ScoreUtils.getWeekScore(curWeek, curDifficulty);

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek = FlxMath.wrap(curWeek + change, 0, Main.weeks.length - 1);

		var lockedWeek:Bool = checkProgression(Main.weeks[curWeek]);
		difficultySelectors.visible = !lockedWeek;

		var storyName:String = Main.weeksMap.get(Main.weeks[curWeek]).storyName;
		txtWeekTitle.text = storyName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == 0 && !lockedWeek)
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

		changeDifficulty();
		updateText();
	}

	function updateText()
	{
		var gameWeek = Main.weeksMap.get(Main.weeks[curWeek]);
		var weekChars = gameWeek.characters;

		for (i in 0...grpWeekCharacters.length)
			grpWeekCharacters.members[i].createCharacter(weekChars[i], true);
		txtTracklist.text = "Tracks\n";

		var stringThing:Array<String> = [];

		for (i in 0...gameWeek.songs.length)
			stringThing.push(gameWeek.songs[i].name);

		for (i in stringThing)
			txtTracklist.text += "\n" + CoolUtil.dashToSpace(i);

		txtTracklist.text += "\n"; // pain
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		intendedScore = ScoreUtils.getWeekScore(curWeek, curDifficulty);
	}
}
