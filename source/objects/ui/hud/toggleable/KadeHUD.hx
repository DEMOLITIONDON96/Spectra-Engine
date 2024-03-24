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
import objects.psychutils.AttachedSprite;
import states.PlayState;

class KadeHUD extends FlxSpriteGroup
{
	// bar variables
	public var scoreBar:FlxText;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	// mark variables
	public var cornerMark:FlxText; // engine mark at the upper right corner
	public var centerMark:FlxText; // song display name and difficulty at the center
	public var autoplayMark:FlxText; // botplay/autoplay indicator at the center

	// icons
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	//muckney health color lmao
	public var muckneyColors:Array<Int> = [];

	// other
	public var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop'; // fnf mods

	public var autoplaySine:Float = 0;

	public var timingsMap:Map<String, FlxText> = [];

	// display texts
	public var infoDisplay:String = "";
	public var diffDisplay:String = "";
	public var engineDisplay:String = 'Spectra Engine v0.2.0';

	public var timeTxt:FlxText;
	public var timeBar:FlxBar;
	public var timeBarBG:AttachedSprite;

	var songPercent:Float = 0;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(EngineTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		reloadHealthBar();
		add(healthBar);

		iconP1 = new HealthIcon(PlayState.boyfriend.characterData.icon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.opponent.characterData.icon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreBar = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, scoreDisplay, 20);
		scoreBar.setFormat(Paths.font("vcr"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreBar.scrollFactor.set();
		scoreBar.visible = !PlayState.bfStrums.autoplay;
		updateScoreText();
		add(scoreBar);

		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setFormat(Paths.font('vcr'), 12, FlxColor.WHITE);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		cornerMark.setPosition(0, FlxG.height * 0.97);
		add(cornerMark);

		centerMark = new FlxText(0, (Init.trueSettings.get('Downscroll') ? FlxG.height - 40 : 10), 0, '');
		centerMark.setFormat(Paths.font('vcr'), 24, FlxColor.WHITE);
		centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		centerMark.screenCenter(X);
		add(centerMark);

		timeTxt = new FlxText(0, 10, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.borderSize = 2;
		timeTxt.screenCenter(X);
		if(Init.trueSettings.get('Downscroll'))
			timeTxt.y = FlxG.height - 44;

		if(Init.trueSettings.get('Downscroll')) timeTxt.y = FlxG.height - 44;

		timeBar = new FlxBar(timeTxt.x - 300, (timeTxt.y + (timeTxt.height / 4)) + 4, LEFT_TO_RIGHT, 1000, 15, this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.numDivisions = 800;
		timeBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME, true, FlxColor.BLACK);

		add(timeBar);
		add(timeTxt);

		autoplayMark = new FlxText(-5, (Init.trueSettings.get('Downscroll') ? centerMark.y - 60 : centerMark.y + 60), FlxG.width - 800, '\n', 32);
		autoplayMark.setFormat(Paths.font("vcr"), 32, FlxColor.WHITE, CENTER);
		autoplayMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2.3);
		autoplayMark.screenCenter(X);
		autoplayMark.visible = PlayState.bfStrums.autoplay;

		// repositioning for it to not be covered by the receptors
		if (Init.trueSettings.get('Centered Notefield'))
		{
			if (Init.trueSettings.get('Downscroll'))
				autoplayMark.y = autoplayMark.y - 125;
			else
				autoplayMark.y = autoplayMark.y + 125;
		}
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
				textAsset.setFormat(Paths.font("vcr"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
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

	override public function update(elapsed:Float)
	{

		healthBar.percent = (PlayState.health * 50);
		
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.updateAnim(healthBar.percent);
		iconP2.updateAnim(100 - healthBar.percent);

		iconP1.bop(elapsed);
		iconP2.bop(elapsed);

		if (autoplayMark.visible)
		{
			autoplaySine += 180 * (elapsed / 4);
			autoplayMark.alpha = 1 - Math.sin((Math.PI * autoplaySine) / 80);
		}

		updateScoreText();

		var curTime:Float = Conductor.songPosition - Init.trueSettings.get('Offset');
		var songCalc:Float = (PlayState.songLength - curTime);
		var totalTime = PlayState.songLength;
		var secondsTotal:Int = Math.floor(songCalc / 1000);

		if (curTime < 0)
			curTime = 0;
		songPercent = (curTime / PlayState.songMusic.length);
		
		if (secondsTotal < 0)
			secondsTotal = 0;

		timeTxt.text = PlayState.SONG.song;
		timeBar.updateBar();
		timeBar.active = true;
		timeBar.update(elapsed);
	}

	public static var divider:String = " • ";

	private var markupDivider:String = '';

	public function updateScoreText()
	{
		scoreDisplay = 'Score: ' + ScoreUtils.score + ' | Combo Breaks: ${ScoreUtils.misses} | Accuracy: ${ScoreUtils.returnAccuracy()} | ${ScoreUtils.returnRankingStatus()}';
		scoreDisplay += '\n';

		scoreBar.text = scoreDisplay;

        scoreBar.screenCenter(X);

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
		if(Init.trueSettings.get('HUD Style') == "kade")
		PlayState.detailsSub = scoreBar.text;
		
		PlayState.updateRPC(false);
	}

	public function reloadHealthBar()
	{
		muckneyColors = [FlxG.random.int(0, 255), FlxG.random.int(0, 255), FlxG.random.int(0, 255)];
	
		healthBar.createFilledBar(FlxColor.fromRGB(muckneyColors[0], muckneyColors[1], muckneyColors[2]), 0xFF66FF33);
	}

	public function beatHit(curBeat:Int)
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			if (iconP1.canBounce)
			{
				iconP1.setGraphicSize(Std.int(iconP1.width + 30));
				iconP1.updateHitbox();
			}

			if (iconP2.canBounce)
			{
				iconP2.setGraphicSize(Std.int(iconP2.width + 30));
				iconP2.updateHitbox();
			}
			
		}
	}

	var scoreFlashFormat:FlxTextFormat;

	override function add(Object:FlxSprite):FlxSprite
		{
			if (Std.isOfType(Object, FlxText))
				cast(Object, FlxText).antialiasing = !Init.trueSettings.get('Disable Antialiasing');
			if (Std.isOfType(Object, FlxSprite))
				cast(Object, FlxSprite).antialiasing = !Init.trueSettings.get('Disable Antialiasing');
			return super.add(Object);
		}
}
