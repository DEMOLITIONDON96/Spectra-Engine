package objects;

import base.dependency.FeatherDeps.ScriptHandler;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import states.PlayState;

class Stage extends FlxTypedGroup<FlxBasic>
{
	//
	public var gfVersion:String = 'gf';

	public var curStage:String;

	public var foreground:FlxTypedGroup<FlxBasic>;
	public var layers:FlxTypedGroup<FlxBasic>;

	public var spawnGirlfriend:Bool = true;

	public var stageScript:ScriptHandler;

	public var sendMessage:Bool = false;
	public var messageText:String = '';

	public function new(curStage:String)
	{
		super();

		this.curStage = curStage;

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();
		layers = new FlxTypedGroup<FlxBasic>();

		setStage(curStage);
	}

	public function setStage(curStage:String)
	{
		if (curStage == null || curStage.length < 1)
		{
			if (PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1)
				curStage = 'unknown';
			else
				curStage = PlayState.SONG.stage;
		}

		//
		switch (curStage)
		{
			default:
				curStage = 'unknown';
				PlayState.defaultCamZoom = 0.9;
		}

		reloadGroups();

		try
		{
			//
			callStageScript();
		}
		catch (e)
		{
			sendMessage = true;
			messageText = '[GAME STAGE]: Uncaught Error: $e';
		}
	}

	public function reloadGroups()
	{
		foreground.forEach(function(a:Dynamic)
		{
			if (a != null && !Std.isOfType(a, flixel.system.FlxSound))
				remove(a);
		});

		layers.forEach(function(a:Dynamic)
		{
			if (a != null && !Std.isOfType(a, flixel.system.FlxSound))
				remove(a);
		});
	}

	public function dadPosition(curStage:String, boyfriend:Character, gf:Character, dad:Character, camPos:FlxPoint):Void
		callFunc('onPostCreate', [boyfriend, gf, dad]);

	public function repositionPlayers(curStage:String, boyfriend:Character, gf:Character, dad:Character)
	{
		boyfriend.setPosition(770, 450);
		dad.setPosition(100, 100);
		gf.setPosition(300, 100);
		callFunc('charStagePos', [boyfriend, gf, dad]);
	}

	public function stageUpdate(curBeat:Int, boyfriend:Character, gf:Character, dad:Character)
		callFunc('onBeat', [curBeat, boyfriend, gf, dad]);

	public function stageUpdateSteps(curStep:Int, boyfriend:Character, gf:Character, dad:Character)
		callFunc('onStep', [curStep, boyfriend, gf, dad]);

	public function stageUpdateConstant(elapsed:Float, boyfriend:Character, gf:Character, dad:Character)
		callFunc('onUpdate', [elapsed, boyfriend, gf, dad]);

	override public function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}

	function callStageScript()
	{
		var modulePath = Paths.module('stages/$curStage/$curStage', 'data');

		if (!sys.FileSystem.exists(modulePath))
			return;

		stageScript = new ScriptHandler(modulePath);

		/* ===== SCRIPT VARIABLES ===== */

		setVar('add', add);
		setVar('remove', remove);
		setVar('foreground', foreground);
		setVar('layers', layers);
		setVar('gfVersion', gfVersion);
		setVar('game', PlayState.main);
		setVar('spawnGirlfriend', function(blah:Bool)
		{
			spawnGirlfriend = blah;
		});
		if (PlayState.SONG != null)
			setVar('songName', PlayState.SONG.song.toLowerCase());

		if (PlayState.boyfriend != null)
		{
			setVar('bf', PlayState.boyfriend);
			setVar('boyfriend', PlayState.boyfriend);
			setVar('player', PlayState.boyfriend);
			setVar('bfName', PlayState.boyfriend.curCharacter);
			setVar('boyfriendName', PlayState.boyfriend.curCharacter);
			setVar('playerName', PlayState.boyfriend.curCharacter);

			setVar('bfData', PlayState.boyfriend.characterData);
			setVar('boyfriendData', PlayState.boyfriend.characterData);
			setVar('playerData', PlayState.boyfriend.characterData);
		}

		if (PlayState.opponent != null)
		{
			setVar('dad', PlayState.opponent);
			setVar('dadOpponent', PlayState.opponent);
			setVar('opponent', PlayState.opponent);
			setVar('dadName', PlayState.opponent.curCharacter);
			setVar('dadOpponentName', PlayState.opponent.curCharacter);
			setVar('opponentName', PlayState.opponent.curCharacter);

			setVar('dadData', PlayState.opponent.characterData);
			setVar('dadOpponentData', PlayState.opponent.characterData);
			setVar('opponentData', PlayState.opponent.characterData);
		}

		if (PlayState.gf != null)
		{
			setVar('gf', PlayState.gf);
			setVar('girlfriend', PlayState.gf);
			setVar('spectator', PlayState.gf);
			setVar('gfName', PlayState.gf.curCharacter);
			setVar('girlfriendName', PlayState.gf.curCharacter);
			setVar('spectatorName', PlayState.gf.curCharacter);

			setVar('gfData', PlayState.gf.characterData);
			setVar('girlfriendData', PlayState.gf.characterData);
			setVar('spectatorData', PlayState.gf.characterData);
		}

		callFunc('onCreate', []);
	}

	public function callFunc(key:String, args:Array<Dynamic>)
	{
		if (stageScript == null)
			return null;
		else
			return stageScript.call(key, args);
	}

	public function setVar(key:String, value:Dynamic)
	{
		if (stageScript == null)
			return null;
		else
			return stageScript.set(key, value);
	}
}
