package states;

import base.dependency.Discord;
import base.song.Conductor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import objects.fonts.Alphabet;
import openfl.Assets;
import states.MusicBeatState;

/**
 * I hate this state so much that I gave up after trying to rewrite it 3 times and just copy pasted the original code
 * with like minor edits so it actually runs in forever engine. I'll redo this later, I've said that like 12 times now
 * 
 * I genuinely fucking hate this code no offense ninjamuffin I just dont like it and I don't know why or how I should rewrite it
**/
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var colorTest:Float = 0;

	override public function create():Void
	{
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();

		startIntro();
	}

	var gameLogo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	var initLogowidth:Float = 0;
	var newLogoScale:Float = 0;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	function startIntro()
	{
		if (!initialized)
		{
			///*
			#if DISCORD_RPC
			Discord.changePresence('TITLE SCREEN', 'Main Menu');
			#end

			ForeverTools.resetMenuMusic(true);
		}

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		gameLogo = new FlxSprite(-10, 10);
		gameLogo.loadGraphic(Paths.image('menus/base/title/logo'));
		gameLogo.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		initLogowidth = gameLogo.width;
		newLogoScale = gameLogo.scale.x;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('menus/base/title/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(gameLogo);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('menus/base/title/titleEnter');
		var animFrames:Array<FlxFrame> = [];
		@:privateAccess {
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}

		if (animFrames.length > 0)
		{
			newTitle = true;

			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', !Init.trueSettings.get('Disable Flashing Lights') ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			newTitle = false;

			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.antialiasing = !Init.trueSettings.get('Disable Antialiasing');
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menus/base/title/newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	inline function getIntroTextShit():Array<Array<String>>
	{
		var swagGoodArray:Array<Array<String>> = [[]];
		if (Assets.exists(Paths.txt('data/introText')))
		{
			var fullText:String = Assets.getText(Paths.txt('data/introText'));
			var firstArray:Array<String> = fullText.split('\n');

			for (i in firstArray)
				swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		gameLogo.scale.x = FlxMath.lerp(newLogoScale, gameLogo.scale.x, 0.95);
		gameLogo.scale.y = FlxMath.lerp(newLogoScale, gameLogo.scale.y, 0.95);

		var pressedEnter:Bool = Controls.getPressEvent("accept");

		if (newTitle)
		{
			titleTimer += CoolUtil.boundTo(elapsed, 0, 1);
			if (titleTimer > 2)
				titleTimer -= 2;
		}

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;

				timer = FlxEase.quadInOut(timer);

				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}

			if (FlxG.keys.justPressed.ESCAPE && !pressedEnter)
			{
				FlxG.sound.music.fadeOut(0.3);
				FlxG.camera.fade(FlxColor.BLACK, 0.5, false, function()
				{
					#if DISCORD_RPC
					Discord.shutdownRPC();
					#end
					Sys.exit(0);
				}, false);
			}

			if (pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				titleText.animation.play('press');

				if (!Init.trueSettings.get('Disable Flashing Lights'))
					FlxG.camera.flash(FlxColor.WHITE, 1);

				FlxG.sound.play(Paths.sound('base/menus/confirmMenu'), 0.7);

				transitioning = true;
				if (logoTween != null)
					logoTween.cancel();

				gameLogo.setGraphicSize(Std.int(initLogowidth * 1.15));

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					Main.switchState(this, new states.menus.MainMenu());
				});
			}
		}

		// hi game, please stop crashing its kinda annoyin, thanks!
		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	inline function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	inline function addMoreText(text:String)
	{
		if (!skippedIntro)
		{
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	inline function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var logoTween:FlxTween;

	override function beatHit()
	{
		super.beatHit();

		if (gameLogo != null && !transitioning)
		{
			if (logoTween != null)
				logoTween.cancel();
			gameLogo.scale.set(1, 1);
			logoTween = FlxTween.tween(gameLogo, {'scale.x': 0.9, 'scale.y': 0.9}, 60 / Conductor.bpm, {ease: FlxEase.expoOut});
		}

		if (gfDance != null)
		{
			danceLeft = !danceLeft;
			gfDance.animation.play('dance' + (danceLeft ? 'Left' : 'Right'));
		}

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['ninjamuffin', 'phantomArcade', 'kawaisprite', 'evilsker']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('newgrounds');
				ngSpr.visible = true;
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText("Funkin'");
			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			if (!Init.trueSettings.get('Disable Flashing Lights'))
				FlxG.camera.flash(FlxColor.WHITE, 4);
			deleteCoolText();
			remove(credGroup);
			skippedIntro = true;
		}
		//
	}
}
