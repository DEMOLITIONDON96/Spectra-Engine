package base.dependency;

/*
	Forever Dependencies is a way to unify both ForeverAssets and ForeverTools;
	it contains data for custom asset skins and generation scripts for asset types;
 */
import base.dependency.FeatherDeps.ScriptHandler;
import base.song.Conductor;
import base.utils.FNFUtils.FNFSprite;
import base.utils.ScoreUtils;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import objects.ui.Note;
import objects.ui.NoteSplash;
import objects.ui.Strumline.Receptor;
import objects.ui.Strumline;
import objects.ui.menu.Checkmark;
import openfl.display.BlendMode;
import states.PlayState;
import sys.FileSystem;

/**
 * Forever Assets is a class that manages the different asset types, basically a compilation of switch statements that are
 * easy to edit for your own needs. Most of these are just static functions that return information
**/
class ForeverAssets
{
	//
	public static function generateCombo(asset:String, assetGroup:FlxTypedGroup<FNFSprite>, number:String, allSicks:Bool, assetModifier:String = 'base',
			changeableSkin:String = 'default', baseLibrary:String, negative:Bool, createdColor:FlxColor, scoreInt:Int):FNFSprite
	{
		var width = assetModifier == "pixel" ? 10 : 100;
		var height = assetModifier == "pixel" ? 12 : 140;

		if (!Init.trueSettings.get('Judgement Recycling'))
			assetGroup == null;

		var comboNumbers:FNFSprite = generateForeverSprite(asset, assetModifier, changeableSkin, baseLibrary, true, width, height, assetGroup);

		comboNumbers.alpha = 1;
		comboNumbers.screenCenter();
		comboNumbers.antialiasing = (assetModifier != 'pixel');
		comboNumbers.x += (43 * scoreInt) + 20;
		comboNumbers.y += 60;

		if (!Init.trueSettings.get('Simply Judgements'))
		{
			comboNumbers.acceleration.y = FlxG.random.int(200, 300);
			comboNumbers.velocity.y = -FlxG.random.int(140, 160);
			comboNumbers.velocity.x = FlxG.random.float(-5, 5);
		}
		comboNumbers.zDepth = -Conductor.songPosition;

		comboNumbers.color = FlxColor.WHITE;
		if (negative)
			comboNumbers.color = createdColor;

		comboNumbers.animation.add('base', [
			(Std.parseInt(number) != null ? Std.parseInt(number) + 1 : 0) + (!allSicks ? 0 : 11)
		], 0, false);
		comboNumbers.animation.play('base');

		if (assetModifier == 'pixel')
			comboNumbers.setGraphicSize(Std.int(comboNumbers.width * PlayState.daPixelZoom));
		else
			comboNumbers.setGraphicSize(Std.int(comboNumbers.width * 0.5));
		comboNumbers.updateHitbox();

		// hardcoded lmao
		if (!Init.trueSettings.get('Simply Judgements'))
		{
			FlxTween.tween(comboNumbers, {alpha: 0}, (Conductor.stepCrochet * 2) / 1000, {
				onComplete: function(tween:FlxTween)
				{
					comboNumbers.kill();
				},
				startDelay: (Conductor.crochet) / 1000
			});
		}
		else
			FlxTween.tween(comboNumbers, {y: comboNumbers.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});

		return comboNumbers;
	}

	public static function generateRating(id:Int, assetGroup:FlxTypedGroup<FNFSprite>, assetModifier:String = 'base', changeableSkin:String = 'default',
			baseLibrary:String):FNFSprite
	{
		var width = assetModifier == 'pixel' ? 60 : 390;
		var height = assetModifier == 'pixel' ? 32 : 163;

		if (!Init.trueSettings.get('Judgement Recycling'))
			assetGroup == null;

		var judgement:FNFSprite = generateForeverSprite('judgements', assetModifier, changeableSkin, baseLibrary, true, width, height, assetGroup);

		judgement.alpha = 1;
		judgement.visible = true;
		judgement.screenCenter();
		judgement.antialiasing = (assetModifier != 'pixel');
		judgement.x = (FlxG.width * 0.55) - 40;
		judgement.y -= 60;
		if (!Init.trueSettings.get('Simply Judgements'))
		{
			judgement.acceleration.y = 550;
			judgement.velocity.y = -FlxG.random.int(140, 175);
			judgement.velocity.x = -FlxG.random.int(0, 10);
		}
		judgement.zDepth = -Conductor.songPosition;

		judgement.animation.add('sick-perfect', [0]);
		for (i in 0...ScoreUtils.judges.length)
			judgement.animation.add(ScoreUtils.judges[i].name, [i + 1]);

		var perfectString = (ScoreUtils.judges[id].name == "sick" && ScoreUtils.perfectCombo ? '-perfect' : '');
		judgement.animation.play(ScoreUtils.judges[id].name + perfectString);

		if (assetModifier == 'pixel')
			judgement.setGraphicSize(Std.int(judgement.width * PlayState.daPixelZoom * 0.7));
		else
			judgement.setGraphicSize(Std.int(judgement.width * 0.7));

		return judgement;
	}

	public static function generateTimings(anim:String, isLate:Bool, parent:FNFSprite, assetGroup:FlxTypedGroup<FNFSprite>, assetModifier:String,
			changeableSkin:String, baseLibrary:String):FNFSprite
	{
		var width = assetModifier == "pixel" ? 28 : 150;
		var height = assetModifier == "pixel" ? 14 : 120;

		if (!Init.trueSettings.get('Judgement Recycling'))
			assetGroup == null;

		var timing:FNFSprite = generateForeverSprite('timings', assetModifier, changeableSkin, baseLibrary, true, width, height, assetGroup);

		timing.alpha = 1;
		timing.visible = (anim != 'sick-perfect' && anim != 'sick' && anim != 'miss');
		timing.scrollFactor.set(parent.scrollFactor.x, parent.scrollFactor.y);
		timing.velocity.set(parent.velocity.x, parent.velocity.y);
		timing.acceleration.set(parent.acceleration.x, parent.acceleration.y);
		timing.antialiasing = (assetModifier != 'pixel');
		timing.zDepth = -Conductor.songPosition;

		for (i in 0...ScoreUtils.judges.length)
			for (j in 0...2)
				timing.animation.add(ScoreUtils.judges[i].name + (j == 1 ? '-late' : '-early'), [(i * 2) + (j == 1 ? 1 : 0) - 2]);

		var timingString = (isLate ? '-late' : '-early');
		timing.animation.play(anim + timingString);

		if (assetModifier == 'pixel')
			timing.setGraphicSize(Std.int(timing.width * PlayState.daPixelZoom * 0.7));
		else
			timing.setGraphicSize(Std.int(timing.width * 0.7));

		return timing;
	}

	public static function generateForeverSprite(asset:String, aMod:String, skin:String, lib:String, animated:Bool, width:Int, height:Int,
			?group:FlxTypedGroup<FNFSprite>)
	{
		//
		var newSprite:FNFSprite;
		if (group != null)
			newSprite = group.recycle(FNFSprite);
		else
			newSprite = new FNFSprite();
		newSprite.loadGraphic(Paths.image(ForeverTools.returnSkinAsset(asset, aMod, skin, lib)), animated, width, height);
		return newSprite;
	}

	public static function generateNoteSplashes(strumline:Strumline, assetModifier:String = 'base', changeableSkin:String = 'default',
			noteType:String = 'default', noteData:Int):NoteSplash
	{
		//
		var tempSplash:NoteSplash = strumline.splashNotes.recycle(NoteSplash, function()
		{
			var splash:NoteSplash = new NoteSplash(noteData);
			return splash;
		});

		tempSplash.visible = true;
		tempSplash.x = strumline.receptors.members[noteData].x;
		tempSplash.y = strumline.receptors.members[noteData].y;

		if (FileSystem.exists(Paths.module('$noteType/$noteType-$assetModifier', 'data/notetypes')))
		{
			var possibleModules:Array<String> = [
				Paths.module('$noteType/$noteType-$assetModifier', 'data/notetypes'),
				Paths.module('$noteType/$noteType-$assetModifier', 'songs/${PlayState.SONG.song}/notetypes')
			];
			for (module in possibleModules)
			{
				if (FileSystem.exists(module))
				{
					Note.noteMap.set(noteType, new ScriptHandler(module));
					Note.noteMap.get(noteType).call('generateSplash', [tempSplash, noteData]);
					// trace('Splash Module loaded: $noteType-$assetModifier');
				}
			}
		}

		tempSplash.zDepth = -Conductor.songPosition;
		strumline.splashNotes.sort(FNFSprite.depthSorting, FlxSort.DESCENDING);
		return tempSplash;
	}

	public static function generateUIArrows(x:Float, y:Float, ?receptorData:Int = 0, assetModifier:String, noteType:String = 'default'):Receptor
	{
		var uiReceptor:Receptor = new Receptor(x, y, receptorData);

		var framesArg:String = "NOTE_assets";

		switch (assetModifier)
		{
			case 'chart editor':
				uiReceptor.loadGraphic(Paths.image('UI/forever/base/chart editor/note_array'), true, 157, 156);
				uiReceptor.animation.add('static', [receptorData]);
				uiReceptor.animation.add('pressed', [16 + receptorData], 12, false);
				uiReceptor.animation.add('confirm', [4 + receptorData, 8 + receptorData, 16 + receptorData], 24, false);

				uiReceptor.addOffset('static');
				uiReceptor.addOffset('pressed');
				uiReceptor.addOffset('confirm');

			default:
				try
				{
					if (FileSystem.exists(Paths.module('$noteType/$noteType-$assetModifier', 'data/notetypes')))
					{
						var possibleModules:Array<String> = [
							Paths.module('$noteType/$noteType-$assetModifier', 'data/notetypes'),
							Paths.module('$noteType/$noteType-$assetModifier', 'songs/${PlayState.SONG.song}/notetypes')
						];
						for (module in possibleModules)
						{
							if (FileSystem.exists(module))
							{
								Note.noteMap.set(noteType, new ScriptHandler(module));
								Note.noteMap.get(noteType).call('generateReceptor', [uiReceptor]);
								// trace('Receptor Module loaded: $noteType-$assetModifier');
							}
						}
					}
				}
				catch (e)
				{
					// trace('[RECEPTOR ERROR] $e');

					// probably gonna revise this and make it possible to add other arrow types but for now it's just pixel and normal
					var stringSect:String = '';
					// call arrow type I think
					stringSect = Receptor.actions[receptorData];

					uiReceptor.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset('$framesArg', assetModifier, Init.trueSettings.get("Note Skin"),
						'$noteType/skins', 'data/notetypes'),
						'data/notetypes');

					uiReceptor.animation.addByPrefix('static', 'arrow' + stringSect.toUpperCase());
					uiReceptor.animation.addByPrefix('pressed', stringSect + ' press', 24, false);
					uiReceptor.animation.addByPrefix('confirm', stringSect + ' confirm', 24, false);

					uiReceptor.antialiasing = true;
					uiReceptor.setGraphicSize(Std.int(uiReceptor.width * 0.7));

					// set little offsets per note!
					// so these had a little problem honestly and they make me wanna off(set) myself so the middle notes basically
					// have slightly different offsets than the side notes (which have the same offset)

					var offsetMiddleX = 0;
					var offsetMiddleY = 0;
					if (receptorData > 0 && receptorData < 3)
					{
						offsetMiddleX = 2;
						offsetMiddleY = 2;
						if (receptorData == 1)
						{
							offsetMiddleX -= 1;
							offsetMiddleY += 2;
						}
					}

					uiReceptor.addOffset('static');
					uiReceptor.addOffset('pressed', -2, -2);
					uiReceptor.addOffset('confirm', 36 + offsetMiddleX, 36 + offsetMiddleY);
				}
		}

		return uiReceptor;
	}

	/**
	 * Notes!
	**/
	public static function generateArrow(framesArg, assetModifier, strumTime, noteData, noteType, ?isSustainNote:Bool = false, ?prevNote:Note = null):Note
	{
		if (framesArg == null || framesArg.length < 1)
			framesArg = 'NOTE_assets';
		var changeableSkin:String = Init.trueSettings.get("Note Skin");

		var newNote:Note;

		newNote = new Note(strumTime, noteData, noteType, prevNote, isSustainNote);

		try
		{
			if (FileSystem.exists(Paths.module('$noteType/$noteType-$assetModifier', 'data/notetypes')))
			{
				var possibleModules:Array<String> = [
					Paths.module('$noteType/$noteType-$assetModifier', 'data/notetypes'),
					Paths.module('$noteType/$noteType-$assetModifier', 'songs/${PlayState.SONG.song}/notetypes')
				];
				for (module in possibleModules)
				{
					if (FileSystem.exists(module))
					{
						Note.noteMap.set(noteType, new ScriptHandler(module));
						Note.noteMap.get(noteType).call(newNote.isSustainNote ? 'generateSustain' : 'generateNote', [newNote]);
						// trace('Note Module loaded: $noteType-$assetModifier');
					}
				}
			}
		}
		catch (e)
		{
			// trace('[NOTE ERROR] $e');

			// load default so the game won't explode in front of you;
			Note.resetNote(framesArg, changeableSkin, assetModifier, newNote);
			newNote.setGraphicSize(Std.int(newNote.width * (assetModifier == "pixel" ? PlayState.daPixelZoom : 0.7)));
			newNote.updateHitbox();
		}

		if (newNote.frames != null)
		{
			if (!isSustainNote)
			{
				if (newNote.animation.getByName(Receptor.colors[noteData] + 'Scroll') != null)
					newNote.animation.play(Receptor.colors[noteData] + 'Scroll');
			}

			if (isSustainNote && prevNote != null)
			{
				newNote.noteSpeed = prevNote.noteSpeed;
				newNote.alpha = (Init.trueSettings.get('Opaque Holds')) ? 1 : 0.6;
				if (newNote.animation.getByName(Receptor.colors[noteData] + 'holdend') != null)
					newNote.animation.play(Receptor.colors[noteData] + 'holdend');
				newNote.updateHitbox();
				if (prevNote.isSustainNote)
				{
					if (prevNote.animation.getByName(Receptor.colors[prevNote.noteData] + 'hold') != null)
						prevNote.animation.play(Receptor.colors[prevNote.noteData] + 'hold');
				}
			}
		}

		// hold note shit
		if (isSustainNote && prevNote != null)
		{
			// set note offset
			if (prevNote.isSustainNote)
				newNote.noteVisualOffset = prevNote.noteVisualOffset;
			else // calculate a new visual offset based on that note's width and newnote's width
				newNote.noteVisualOffset = ((prevNote.width / 2) - (newNote.width / 2));
		}

		return newNote;
	}

	/**
	 * Checkmarks!
	**/
	public static function generateCheckmark(x:Float, y:Float, asset:String, assetModifier:String = 'base', changeableSkin:String = 'default',
			baseLibrary:String)
	{
		var newCheckmark:Checkmark = new Checkmark(x, y);
		newCheckmark.frames = Paths.getSparrowAtlas(ForeverTools.returnSkinAsset(asset, assetModifier, changeableSkin, baseLibrary));
		newCheckmark.antialiasing = true;

		switch (assetModifier)
		{
			default:
				switch (changeableSkin.toLowerCase())
				{
					case "forever":
						newCheckmark.animation.addByPrefix('false', 'uncheck', 12, false);
						newCheckmark.animation.addByPrefix('true', 'check', 12, false);
						newCheckmark.animation.addByPrefix('false finished', 'uncheckFinished');
						newCheckmark.animation.addByPrefix('true finished', 'checkFinished');

						//
						newCheckmark.addOffset('false', 45, 5);
						newCheckmark.addOffset('true', 45, 5);
						newCheckmark.addOffset('true finished', 45, 5);
						newCheckmark.addOffset('false finished', 45, 5);
					default:
						// for week 7 assets
						newCheckmark.animation.addByPrefix('false', 'Check Box unselected', 24, false);
						newCheckmark.animation.addByPrefix('true', 'Check Box selecting animation', 24, false);
						newCheckmark.animation.addByPrefix('false finished', 'Check Box unselected', 24, false);
						newCheckmark.animation.addByPrefix('true finished', 'Check Box Selected Static', 24, true);

						//
						newCheckmark.addOffset('false', 2, -12);
						newCheckmark.addOffset('false finished', 2, -12);
						newCheckmark.addOffset('true', 20, 59);
						newCheckmark.addOffset('true finished', 12, 39);
				}
		}

		newCheckmark.setGraphicSize(Std.int(newCheckmark.width * 0.7));
		newCheckmark.updateHitbox();

		return newCheckmark;
	}
}

/**
 * This class is used as an extension to many other forever engine stuffs, please don't delete it as it is not only exclusively used in forever engine
 * custom stuffs, and is instead used globally.
**/
class ForeverTools
{
	/**
	 * [Resets the Main Menu Music]
	 * @param resetVolume - whether the song should fade in
	 */
	inline public static function resetMenuMusic(resetVolume:Bool = false)
	{
		// make sure the music is playing
		if (((FlxG.sound.music != null) && (!FlxG.sound.music.playing)) || (FlxG.sound.music == null))
		{
			var song = (Init.trueSettings.get("Custom Titlescreen") ? Paths.music('foreverMenu') : Paths.music('freakyMenu'));
			FlxG.sound.playMusic(song, (resetVolume) ? 0 : 0.7);
			if (resetVolume)
				FlxG.sound.music.fadeIn(4, 0, 0.7);
			// placeholder bpm
			Conductor.changeBPM(102);
		}
		//
	}

	inline public static function returnSkinAsset(asset:String, assetModifier:String = 'base', changeableSkin:String = 'default', baseLibrary:String,
			?baseFolder:String):String
	{
		if (baseFolder == null)
			baseFolder = 'images';
		baseFolder = Paths.getPath(baseFolder, IMAGE);

		var defaultChangeable:String = 'default';
		var defaultAssetModifier:String = 'base';

		var realAsset = '$baseLibrary/$changeableSkin/$assetModifier/$asset';
		if (!FileSystem.exists('$baseFolder/$realAsset.png'))
		{
			realAsset = '$baseLibrary/$defaultChangeable/$assetModifier/$asset';
			if (!FileSystem.exists('$baseFolder/$realAsset.png'))
				realAsset = '$baseLibrary/$defaultChangeable/$defaultAssetModifier/$asset';
		}

		return realAsset;
	}

	/**
	 * hehe funny variable names
	 * 
	 * Handles PlayState's camera zooming events
	 * @param leCam - Target Camera
	 * @param daZaza - Default Camera Zoom
	 * @param forceZaza - Forced Paramaters for Zooming / Changing Angle
	 */
	inline public static function cameraBumpingZooms(leCam:FlxCamera, daZaza:Float = 1.05, ?forceZaza:Array<Float>)
	{
		var easeLerp = 1 - Main.framerateAdjust(0.05);

		if (forceZaza == null)
			forceZaza = [0, 0, 0, 0];

		if (leCam != null)
		{
			// camera stuffs
			leCam.zoom = FlxMath.lerp(daZaza + forceZaza[0], leCam.zoom, easeLerp);

			// not even forceZoom anymore but still
			leCam.angle = FlxMath.lerp(0 + forceZaza[2], leCam.angle, easeLerp);
		}
	}

	inline public static function killMusic(songsArray:Array<FlxSound>)
	{
		// neat function thing for songs
		for (i in 0...songsArray.length)
		{
			// stop
			songsArray[i].stop();
			songsArray[i].destroy();
		}
	}

	inline public static function tweenJudgement(obj:FNFSprite)
	{
		if (obj != null)
		{
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				FlxTween.tween(obj, {alpha: 0}, 0.3, {
					onComplete: t ->
					{
						obj.kill();
					},
					startDelay: ((Conductor.crochet + Conductor.stepCrochet * 2) / 1000)
				});
			}
			else
			{
				FlxTween.tween(obj, {y: obj.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
				FlxTween.tween(obj, {"scale.x": 0, "scale.y": 0}, 0.1, {
					onComplete: t ->
					{
						obj.kill();
					},
					startDelay: ((Conductor.crochet + Conductor.stepCrochet * 2) / 1000)
				});
			}
		}
	}

	public static function returnTweenType(type:String = ''):FlxTweenType
	{
		switch (type.toLowerCase())
		{
			case 'backward':
				return FlxTweenType.BACKWARD;
			case 'looping':
				return FlxTweenType.LOOPING;
			case 'oneshot':
				return FlxTweenType.ONESHOT;
			case 'persist':
				return FlxTweenType.PERSIST;
			case 'pingpong':
				return FlxTweenType.PINGPONG;
		}
		return FlxTweenType.PERSIST;
	}

	public static function returnTweenEase(ease:String = '')
	{
		switch (ease.toLowerCase())
		{
			case 'linear':
				return FlxEase.linear;
			case 'backin':
				return FlxEase.backIn;
			case 'backinout':
				return FlxEase.backInOut;
			case 'backout':
				return FlxEase.backOut;
			case 'bouncein':
				return FlxEase.bounceIn;
			case 'bounceinout':
				return FlxEase.bounceInOut;
			case 'bounceout':
				return FlxEase.bounceOut;
			case 'circin':
				return FlxEase.circIn;
			case 'circinout':
				return FlxEase.circInOut;
			case 'circout':
				return FlxEase.circOut;
			case 'cubein':
				return FlxEase.cubeIn;
			case 'cubeinout':
				return FlxEase.cubeInOut;
			case 'cubeout':
				return FlxEase.cubeOut;
			case 'elasticin':
				return FlxEase.elasticIn;
			case 'elasticinout':
				return FlxEase.elasticInOut;
			case 'elasticout':
				return FlxEase.elasticOut;
			case 'expoin':
				return FlxEase.expoIn;
			case 'expoinout':
				return FlxEase.expoInOut;
			case 'expoout':
				return FlxEase.expoOut;
			case 'quadin':
				return FlxEase.quadIn;
			case 'quadinout':
				return FlxEase.quadInOut;
			case 'quadout':
				return FlxEase.quadOut;
			case 'quartin':
				return FlxEase.quartIn;
			case 'quartinout':
				return FlxEase.quartInOut;
			case 'quartout':
				return FlxEase.quartOut;
			case 'quintin':
				return FlxEase.quintIn;
			case 'quintinout':
				return FlxEase.quintInOut;
			case 'quintout':
				return FlxEase.quintOut;
			case 'sinein':
				return FlxEase.sineIn;
			case 'sineinout':
				return FlxEase.sineInOut;
			case 'sineout':
				return FlxEase.sineOut;
			case 'smoothstepin':
				return FlxEase.smoothStepIn;
			case 'smoothstepinout':
				return FlxEase.smoothStepInOut;
			case 'smoothstepout':
				return FlxEase.smoothStepInOut;
			case 'smootherstepin':
				return FlxEase.smootherStepIn;
			case 'smootherstepinout':
				return FlxEase.smootherStepInOut;
			case 'smootherstepout':
				return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	public static function returnBlendMode(str:String):BlendMode
	{
		return switch (str)
		{
			case "normal": BlendMode.NORMAL;
			case "darken": BlendMode.DARKEN;
			case "multiply": BlendMode.MULTIPLY;
			case "lighten": BlendMode.LIGHTEN;
			case "screen": BlendMode.SCREEN;
			case "overlay": BlendMode.OVERLAY;
			case "hardlight": BlendMode.HARDLIGHT;
			case "difference": BlendMode.DIFFERENCE;
			case "add": BlendMode.ADD;
			case "subtract": BlendMode.SUBTRACT;
			case "invert": BlendMode.INVERT;
			case _: BlendMode.NORMAL;
		}
	}

	public static function setTextAlign(str:String):FlxTextAlign
	{
		return switch (str)
		{
			case "center": FlxTextAlign.CENTER;
			case "justify": FlxTextAlign.JUSTIFY;
			case "left": FlxTextAlign.LEFT;
			case "right": FlxTextAlign.RIGHT;
			case _: FlxTextAlign.LEFT;
		}
	}

	public static function returnColor(str:String = ''):FlxColor
	{
		switch (str.toLowerCase())
		{
			case "black":
				FlxColor.BLACK;
			case "white":
				FlxColor.WHITE;
			case "blue":
				FlxColor.BLUE;
			case "brown":
				FlxColor.BROWN;
			case "cyan":
				FlxColor.CYAN;
			case "gray":
				FlxColor.GRAY;
			case "green":
				FlxColor.GREEN;
			case "lime":
				FlxColor.LIME;
			case "magenta":
				FlxColor.MAGENTA;
			case "orange":
				FlxColor.ORANGE;
			case "pink":
				FlxColor.PINK;
			case "purple":
				FlxColor.PURPLE;
			case "red":
				FlxColor.RED;
			case "transparent":
				FlxColor.TRANSPARENT;
		}
		return FlxColor.WHITE;
	}

	public static function getPoint(point:String):FlxAxes
	{
		switch (point.toLowerCase())
		{
			case 'x':
				return FlxAxes.X;
			case 'y':
				return FlxAxes.Y;
			case 'xy':
				return FlxAxes.XY;
		}
		return FlxAxes.XY;
	}

	inline public static function createTypedGroup(?variable)
	{
		variable = new FlxTypedGroup<Dynamic>();
		return variable;
	}

	inline public static function createSpriteGroup(?variable)
	{
		variable = new FlxSpriteGroup();
		return variable;
	}

	// FLXCOLOR;

	inline public static function fromHSB(hue:Float, sat:Float, brt:Float, alpha:Float):FlxColor
		return FlxColor.fromHSB(hue, sat, brt, alpha);

	inline public static function fromRGB(red:Int, green:Int, blue:Int, alpha:Int):FlxColor
		return FlxColor.fromRGB(red, green, blue, alpha);

	inline public static function fromRGBFloat(red:Float, green:Float, blue:Float, alpha:Float):FlxColor
		return FlxColor.fromRGBFloat(red, green, blue, alpha);

	inline public static function fromInt(value:Int):FlxColor
		return FlxColor.fromInt(value);

	inline public static function fromString(str:String):FlxColor
		return FlxColor.fromString(str);
}
