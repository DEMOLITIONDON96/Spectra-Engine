package objects.ui.hud.toggleable;

import base.song.Conductor;
import base.utils.ScoreUtils;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import states.PlayState;

class SpectraHUD extends FlxSpriteGroup
{
	// bar variables
	public var scoreBar:FlxText;
	public var songTime:FlxText;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var timeBarBG:FlxSprite;
	public var timeBar:FlxBar;
	public var songPercent:Float = 0;

	// mark variables
	public var cornerMark:FlxText; // engine mark at the upper right corner
	public var centerMark:FlxText; // song display name and difficulty at the center
	public var autoplayMark:FlxText; // botplay/autoplay indicator at the center
	public var playingTxt:FlxText;
	public var botTxtArray:Array<Any> = [
		"AUTOPLAY",
		"BOTPLAY",
		"BURN IN HELL",
		"hi nikoru lol",
		"YOU'RE FUCKING CHEATING!",
		"what the rat doin?",
		"2 WORDS: GIT GUD",
		"THIS AIN'T PSYCH ANYMORE, IT'S OPTIMIZED NOW",
		"JAMMING TO THE SONG",
		"Hope you know this mod's an hour long now.",
		"you're just using the botplay key to see all these random messages, aren't you?",
		"YOU FUCKING SUCK AT RHYTHM GAMES LMFAO",
		"POV: YOU'RE TOO LAZY TO ACTUALLY PLAY THE GAME",
		"What's up guys! <Insert Generic YouTube Name Here> back again with yet another cool FNF mod called Funkin dot avi version 2 point O!",
		"eyeless mouse is real.",
		"BOO!",
		"IT'S ABOUT DRIVE, IT'S ABOUT POWER",
		"WE STAY HUNGRY, WE DEVOUR",
		"i'm fucking high on crack man...",
		"ALL OF OUR FOOD KEEPS BLOWING UP",
		"sample text",
		"I did ur mom 2023",
		"WHAT THE FUCK IS WRONG WITH YOU?",
		"I think you deserve this loop curse more than Mickey",
		"no.",
		"If you're doing this on Malfunction, you're gonna die lmao",
		"i bet you fail to the tutorial still...",
		"I will personally skin you <3",
		"BOTPLAY 2: ELECTRIC BOOGALOO",
		"five nights at freddy's",
		"Hi guys, Satan here, and welcome to Jackass *snaps Mickey in half*"
	];

	// icons
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	// other
	public var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop'; // fnf mods

	public var autoplaySine:Float = 0;

	public var timingsMap:Map<String, FlxText> = [];

	// display texts
	public var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song);
	public var diffDisplay:String = '[${CoolUtil.difficultyString}]';
	public var engineDisplay:String = "Spectra Engine v0.2.0";

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();
		
		if (Init.trueSettings.get('Downscroll')) songTime = new FlxText(-108, 655, 400, "", 32); else songTime = new FlxText(-108, 100, 400, "", 32);
		songTime.setFormat(Paths.font("VanillaExtractRegular"), 13, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (!Init.trueSettings.get('Centered Notefield')) songTime.screenCenter(X);
		songTime.scrollFactor.set();
		songTime.borderSize = 2;
	
		/*add(timeBarBG);
		add(timeBar);*/
		add(songTime);

		// le healthbar setup
		healthBarBG = new FlxSprite(0,
			0).loadGraphic(Paths.image(EngineTools.returnSkinAsset('healthBar-Long', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.y = FlxG.height * 0.95;
		healthBarBG.x = 230;
		//healthBarBG.scale.set(1.6, 1);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);
		if(Init.trueSettings.get('Downscroll')) healthBarBG.y = 0.05 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		reloadHealthBar();
		add(healthBar);

		//healthBarIcon = new FlxSprite();

		iconP1 = new HealthIcon(PlayState.boyfriend.characterData.icon, true);
		iconP1.scale.set(0.78, 0.78);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.opponent.characterData.icon, false);
		iconP2.scale.set(0.78, 0.78);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(healthBarBG.x + 300, (Init.trueSettings.get('Downscroll') ? Math.floor(healthBarBG.y + 35) : Math.floor(healthBarBG.y - 35)), 650, scoreDisplay);
		scoreBar.setFormat(Paths.font('VanillaExtractRegular'), 14, FlxColor.WHITE, RIGHT);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreBar.visible = !PlayState.bfStrums.autoplay;
		updateScoreText();
		add(scoreBar);
	
		// F.AVI V2 Watermark
		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		if (Init.trueSettings.get('Downscroll')) cornerMark.setPosition(0, 685); else cornerMark.setPosition(0, 8);
		cornerMark.screenCenter(X);
		add(cornerMark);

		// i am very original
		playingTxt = new FlxText(50, (Init.trueSettings.get('Downscroll') ? FlxG.height - 120 : 50), 0, 'Playing:');
		playingTxt.setFormat(Paths.font('VanillaExtractRegular'), 16, FlxColor.WHITE);
		playingTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		playingTxt.alpha = 0.4;
		if (!Init.trueSettings.get('Centered Notefield')) playingTxt.screenCenter(X);
		add(playingTxt);

		centerMark = new FlxText(50, (Init.trueSettings.get('Downscroll') ? FlxG.height - 100 : 70), 0, '$infoDisplay');
		centerMark.setFormat(Paths.font('VanillaExtractRegular'), 24, FlxColor.WHITE);
		centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		centerMark.alpha = 0.4;
		if (!Init.trueSettings.get('Centered Notefield')) centerMark.screenCenter(X);
		add(centerMark);

		autoplayMark = new FlxText(scoreBar.x + 150, scoreBar.y, FlxG.width - 780, '', 32);
		autoplayMark.text = '[${botTxtArray[FlxG.random.int(0, botTxtArray.length-1)]}]';
		autoplayMark.setFormat(Paths.font("VanillaExtractRegular"), 14, FlxColor.WHITE, RIGHT);
		autoplayMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
		//autoplayMark.screenCenter(X);
		autoplayMark.visible = PlayState.bfStrums.autoplay;

		/*// repositioning for it to not be covered by the receptors
		if (Init.trueSettings.get('Centered Notefield'))
		{
			if (Init.trueSettings.get('Downscroll'))
				autoplayMark.y = autoplayMark.y - 125;
			else
				autoplayMark.y = autoplayMark.y + 125;
		}*/
		add(autoplayMark);

		// counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			var judgementNameArray:Array<String> = [];
			for (i in 0...ScoreUtils.judges.length)
				judgementNameArray.insert(i, ScoreUtils.judges[i].name);
			judgementNameArray.sort(sortJudgements);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("VanillaExtractRegular"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}

		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortJudgements(Obj1:String, Obj2:String):Int
	{
		for (i in 0...ScoreUtils.judges.length)
			return FlxSort.byValues(FlxSort.ASCENDING, i, i);
		return 0;
	}

	var left = (Init.trueSettings.get('Counter') == 'Left');

	public var secondsTotal:Int;

	override public function update(elapsed:Float)
	{
		if (PlayState.SONG.song == "Birthday")
			muckneyHealthColorShitLol();

		// pain, this is like the 7th attempt
		var silly = PlayState.SONG.song == 'Mercy' ? PlayState.main.smoothyHealth : PlayState.health;
		healthBar.percent = (silly * 50); // so it doesn't make the mechanic worthless

		var iconOffset:Int = 26;

			iconP1.x = healthBar.x + (healthBar.width * percent) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
			iconP2.x = healthBar.x + (healthBar.width * percent) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;	
		} else {
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}

		if (autoplayMark.visible)
			autoplaySine += 180 * (elapsed / 4);
			autoplayMark.alpha = 1 - Math.sin((Math.PI * autoplaySine) / 80);
		}

		var curTime:Float = Conductor.songPosition;
		if (curTime < 0)
			curTime = 0;

		var songCalc:Float = curTime;

		secondsTotal = Math.floor(songCalc / 1000);
		if (secondsTotal < 0)
			secondsTotal = 0;
		else if (secondsTotal >= Math.floor(PlayState.songLength / 1000))
			secondsTotal = Math.floor(PlayState.songLength / 1000);

		//songPercent = (secondsTotal / curTime); // this shit won't work no matter what you do aaaaaa.

		songTime.text = '${FlxStringUtil.formatTime(secondsTotal, false)} / ${FlxStringUtil.formatTime(Math.floor(PlayState.songLength / 1000), false)}';
		//timeBar.percent = (secondsTotal / Math.floor(PlayState.songLength / 1000)); // sad, it won't work
	}

	public static var divider:String = " / ";

	private var markupDivider:String = '';

	public function updateScoreText()
	{
		if (ScoreUtils.notesHit > 0 && Init.trueSettings.get('Accuracy Hightlight'))
			markupDivider = '°';

		scoreDisplay = 'Score: ' + ScoreUtils.score;

		if (Init.trueSettings.get('Display Accuracy'))
		{
			scoreDisplay += divider + markupDivider + 'Accuracy: ${ScoreUtils.returnAccuracy()}' + markupDivider;
			scoreDisplay += markupDivider + ScoreUtils.returnRankingStatus() + markupDivider;
			scoreDisplay += divider + 'Combo Breaks: ${ScoreUtils.misses}';
		}
		scoreDisplay += '\n';

		scoreBar.text = scoreDisplay;

		if (Init.trueSettings.get('Accuracy Hightlight'))
			if (ScoreUtils.notesHit > 0)
				scoreBar.applyMarkup(scoreBar.text, [new FlxTextFormatMarkerPair(scoreFlashFormat, markupDivider)]);

		//scoreBar.screenCenter(X);

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${ScoreUtils.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		if(Init.trueSettings.get('HUD Style') == "spectra")
		PlayState.detailsSub = scoreBar.text;
		
		PlayState.updateRPC(false);
	}

	public function muckneyHealthColorShitLol()
	{
		muckneyColors = [FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255)];

		if (!Init.trueSettings.get('Colored Health Bar'))
			healthBar.createFilledBar(FlxColor.fromRGB(muckneyColors[0], muckneyColors[1], muckneyColors[2]), 0xFF66FF33 - 0xFFFF0000);
		else
			healthBar.createFilledBar(FlxColor.fromRGB(muckneyColors[0], muckneyColors[1], muckneyColors[2]),
				FlxColor.fromRGB(Std.int(colorPlayer[0]), Std.int(colorPlayer[1]), Std.int(colorPlayer[2])));
				FlxColor.fromRGB(Std.int(colorPlayer[0]), Std.int(colorPlayer[1]), Std.int(colorPlayer[2])));
	}

	public function beatHit(curBeat:Int)
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			if (curBeat % ((PlayState.SONG.song == 'Twisted Grins') ? 2 : 1) == 0)
			{
				if (iconP1.canBounce)
					{
						iconP1.scale.set(1.2, 1.2);
	}
}
