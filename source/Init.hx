import base.Overlay;
import base.utils.ScoreUtils;
import flixel.FlxG;
import flixel.FlxState;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;

/** 
 * Enumerator for settingtypes
**/
enum SettingTypes
{
	Checkmark;
	Selector;
}

enum SettingState
{
	FORCED; // forced at the default value, doesn't show up on the settings menu;
	NOT_FORCED;
}

/**
 * This is the initialisation class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
 * A lot of this code is just going to be similar to the flixel templates' colorblind filters because I wanted to add support for those as I'll
 * most likely need them for skater, and I think it'd be neat if more mods were more accessible.
**/
class Init extends FlxState
{
	/*
		Okay so here we'll set custom settings. As opposed to the previous options menu, everything will be handled in here with no hassle.
		This will read what the second value of the key's array is, and then it will categorise it, telling the game which option to set it to.

		0 - boolean, true or false checkmark
		1 - choose string
		2 - choose number (for fps so its low capped at 30)
		3 - offsets, this is unused but it'd bug me if it were set to 0
		might redo offset code since I didnt make it and it bugs me that it's hardcoded the the last part of the controls menu
	 */
	public static var gameSettings:Map<String, Dynamic> = [
		'Downscroll' => [
			false,
			Checkmark,
			'Whether to have the strumline vertically flipped during Gameplay.',
			NOT_FORCED
		],
		'Controller Mode' => [
			false,
			Checkmark,
			'Whether to use a controller instead of a keyboard to play.',
			FORCED
		],
		'Auto Pause' => [
			true,
			Checkmark,
			'Whether to pause the game automatically if the window is unfocused.',
			NOT_FORCED
		],
		'FPS Counter' => [true, Checkmark, 'Whether to display the FPS counter.', NOT_FORCED],
		'Memory Counter' => [
			true,
			Checkmark,
			'Whether to display approximately how much Memory is being used.',
			NOT_FORCED
		],
		'Reduced Movements' => [
			false,
			Checkmark,
			'Whether to reduce movements, like icons bouncing or beat zooms during Gameplay.',
			NOT_FORCED
		],
		'Stage Opacity' => [
			Checkmark,
			Selector,
			'Darkens non-UI elements, useful if you find the characters and backgrounds distracting.',
			NOT_FORCED
		],
		'Colored Health Bar' => [
			true,
			Checkmark,
			'Whether the Health Bar should be colored after the Icons.',
			NOT_FORCED,
		],
		'Counter' => [
			'None',
			Selector,
			'Choose whether you want somewhere to display your judgements, and where you want it.',
			NOT_FORCED,
			['None', 'Left', 'Right']
		],
		'Display Accuracy' => [true, Checkmark, 'Whether to display your accuracy on screen.', NOT_FORCED],
		'Disable Antialiasing' => [
			false,
			Checkmark,
			'Whether to disable Anti-Aliasing, helps in improving performance.',
			NOT_FORCED
		],
		'Disable Flashing Lights' => [
			false,
			Checkmark,
			'Whether to disable Flashing Lights on Menus, check this if you are sensitive to those.',
			NOT_FORCED
		],
		'Disable Screen Shaders' => [
			false,
			Checkmark,
			'Whether to disable Screen Shaders during gameplay, helps in improving performance.',
			NOT_FORCED
		],
		'No Camera Note Movement' => [
			false,
			Checkmark,
			'When enabled, left and right notes no longer move the camera.',
			NOT_FORCED
		],
		// custom ones lol
		'Offset' => [Checkmark, 3],
		'Filter' => [
			'none',
			Selector,
			'Choose a filter for colorblindness.',
			#if neko FORCED, #else NOT_FORCED, #end
			['none', 'Deuteranopia', 'Protanopia', 'Tritanopia']
		],
		"Clip Style" => [
			'stepmania',
			Selector,
			"Chooses a style for hold note clippings; StepMania: Holds under Receptors; FNF: Holds over receptors",
			NOT_FORCED,
			['StepMania', 'FNF']
		],
		"UI Skin" => [
			'default',
			Selector,
			'Choose a UI Skin for judgements, combo, etc.',
			NOT_FORCED,
			''
		],
		"Note Skin" => [
			'default',
			Selector,
			'Choose a note skin, also affects note splashes.',
			NOT_FORCED,
			''
		],
		"Framerate Cap" => [60, Selector, 'Define your maximum FPS.', #if neko FORCED #else NOT_FORCED #end],
		"Arrow Opacity" => [
			80,
			Selector,
			"Sets the opacity for the arrows at the top/bottom of the screen.",
			NOT_FORCED
		],
		"Hold Opacity" => [
			60,
			Selector,
			"Sets the opacity for the Hold Notes... Huh, why isnt the trail cut off?",
			NOT_FORCED
		],
		"Splash Opacity" => [
			60,
			Selector,
			"Sets the opacity for the Note Splashes, shown when hitting \"Sick!\" judgements on notes.",
			NOT_FORCED
		],
		'Accuracy Hightlight' => [
			true,
			Checkmark,
			"Whether to have a color hightlight based on your ranking when hitting a note.",
			NOT_FORCED
		],
		'Ghost Tapping' => [
			true,
			Checkmark,
			"Enables Ghost Tapping, allowing you to press inputs without missing.",
			NOT_FORCED
		],
		'Centered Notefield' => [false, Checkmark, "Center the notes, disables the enemy's notes."],
		'Skip Text' => [
			'freeplay only',
			Selector,
			'Decides whether to skip cutscenes and dialogue in gameplay. May be always, only in Freeplay, or never.',
			NOT_FORCED,
			['never', 'freeplay only', 'always']
		],
		'Fixed Judgements' => [
			false,
			Checkmark,
			"Fixes the judgements to the camera instead of to the world itself, making them easier to read.",
			NOT_FORCED
		],
		'Simply Judgements' => [
			false,
			Checkmark,
			"Simplifies the judgement animations, displaying only one judgement sprite at a time.",
			NOT_FORCED
		],
		'Judgement Recycling' => [
			true,
			Checkmark,
			"Recycles judgements and combo rather than adding one every note hit, may cause layering issues.",
			NOT_FORCED
		],
		"Camera Position" => [
			'none',
			Selector,
			"Chooses where the camera should stay; None = move depending on sections.",
			NOT_FORCED,
			['none', 'bf', 'gf', 'dad', 'center']
		],
		"Timing Preset" => [
			'forever',
			Selector,
			"Chooses what preset should be used for Judgement Timing Windows.",
			NOT_FORCED,
			['forever', 'funkin', 'judge four', 'itg']
		],
		"Display Miss Judgement" => [
			true,
			Checkmark,
			"Whether to display a miss judgement when missing notes.",
			NOT_FORCED
		],
		"Display Timings" => [
			false,
			Checkmark,
			"Whether to display how early/late you hit a judgement on a note.",
			NOT_FORCED
		],
	];

	public static var trueSettings:Map<String, Dynamic> = [];
	public static var settingsDescriptions:Map<String, String> = [];

	public static var filters:Array<BitmapFilter> = []; // the filters the game has active
	/// initalise filters here
	#if !neko
	public static var gameFilters:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}> = [
		"Deuteranopia" => {
			var matrix:Array<Float> = [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Protanopia" => {
			var matrix:Array<Float> = [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		},
		"Tritanopia" => {
			var matrix:Array<Float> = [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				   0,    0,    0, 1, 0,
			];
			{filter: new ColorMatrixFilter(matrix)}
		}
	];
	#end

	override public function create():Void
	{
		FlxG.save.bind('gameSettings', "Feather");

		// load controls and highscore
		ScoreUtils.loadScores();
		loadControls();

		loadSettings();

		Main.updateFramerate(trueSettings.get("Framerate Cap"));

		#if !neko
		// apply saved filters
		FlxG.game.setFilters(filters);
		#end

		// Some additional changes to default HaxeFlixel settings, both for ease of debugging and usability.
		FlxG.fixedTimestep = false; // This ensures that the game is not tied to the FPS
		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = false; // Hide mouse on start

		Main.switchState(this, cast Type.createInstance(Main.game.initialState, []));
	}

	public static function loadSettings():Void
	{
		FlxG.save.bind('gameSettings', "Feather");

		// set the true settings array
		// only the first variable will be saved! the rest are for the menu stuffs

		// IF YOU WANT TO SAVE MORE THAN ONE VALUE MAKE YOUR VALUE AN ARRAY INSTEAD
		for (setting in gameSettings.keys())
			trueSettings.set(setting, gameSettings.get(setting)[0]);

		// NEW SYSTEM, INSTEAD OF REPLACING THE WHOLE THING I REPLACE EXISTING KEYS
		// THAT WAY IT DOESNT HAVE TO BE DELETED IF THERE ARE SETTINGS CHANGES
		if (FlxG.save.data.settings != null)
		{
			var settingsMap:Map<String, Dynamic> = FlxG.save.data.settings;
			for (singularSetting in settingsMap.keys())
				if (gameSettings.get(singularSetting) != null && gameSettings.get(singularSetting)[3] != FORCED)
					trueSettings.set(singularSetting, FlxG.save.data.settings.get(singularSetting));
		}

		// lemme fix that for you
		setDefaultValue("Framerate Cap", 0, 360, 60);
		setDefaultValue("Stage Opacity", 0, 100, 100);
		setDefaultValue("Arrow Opacity", 0, 1, 80);
		setDefaultValue("Hold Opacity", 0, 1, 60);
		setDefaultValue("Splash Opacity", 0, 1, 60);

		reloadUISkins();

		saveSettings();

		updateAll();

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}

	public static function setDefaultValue(setting:String, valueMin:Float, valueMax:Float, valueDef:Float)
	{
		if (!Std.isOfType(trueSettings.get(setting), Int) || trueSettings.get(setting) < valueMin || trueSettings.get(setting) > valueMax)
			trueSettings.set(setting, valueDef);
	}

	public static function loadControls():Void
	{
		FlxG.save.bind('gameControls', "Feather");

		if (FlxG.save.data.actionBinds != null)
			Controls.actions = FlxG.save.data.actionBinds;

		saveControls();
	}

	public static function saveSettings():Void
	{
		// ez save lol
		FlxG.save.bind('gameSettings', "Feather");
		FlxG.save.data.settings = trueSettings;
		FlxG.save.flush();

		updateAll();
	}

	public static function saveControls():Void
	{
		FlxG.save.bind('gameControls', "Feather");
		FlxG.save.data.actionBinds = Controls.actions;
		FlxG.save.flush();
	}

	public static function updateAll()
	{
		FlxG.autoPause = trueSettings.get('Auto Pause');

		Overlay.updateDisplayInfo(trueSettings.get('FPS Counter'), trueSettings.get('Memory Counter'));

		Main.updateFramerate(trueSettings.get("Framerate Cap"));

		if (Controls.actions.exists("volUp"))
			FlxG.sound.volumeUpKeys = Controls.actions.get("volUp");
		if (Controls.actions.exists("volDown"))
			FlxG.sound.volumeDownKeys = Controls.actions.get("volDown");
		if (Controls.actions.exists("volMute"))
			FlxG.sound.muteKeys = Controls.actions.get("volMute");

		///*
		filters = [];

		#if !neko
		FlxG.game.setFilters(filters);

		var theFilter:String = trueSettings.get('Filter');
		if (gameFilters.get(theFilter) != null)
		{
			var realFilter = gameFilters.get(theFilter).filter;

			if (realFilter != null)
				filters.push(realFilter);
		}

		FlxG.game.setFilters(filters);
		#end
		// */
	}

	public static function reloadUISkins()
	{
		// 'hardcoded' ui skins
		gameSettings.get("UI Skin")[4] = CoolUtil.returnAssetsLibrary('UI');
		if (!gameSettings.get("UI Skin")[4].contains(trueSettings.get("UI Skin")))
			trueSettings.set("UI Skin", 'default');
		gameSettings.get("Note Skin")[4] = CoolUtil.returnAssetsLibrary('notetypes/default/skins', 'assets/data');
		if (!gameSettings.get("Note Skin")[4].contains(trueSettings.get("Note Skin")))
			trueSettings.set("Note Skin", 'default');
	}
}
