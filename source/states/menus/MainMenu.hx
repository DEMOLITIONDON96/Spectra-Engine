package states.menus;

import base.dependency.FeatherDeps.ScriptHandler;
import base.dependency.Discord;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import states.MusicBeatState;

/*
	currently, the Main Menu is completely handled by a script located on the assets/scripts/menus folder
	you can get as expressive as you can with that, create your own custom menu
 */
class MainMenu extends MusicBeatState
{
	var parsedJson:MainMenuDef;
	var mainScript:ScriptHandler;

	var menuCam:FlxCamera;
	var menuHUD:FlxCamera;

	public var logContent:String;

	function cameraCalls()
	{
		menuCam = new FlxCamera();
		menuHUD = new FlxCamera();
		menuHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(menuCam);
		FlxG.cameras.add(menuHUD, false);
		FlxG.cameras.setDefaultDrawTarget(menuCam, true);
	}

	public function new(?logContent:String)
	{
		super();

		this.logContent = logContent;
	}

	override function create()
	{
		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		cameraCalls();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		try // set up the menu preferences json if it exists;
		{
			parsedJson = haxe.Json.parse(Paths.getTextFile('data/menus/states/MainMenu.json'));
		}
		catch (e) // ...or just use a hardcoded fallback one;
		{
			parsedJson = haxe.Json.parse('{
				"staticBack": "menuBG",
				"flashingBack": "menuDesat",
				"staticBackColor": null,
				"flashingBackColor": [253, 113, 155],
				"options": ["story mode", "freeplay", "options"]
			}');
		}

		// set up the main menu script itself
		mainScript = new ScriptHandler(Paths.module('MainMenu', 'data/menus/states'));
		mainScript.call('create', []);

		mainScript.set('parsedJson', parsedJson);

		mainScript.set('add', add);
		mainScript.set('remove', remove);
		mainScript.set('this', this);
		mainScript.set('menuCam', menuCam);
		mainScript.set('menuHUD', menuHUD);

		super.create();

		mainScript.call('postCreate', []);

		if (logContent != null && logContent.length > 1)
			logTrace('$logContent', 3, menuHUD);

		states.substates.PauseSubstate.toOptions = false;
	}

	override function update(elapsed:Float)
	{
		mainScript.call('update', [elapsed]);
		super.update(elapsed);
		mainScript.call('postUpdate', [elapsed]);

		mainScript.set('elapsed', elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		mainScript.call('beatHit', [curBeat]);
		mainScript.set('curBeat', curBeat);
	}

	override function stepHit()
	{
		super.stepHit();

		mainScript.call('stepHit', [curStep]);
		mainScript.set('curStep', curStep);
	}

	override public function destroy()
	{
		mainScript.call('destroy', []);
		super.destroy();
	}

	override public function onFocus()
	{
		mainScript.call('onFocus', []);
		super.onFocus();
	}

	override public function onFocusLost()
	{
		mainScript.call('onFocusLost', []);
		super.onFocusLost();
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxText))
			cast(Object, FlxText).antialiasing = false;
		return super.add(Object);
	}
}