package base.dependency;

import flixel.FlxSprite;

/**
 * Feather Dependencies unifies ScriptHandler and Events into a single class;
 * it handle Script-related variables and functions and can be modified as you wish;
 * 
 * this class is subjective of change;
**/
class FeatherSprite extends FlxSprite
{
	public var parentSprite:FlxSprite;

	public var addX:Float = 0;
	public var addY:Float = 0;
	public var addAngle:Float = 0;
	public var addAlpha:Float = 0;

	public var copyParentAngle:Bool = false;
	public var copyParentAlpha:Bool = false;
	public var copyParentVisib:Bool = false;

	public function new(fileName:String, ?fileFolder:String, ?fileAnim:String, ?looped:Bool = false)
	{
		super();

		if (fileName != null)
		{
			if (fileAnim != null)
			{
				frames = Paths.getSparrowAtlas(fileName, fileFolder);
				animation.addByPrefix('static', fileAnim, 24, looped);
				animation.play('static');
			}
			else
			{
				loadGraphic(Paths.image(fileName, fileFolder));
			}
			antialiasing = !Init.trueSettings.get('Disable Antialiasing');
			scrollFactor.set();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// set parent sprite stuffs;
		if (parentSprite != null)
		{
			setPosition(parentSprite.x + addX, parentSprite.y + addY);
			scrollFactor.set(parentSprite.scrollFactor.x, parentSprite.scrollFactor.y);

			if (copyParentAngle)
				angle = parentSprite.angle + addAngle;

			if (copyParentAlpha)
				alpha = parentSprite.alpha * addAlpha;

			if (copyParentVisib)
				visible = parentSprite.visible;
		}
	}
}

class ScriptHandler extends SScript
{
	// this just kinda sets up script variables and such;
	// probably gonna clean it up later;
	public function new(file:String, ?preset:Bool = true)
	{
		super(file, preset);
		traces = false;
	}

	override public function preset():Void
	{
		super.preset();

		// here we set up the built-in imports
		// these should work on *any* script;

		// CLASSES (HAXE)
		set('Type', Type);
		set('Math', Math);
		set('Std', Std);
		set('Date', Date);

		// CLASSES (FLIXEL);
		set('FlxG', flixel.FlxG);
		set('FlxBasic', flixel.FlxBasic);
		set('FlxObject', flixel.FlxObject);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxSound', flixel.system.FlxSound);
		set('FlxSort', flixel.util.FlxSort);
		set('FlxStringUtil', flixel.util.FlxStringUtil);
		set('FlxState', flixel.FlxState);
		set('FlxSubState', flixel.FlxSubState);
		set('FlxText', flixel.text.FlxText);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxTrail', flixel.addons.effects.FlxTrail);
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);

		// CLASSES (FUNKIN);
		set('Alphabet', objects.fonts.Alphabet);
		set('Boyfriend', objects.Character.Boyfriend);
		set('CoolUtil', base.utils.CoolUtil);
		set('Character', objects.Character);
		set('Conductor', base.song.Conductor);
		set('HealthIcon', objects.ui.HealthIcon);
		set('Receptor', objects.ui.Strumline.Receptor);
		set('Strumline', objects.ui.Strumline);
		set('game', states.PlayState.main);
		set('PlayState', states.PlayState);
		set('Paths', Paths);

		// CLASSES (FOREVER);
		set('Init', Init);
		set('Main', Main);
		set('Stage', objects.Stage);
		set('FNFSprite', base.utils.FNFUtils.FNFSprite);
		set('ForeverAssets', base.dependency.ForeverDeps.ForeverAssets);
		set('ForeverTools', base.dependency.ForeverDeps.ForeverTools);

		// CLASSES (FEATHER);
		set('FeatherSprite', base.dependency.FeatherSprite);
		set('Controls', base.Controls);

		// OTHER
		set('GraphicsShader', openfl.display.GraphicsShader);
		set('ShaderFilter', openfl.filters.ShaderFilter);

		// ENUMS AND TYPEDEFINES;
		set('GameMode', states.PlayState.GameMode);
		set('isStoryMode', states.PlayState.gameplayMode == STORY);
		set('isChartingMode', states.PlayState.gameplayMode == CHARTING);
		set('isFreeplayMode', states.PlayState.gameplayMode == FREEPLAY);

		#if windows
		set('platform', 'windows');
		#elseif linux
		set('platform', 'linux');
		#elseif mac
		set('platform', 'mac');
		#elseif android
		set('platform', 'android');
		#elseif html5
		set('platform', 'html5');
		#elseif flash
		set('platform', 'flash');
		#else
		set('platform', 'unknown');
		#end
	}

	public static function callScripts(moduleArray:Array<ScriptHandler>):Array<ScriptHandler>
	{
		var dirs:Array<Array<String>> = [
			CoolUtil.absoluteDirectory('scripts'),
			CoolUtil.absoluteDirectory('songs/${CoolUtil.swapSpaceDash(states.PlayState.SONG.song.toLowerCase())}')
		];

		var pushedModules:Array<String> = [];

		for (directory in dirs)
		{
			for (script in directory)
			{
				if (directory != null && directory.length > 0)
				{
					for (ext in Paths.scriptExts)
					{
						if (!pushedModules.contains(script) && script != null && script.endsWith('.$ext'))
						{
							try
							{
								moduleArray.push(new ScriptHandler(script));
								// trace('new module loaded: ' + script);
								pushedModules.push(script);
							}
							catch (e)
							{
								//
								Main.baseGame.forceSwitch(new states.menus.MainMenu('[MAIN GAME]: $e'));
							}
						}
					}
				}
			}
		}

		if (moduleArray != null)
		{
			for (i in moduleArray)
				i.call('onCreate', []);
		}

		return moduleArray;
	}
}

class Events
{
	public static var eventArray:Array<String> = [];
	public static var needsValue3:Array<String> = [];

	// public static var loadedEvents:Array<ScriptHandler> = [];
	// public static var pushedEvents:Array<String> = [];
	public static var loadedEvents:Map<String, ScriptHandler> = [];

	public static function getScriptEvents()
	{
		loadedEvents.clear();
		eventArray = [];

		var myEvents:Array<String> = [];

		for (event in sys.FileSystem.readDirectory('assets/data/events'))
		{
			if (event.contains('.'))
			{
				event = event.substring(0, event.indexOf('.', 0));
				try
				{
					loadedEvents.set(event, new ScriptHandler(Paths.module('$event', 'data/events')));
					// trace('new event module loaded: ' + event);
					myEvents.push(event);
				}
				catch (e)
				{
					// have to use FlxG instead of main since this isn't a class;
					Main.baseGame.forceSwitch(new states.menus.MainMenu('[CHART EVENT]: Uncaught Error: $e'));
				}
			}
		}
		myEvents.sort(function(e1, e2) return Reflect.compare(e1.toLowerCase(), e2.toLowerCase()));

		for (e in myEvents)
		{
			if (!eventArray.contains(e))
				eventArray.push(e);
		}
		eventArray.insert(0, '');

		for (e in eventArray)
			returnValue3(e);

		myEvents = [];
	}

	inline public static function returnValue3(event:String):Array<String>
	{
		if (loadedEvents.exists(event))
		{
			var script:ScriptHandler = loadedEvents.get(event);
			var scriptCall = script.call('returnValue3', []);

			if (scriptCall != null)
			{
				needsValue3.push(event);
				// trace(needsValue3);
			}
		}
		return needsValue3.copy();
	}

	inline public static function returnEventDescription(event:String):String
	{
		if (loadedEvents.exists(event))
		{
			var script:ScriptHandler = loadedEvents.get(event);
			var descString = script.call('returnDescription', []);
			return descString;
		}
		trace('Event $event has no description.');
		return '';
	}
}
