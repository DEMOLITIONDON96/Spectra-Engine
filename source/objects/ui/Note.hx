package objects.ui;

import base.dependency.FeatherDeps.ScriptHandler;
import base.song.Conductor;
import base.utils.FNFUtils.FNFSprite;
import base.utils.ScoreUtils;
import flixel.FlxSprite;
import objects.ui.Strumline.Receptor;

class Note extends FNFSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;

	public var noteType:String = 'default';
	public var noteString:String = "";
	public var noteSuffix:String = "";
	public var noteTimer:Float = 0;

	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var canDie:Bool = true;
	public var ignoreNote:Bool = false;
	public var noteSplash:Bool = false;
	public var isMine:Bool = false;

	// not set initially
	public var noteQuant:Int = -1;
	public var noteVisualOffset:Float = 0;
	public var noteDirection:Float = 0;

	// values
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var noteSpeed(default, set):Float;

	public function set_noteSpeed(value:Float):Float
	{
		if (noteSpeed != value)
		{
			noteSpeed = value;
			updateSustainScale();
		}
		return noteSpeed;
	}

	public var parentNote:Note;
	public var childrenNotes:Array<Note> = [];

	public static var swagWidth:Float = 160 * 0.7;

	public var holdHeight = 0.713; // shitty hold note hack for sustain scales, i hate it;

	// it has come to this.
	public var endHoldOffset:Float = Math.NEGATIVE_INFINITY;

	public static var noteMap:Map<String, ScriptHandler> = new Map();

	public function new(strumTime:Float, noteData:Int, noteType:String, ?prevNote:Note, ?isSustainNote:Bool = false)
	{
		this.prevNote = prevNote;
		this.isSustainNote = isSustainNote;
		this.strumTime = strumTime;
		this.noteData = noteData;

		if (prevNote == null)
			prevNote = this;

		if (noteType == null)
			noteType = 'default';

		isMine = false;

		super(x, y);

		// oh okay I know why this exists now
		y -= 2000;

		// determine parent note
		if (isSustainNote && prevNote != null)
		{
			parentNote = prevNote;
			this.noteString = parentNote.noteString;
			this.noteSuffix = parentNote.noteSuffix;
			this.noteTimer = parentNote.noteTimer;
			this.noteQuant = parentNote.noteQuant;
			this.isMine = parentNote.isMine;
			while (parentNote.parentNote != null)
				parentNote = parentNote.parentNote;
			parentNote.childrenNotes.push(this);
		}
		else if (!isSustainNote)
			parentNote = null;

		antialiasing = !Init.trueSettings.get('Disable Antialiasing');
	}

	public function updateSustainScale()
	{
		if (isSustainNote)
		{
			alpha = Init.trueSettings.get('Hold Opacity') * 0.01;
			if (prevNote != null && prevNote.exists)
			{
				if (prevNote.isSustainNote)
				{
					// listen I dont know what i was doing but I was onto something
					prevNote.scale.y = (prevNote.width / prevNote.frameWidth) * ((Conductor.stepCrochet / 100) * (1.07 / holdHeight)) * noteSpeed;
					prevNote.updateHitbox();
					offsetX = prevNote.offsetX;
				}
				else
					offsetX = ((prevNote.width / 2) - (width / 2));
			}
		}
	}

	function getNoteColor(noteData)
		return Receptor.colors[noteData];

	function getNoteAction(noteData)
		return Receptor.actions[noteData];

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (strumTime > Conductor.songPosition - (ScoreUtils.msThreshold)
				&& strumTime < Conductor.songPosition + (ScoreUtils.msThreshold))
				canBeHit = true;
			else
				canBeHit = false;
		}
		else // make sure the note can't be hit if it's the dad's I guess
			canBeHit = false;

		if (tooLate || (parentNote != null && parentNote.tooLate))
			alpha = 0.3;

		noteCall(this.noteType, 'update', [elapsed]);
	}

	public static function resetNote(framesArg:String, changeable:String = '', assetModifier:String, newNote:Note)
	{
		var pixelData:Array<Int> = [4, 5, 6, 7];

		if (framesArg.length < 2 || framesArg == null)
		{
			if (assetModifier == 'pixel')
			{
				if (newNote.isSustainNote)
					framesArg = 'arrowEnds';
				else
					framesArg = 'arrows-pixels';
			}
			else
				framesArg = 'NOTE_assets';
		}

		var stringSect = Receptor.colors[newNote.noteData];

		if (assetModifier != 'pixel')
		{
			var skinAssetPath:String = ForeverTools.returnSkinAsset(framesArg, assetModifier, changeable, '${newNote.noteType}/skins', 'data/notetypes');
			newNote.frames = Paths.getSparrowAtlas(skinAssetPath, 'data/notetypes');

			newNote.animation.addByPrefix(stringSect + 'Scroll', stringSect + '0');
			newNote.animation.addByPrefix(stringSect + 'holdend', stringSect + ' hold end');
			newNote.animation.addByPrefix(stringSect + 'hold', stringSect + ' hold piece');

			newNote.animation.addByPrefix('purpleholdend', 'pruple end hold'); // PA god dammit.
			newNote.animation.play(stringSect + 'Scroll');
		}
		else
		{
			if (newNote.isSustainNote)
			{
				var skinAssetPath:String = ForeverTools.returnSkinAsset(framesArg, assetModifier, changeable, '${newNote.noteType}/skins', 'data/notetypes');
				newNote.loadGraphic(Paths.image(skinAssetPath, 'data/notetypes'), true, 7, 6);

				newNote.animation.add(stringSect + 'holdend', [pixelData[newNote.noteData]]);
				newNote.animation.add(stringSect + 'hold', [pixelData[newNote.noteData] - 4]);
			}
			else
			{
				var skinAssetPath:String = ForeverTools.returnSkinAsset(framesArg, assetModifier, changeable, '${newNote.noteType}/skins', 'data/notetypes');
				newNote.loadGraphic(Paths.image(skinAssetPath, 'data/notetypes'), true, 17, 17);
				newNote.animation.add(stringSect + 'Scroll', [pixelData[newNote.noteData]], 12);
				newNote.animation.play(stringSect + 'Scroll');
			}
		}

		newNote.isMine = false;
	}

	public function noteHit()
		noteCall(this.noteType, 'onHit', [this]);

	public function noteMiss()
		noteCall(this.noteType, 'onMiss', [this]);

	public function stepHit(curStep:Int)
		noteCall(this.noteType, 'onStep', [this, curStep]);

	public function beatHit(curBeat:Int)
		noteCall(this.noteType, 'onBeat', [this, curBeat]);

	function noteCall(type:String, name:String, args:Array<Dynamic>)
	{
		if (noteMap.exists(type))
		{
			var noteScript:ScriptHandler = noteMap.get(type);
			noteScript.call(name, args);
		}
	}

	public function determineQuantIndex(strumTime:Float, newNote:Note)
	{
		/*
			I have to credit like 3 different people for these LOL they were a hassle
			but its gede pixl and scarlett, thank you SO MUCH for baring with me
		 */
		final quantArray:Array<Int> = [4, 8, 12, 16, 20, 24, 32, 48, 64, 192]; // different quants

		var curBPM:Float = Conductor.bpm;
		var newTime:Float = strumTime;

		final beatTimeSeconds:Float = (60 / curBPM); // beat in seconds
		final beatTime:Float = beatTimeSeconds * 1000; // beat in milliseconds
		final measureTime:Float = beatTime * 4; // assumed 4 beats per measure?

		final smallestDeviation:Float = measureTime / quantArray[quantArray.length - 1];

		if (newNote.noteQuant == -1)
		{
			for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (strumTime > Conductor.bpmChangeMap[i].songTime)
				{
					curBPM = Conductor.bpmChangeMap[i].bpm;
					newTime = strumTime - Conductor.bpmChangeMap[i].songTime;
				}
			}

			for (quant in 0...quantArray.length)
			{
				// please generate this ahead of time and put into array :)
				// I dont think I will im scared of those
				final quantTime = (measureTime / quantArray[quant]);
				if ((newTime #if !neko + Init.trueSettings['Offset'] #end + smallestDeviation) % quantTime < smallestDeviation * 2)
				{
					// here it is, the quant, finally!
					newNote.noteQuant = quant;
					break;
				}
			}
		}

		return quantArray.length - 1;
	}
}
