package objects;

import base.dependency.FeatherDeps.ScriptHandler;
import base.song.Conductor;
import base.utils.FNFUtils.FNFSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.Json;
import objects.CharacterData.CharacterOrigin;
import objects.CharacterData.PsychAnimArray;
import objects.CharacterData.PsychEngineChar;
import states.PlayState;
import sys.FileSystem;
import sys.io.File;

/**
 * The character class initialises any and all characters that exist within gameplay.
**/
class Character extends FNFSprite
{
	public var legacyGirlfriend:Bool = false;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0.6;

	public var specialAnim:Bool = false;

	public var hasMissAnims:Bool = false;
	public var danceIdle:Bool = false;

	public var characterType:String = FOREVER_FEATHER;
	public var characterData:CharacterData;

	public var characterScripts:Array<ScriptHandler> = [];

	public var idleSuffix:String = '';

	public function new(?isPlayer:Bool = false)
	{
		super(x, y);
		this.isPlayer = isPlayer;
	}

	public function setCharacter(x:Float, y:Float, character:String):Character
	{
		curCharacter = character;
		var tex:FlxAtlasFrames;

		characterData = {
			flipX: isPlayer,
			flipY: false,
			antialiasing: true,
			quickDancer: false,
			offsets: [0, 0],
			camOffsets: [0, 0],
			singDuration: 4,
			headBopSpeed: 2,
			healthColor: [255, 255, 255],
			missColor: [112, 105, 255],
			adjustPos: !character.startsWith('gf'),
			icon: null
		};

		if (characterData.icon == null)
			characterData.icon = character;

		if (animation.getByName('danceRight') != null)
			danceIdle = true;

		if (FileSystem.exists(Paths.characterModule(character, character, PSYCH_ENGINE)))
			characterType = PSYCH_ENGINE;

		switch (curCharacter)
		{
			case 'placeholder':
				// hardcoded placeholder so it can be used on errors;
				frames = Paths.getSparrowAtlas('placeholder', 'data/characters/$character');

				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singLEFT', 'Left', 24, false);
				animation.addByPrefix('singDOWN', 'Down', 24, false);
				animation.addByPrefix('singUP', 'Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Right', 24, false);

				if (!isPlayer)
				{
					addOffset("idle", 0, -350);
					addOffset("singLEFT", 22, -353);
					addOffset("singDOWN", 17, -375);
					addOffset("singUP", 8, -334);
					addOffset("singRIGHT", 50, -348);
					characterData.camOffsets = [30, 330];
					characterData.offsets = [0, -350];
				}
				else
				{
					addOffset("idle", 0, -10);
					addOffset("singLEFT", 33, -6);
					addOffset("singDOWN", -48, -31);
					addOffset("singUP", -45, 11);
					addOffset("singRIGHT", -61, -14);
					characterData.camOffsets = [0, -5];
					characterData.flipX = false;
				}

				playAnim('idle');
				characterData.healthColor = [161, 161, 161];

			default:
				switch (characterType)
				{
					case PSYCH_ENGINE:
						generatePsychChar(character);
					default:
						try
						{
							generateChar(character);
						}
						catch (e)
						{
							trace('$character is/was null');
							return setCharacter(x, y, 'placeholder');
						}
				}
		}

		var missAnimations:Array<String> = ['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'];

		for (missAnim in missAnimations)
		{
			if (animOffsets.exists(missAnim))
				hasMissAnims = true;
		}

		// "Preloads" animations so they dont lag in the song
		var allAnims:Array<String> = animation.getNameList();
		for (anim in allAnims)
		{
			playAnim(anim);
			if (anim.startsWith("sad"))
				animation.curAnim.finish();
		}

		recalcDance();
		dance();

		antialiasing = characterData.antialiasing;

		flipX = isPlayer ? !characterData.flipX : characterData.flipX;
		flipY = characterData.flipY;

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
				flipLeftRight();
			//
		}
		else if (curCharacter.startsWith('bf'))
			flipLeftRight();

		if (characterData.adjustPos)
		{
			x += characterData.offsets[0];
			y += (characterData.offsets[1] - (frameHeight * scale.y));
		}

		this.x = x;
		this.y = y;

		return this;
	}

	function flipLeftRight():Void
	{
		// get the old right sprite
		var oldRight = animation.getByName('singRIGHT').frames;

		// set the right to the left
		animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;

		// set the left to the old right
		animation.getByName('singLEFT').frames = oldRight;

		// insert ninjamuffin screaming I think idk I'm lazy as hell

		if (animation.getByName('singRIGHTmiss') != null)
		{
			var oldMiss = animation.getByName('singRIGHTmiss').frames;
			animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			animation.getByName('singLEFTmiss').frames = oldMiss;
		}
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (heyTimer > 0)
			{
				heyTimer -= elapsed;
				if (heyTimer <= 0)
				{
					if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			}
			else if (specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer && !specialAnim)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				if (holdTimer >= Conductor.stepCrochet * characterData.singDuration * 0.001)
				{
					dance();
					holdTimer = 0;
				}
			}

			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight$idleSuffix');
					if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
						playAnim('danceLeft$idleSuffix');
			}

			// Post idle animation (think Week 4 and how the player and mom's hair continues to sway after their idle animations are done!)
			if (animation.curAnim.finished && animation.curAnim.name == 'idle')
			{
				// We look for an animation called 'idlePost' to switch to
				if (animation.getByName('idlePost') != null)
					// (( WE DON'T USE 'PLAYANIM' BECAUSE WE WANT TO FEED OFF OF THE IDLE OFFSETS! ))
					animation.play('idlePost', true, false, 0);
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode && animation.curAnim != null && !specialAnim)
		{
			// reset color if it's not white;
			if (color != 0xFFFFFFFF)
				color = 0xFFFFFFFF;

			specialAnim = false;

			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				default:
					// Left/right dancing, think Skid & Pump

					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
					{
						danced = !danced;
						if (danced)
							playAnim('danceRight$idleSuffix', forced);
						else
							playAnim('danceLeft$idleSuffix', forced);
					}
					else
						playAnim('idle$idleSuffix', forced);
			}
		}
	}

	private var settingCharacterUp:Bool = true;

	/**
	 * Recalculates Character Headbop Speed, used by GF-Like Characters;
	 * @author Shadow_Mario_
	**/
	public function recalcDance()
	{
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);

		if (settingCharacterUp)
		{
			characterData.headBopSpeed = (danceIdle ? 1 : 2);
		}
		else if (lastDanceIdle != danceIdle)
		{
			var calc:Float = characterData.headBopSpeed;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;

			characterData.headBopSpeed = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) != null)
			super.playAnim(AnimName, Force, Reversed, Frame);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));
		return base;
	}

	/**
	 * [Generates a Character in the Forever Engine Feather Format]
	 * @param char returns the character that should be generated
	 */
	function generateChar(char:String = 'bf')
	{
		var pushedChars:Array<String> = [];

		var overrideFrames:String = null;
		var framesPath:String = null;

		if (!pushedChars.contains(char))
		{
			var script:ScriptHandler = new ScriptHandler(Paths.characterModule(char, 'config', FOREVER_FEATHER));

			if (script.interp == null)
				trace("Something terrible occured! Skipping.");

			characterScripts.push(script);
			pushedChars.push(char);
		}

		var spriteType = "SparrowAtlas";

		try
		{
			var textAsset:String = Paths.characterModule(char, char + '.txt');

			// check if a text file exists with the character name exists, if so, it's a spirit-like character;
			if (FileSystem.exists(textAsset))
				spriteType = "PackerAtlas";
			else
				spriteType = "SparrowAtlas";
		}
		catch (e)
		{
			trace('Could not define Sprite Type, Uncaught Error: ' + e);
		}

		// frame overrides because why not;
		setVar('setFrames', function(newFrames:String, newFramesPath:String)
		{
			if (newFrames != null || newFrames != '')
				overrideFrames = newFrames;
			if (newFramesPath != null && newFramesPath != '')
				framesPath = newFramesPath;
		});

		switch (spriteType)
		{
			case "PackerAtlas":
				var sprPacker:String = (overrideFrames == null ? char : overrideFrames);
				var sprPath:String = (framesPath == null ? 'data/characters/$char' : framesPath);
				frames = Paths.getPackerAtlas(sprPacker, sprPath);
			default:
				var sprSparrow:String = (overrideFrames == null ? char : overrideFrames);
				var sprPath:String = (framesPath == null ? 'data/characters/$char' : framesPath);
				frames = Paths.getSparrowAtlas(sprSparrow, sprPath);
		}

		setVar('addByPrefix', function(name:String, prefix:String, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByPrefix(name, prefix, frames, loop);
		});

		setVar('addByIndices', function(name:String, prefix:String, indices:Array<Int>, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByIndices(name, prefix, indices, "", frames, loop);
		});

		setVar('addOffset', function(?name:String = "idle", ?x:Float = 0, ?y:Float = 0)
		{
			addOffset(name, x, y);
		});

		setVar('set', function(name:String, value:Dynamic)
		{
			Reflect.setProperty(this, name, value);
		});

		setVar('setSingDuration', function(amount:Int)
		{
			characterData.singDuration = amount;
		});

		setVar('setOffsets', function(x:Float = 0, y:Float = 0)
		{
			characterData.offsets = [x, y];
		});

		setVar('setCamOffsets', function(x:Float = 0, y:Float = 0)
		{
			characterData.camOffsets = [x, y];
		});

		setVar('setScale', function(?x:Float = 1, ?y:Float = 1)
		{
			scale.set(x, y);
		});

		setVar('setIcon', function(swag:String = 'face') characterData.icon = swag);

		setVar('quickDancer', function(quick:Bool = false)
		{
			characterData.quickDancer = quick;
		});

		setVar('setBarColor', function(rgb:Array<Float>)
		{
			if (characterData.healthColor != null)
				characterData.healthColor = rgb;
			else
				characterData.healthColor = [161, 161, 161];
			return true;
		});

		setVar('setDeathChar',
			function(char:String = 'bf-dead', lossSfx:String = 'fnf_loss_sfx', song:String = 'gameOver', confirmSound:String = 'gameOverEnd', bpm:Int)
			{
				states.substates.GameOverSubstate.bfType = char;
				states.substates.GameOverSubstate.deathNoise = lossSfx;
				states.substates.GameOverSubstate.deathTrack = song;
				states.substates.GameOverSubstate.leaveTrack = confirmSound;
				states.substates.GameOverSubstate.trackBpm = bpm;
			});

		setVar('get', function(variable:String)
		{
			return Reflect.getProperty(this, variable);
		});

		setVar('setGraphicSize', function(width:Int = 0, height:Int = 0)
		{
			setGraphicSize(width, height);
			updateHitbox();
		});

		setVar('playAnim', function(name:String, ?force:Bool = false, ?reversed:Bool = false, ?frames:Int = 0)
		{
			playAnim(name, force, reversed, frames);
		});

		setVar('isPlayer', isPlayer);
		setVar('characterData', characterData);
		if (PlayState.SONG != null)
			setVar('songName', PlayState.SONG.song.toLowerCase());
		setVar('flipLeftRight', flipLeftRight);

		if (characterScripts != null)
		{
			for (i in characterScripts)
				i.call('loadAnimations', []);
		}

		if (animation.getByName('danceLeft$idleSuffix') != null)
			playAnim('danceLeft$idleSuffix');
		else
			playAnim('idle$idleSuffix');
	}

	public function setVar(key:String, value:Dynamic)
	{
		var allSucceed:Bool = true;
		if (characterScripts != null)
		{
			for (i in characterScripts)
			{
				i.set(key, value);

				if (!i.exists(key))
				{
					trace('${i.scriptFile} failed to set $key for its interpreter, continuing.');
					allSucceed = false;
					continue;
				}
			}
		}
		return allSucceed;
	}

	public var psychAnimationsArray:Array<PsychAnimArray> = [];

	/**
	 * [Generates a Character in the Psych Engine Format, as a Compatibility Layer for them]
	 * [@author Shadow_Mario_]
	 * @param char returns the character that should be generated
	 */
	function generatePsychChar(char:String = 'bf-psych')
	{
		var rawJson:String = null;
		var json:PsychEngineChar = null;

		if (FileSystem.exists(Paths.characterModule(char, char, PSYCH_ENGINE)))
			rawJson = File.getContent(Paths.characterModule(char, char, PSYCH_ENGINE));

		if (rawJson != null)
			json = cast Json.parse(rawJson);

		var spriteType:String = "SparrowAtlas";

		try
		{
			var textAsset:String = Paths.characterModule(char, json.image.replace('characters/', '') + '.txt');

			if (FileSystem.exists(textAsset))
				spriteType = "PackerAtlas";
			else
				spriteType = "SparrowAtlas";
		}
		catch (e)
		{
			trace('Could not define Sprite Type, Uncaught Error: ' + e);
		}

		switch (spriteType)
		{
			case "PackerAtlas":
				frames = Paths.getPackerAtlas(json.image.replace('characters/', ''), 'data/characters/$char');
			default:
				frames = Paths.getSparrowAtlas(json.image.replace('characters/', ''), 'data/characters/$char');
		}

		psychAnimationsArray = json.animations;
		for (anim in psychAnimationsArray)
		{
			var animAnim:String = '' + anim.anim;
			var animName:String = '' + anim.name;
			var animFps:Int = anim.fps;
			var animLoop:Bool = !!anim.loop; // Bruh
			var animIndices:Array<Int> = anim.indices;
			if (animIndices != null && animIndices.length > 0)
				animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
			else
				animation.addByPrefix(animAnim, animName, animFps, animLoop);

			if (anim.offsets != null && anim.offsets.length > 1)
				addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
		}
		characterData.flipX = json.flip_x;

		// characterData.icon = json.healthicon;
		characterData.antialiasing = !json.no_antialiasing;
		characterData.healthColor = json.healthbar_colors;
		characterData.singDuration = json.sing_duration;

		characterData.adjustPos = true;

		if (json.scale != 1)
		{
			setGraphicSize(Std.int(width * json.scale));
			updateHitbox();
		}

		if (animation.getByName('danceLeft$idleSuffix') != null)
			playAnim('danceLeft$idleSuffix');
		else
			playAnim('idle$idleSuffix');

		characterData.camOffsets = [json.camera_position[0], json.camera_position[1]];
		setPosition(json.position[0], json.position[1]);

		return this;
	}
}

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public function new()
		super(true);

	override function update(elapsed:Float)
	{
		if (!debugMode)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
				playAnim('idle', true, false, 10);

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
				playAnim('deathLoop');
		}

		super.update(elapsed);
	}
}
