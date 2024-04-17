package states;

import states.MusicBeatState.MusicBeatSubstate;
import base.dependency.FeatherDeps.ScriptHandler;
import states.MusicBeatState;
import flixel.FlxBasic;
import flixel.FlxSubState;

/**
 * Here's a Custom Class for Scripts, you can customize it to your liking and add your own features to it!
**/
class ScriptableState extends MusicBeatState
{
	public static var stateScript:ScriptHandler;
	var errorCatch:String; // string containing error information;

	override public function new(className:String):Void
	{
		super();

		// here we actually create the main script
		try
		{
			stateScript = new ScriptHandler(Paths.module(className, 'data/menus/states'));
		}
		catch (e)
		{
			errorCatch = '$e';
			stateScript = null;
		}
		scriptCall('new', [className]);
		variableCalls();
	}

	override public function create():Void
	{
		scriptCall('create', []);
		super.create();
		scriptCall('postCreate', []);
	}

	override public function update(elapsed:Float)
	{
		if (stateScript == null)
		{
			Main.switchState(this, new states.menus.MainMenu('[SCRIPTABLE STATE]: $errorCatch'));
			return;
		}
		scriptCall('update', [elapsed]);
		super.update(elapsed);
		scriptCall('postUpdate', [elapsed]);
	}

	override public function beatHit():Void
	{
		super.beatHit();
		scriptCall('beatHit', [curBeat]);
		scriptSet('curBeat', curBeat);
	}

	override public function stepHit():Void
	{
		super.stepHit();
		scriptCall('stepHit', [curStep]);
		scriptSet('curStep', curStep);
	}

	override public function onFocus():Void
	{
		scriptCall('onFocus', []);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		scriptCall('onFocusLost', []);
		super.onFocusLost();
	}

	override public function destroy():Void
	{
		scriptCall('destroy', []);
		super.destroy();
	}

	override function openSubState(SubState:FlxSubState):Void
	{
		scriptCall('openSubState', []);
		super.openSubState(SubState);
	}

	override function closeSubState():Void
	{
		scriptCall('closeSubState', []);
		super.closeSubState();
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, flixel.FlxSprite))
			cast(Object, flixel.FlxSprite).antialiasing = false;
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, flixel.text.FlxText))
			cast(Object, flixel.text.FlxText).antialiasing = false;
		return super.add(Object);
	}

	function variableCalls()
	{
		scriptSet()
		scriptSet('this', this);
		scriptSet('add', add);
		scriptSet('remove', remove);
		scriptSet('kill', kill);
		scriptSet('updatePresence', function(detailsTop:String, subDetails:String, ?iconRPC:String, ?updateTime:Bool = false, time:Float)
		{
			#if DISCORD_RPC
			base.dependency.Discord.changePresence(detailsTop, subDetails, iconRPC, updateTime, time);
			#end
		});
		scriptSet('logTrace', function(text:String, time:Float, onConsole:Bool = false)
		{
			logTrace(text, time, onConsole);
		});
		scriptSet('openSubState', openSubState);
	}

	function scriptCall(funcName:String, params:Array<Dynamic>)
	{
		if (stateScript != null)
			stateScript.call(funcName, params);
	}

	function scriptSet(varName:String, value:Dynamic)
	{
		if (stateScript != null)
			stateScript.set(varName, value);
	}
}

class ScriptableSubstate extends MusicBeatSubstate
{
	public static var substateScript:ScriptHandler;
	var errorCatch:String; // string containing error information;

	override public function new(className:String):Void
	{
		super();

		// here we actually create the main script
		try
		{
			substateScript = new ScriptHandler(Paths.module(className, 'data/menus/substates'));
		}
		catch (e)
		{
			errorCatch = '$e';
			stateScript = null;
		}
		scriptCall('new', [className]);
		variableCalls();
	}

	override public function create():Void
	{
		scriptCall('create', []);
		super.create();
		scriptCall('postCreate', []);
	}

	override public function update(elapsed:Float)
	{
		if (substateScript == null)
		{
			Main.switchState(this, new states.menus.MainMenu('[SCRIPTABLE SUBSTATE]: $errorCatch'));
			return;
		}
		scriptCall('update', [elapsed]);
		super.update(elapsed);
		scriptCall('postUpdate', [elapsed]);
	}

	override public function beatHit():Void
	{
		super.beatHit();
		scriptCall('beatHit', [curBeat]);
		scriptSet('curBeat', curBeat);
	}

	override public function stepHit():Void
	{
		super.stepHit();
		scriptCall('stepHit', [curStep]);
		scriptSet('curStep', curStep);
	}

	override public function onFocus():Void
	{
		scriptCall('onFocus', []);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		scriptCall('onFocusLost', []);
		super.onFocusLost();
	}

	override public function destroy():Void
	{
		scriptCall('destroy', []);
		super.destroy();
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, flixel.FlxSprite))
			cast(Object, flixel.FlxSprite).antialiasing = false;
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, flixel.text.FlxText))
			cast(Object, flixel.text.FlxText).antialiasing = false;
		return super.add(Object);
	}

	function variableCalls()
	{
		scriptSet('this', this);
		scriptSet('add', add);
		scriptSet('remove', remove);
		scriptSet('kill', kill);
		scriptSet('updatePresence', function(detailsTop:String, subDetails:String, ?iconRPC:String, ?updateTime:Bool = false, time:Float)
		{
			#if DISCORD_RPC
			base.dependency.Discord.changePresence(detailsTop, subDetails, iconRPC, updateTime, time);
			#end
		});
	}

	function scriptCall(funcName:String, params:Array<Dynamic>)
	{
		if (suvstateScript != null)
			substateScript.call(funcName, params);
	}

	function scriptSet(varName:String, value:Dynamic)
	{
		if (substateScript != null)
			substateScript.set(varName, value);
	}
}
