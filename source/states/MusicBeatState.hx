package states;

import flixel.FlxSprite;
import base.song.Conductor;
import base.utils.FNFUtils.FNFTransition;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

/* 
	Music beat state happens to be the first thing on my list of things to add, it just so happens to be the backbone of
	most of the project in its entirety. It handles a couple of functions that have to do with actual music and songs and such.

	I'm not going to change any of this because I don't truly understand how songplaying works, 
	I mostly just wanted to rewrite the actual gameplay side of things.
 */
class MusicBeatState extends FlxUIState
{
	public var stepsToDo:Int = 0;

	public var lastStep:Int = 0;
	public var lastBeat:Int = 0;
	public var lastSection:Int = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var curSection:Int = 0;

	// fixes a bug with FlxUITabMenu where it wouldn't respect the current camera zoom
	public var camBeat:FlxCamera;

	// class create event
	override function create()
	{
		FlxSprite.defaultAntialiasing = !Init.trueSettings.get("Disable Antialiasing");
		
		// dump
		var clearPlayState = (PlayState.clearStored && !Std.isOfType(this, states.PlayState));
		if ((clearPlayState))
			Paths.clearStoredMemory();

		if ((!Std.isOfType(this, states.editors.OriginalChartingState)))
			Paths.clearUnusedMemory();

		// create controls event;
		Controls.keyEventPress.add(keyEventPress);
		Controls.keyEventRelease.add(keyEventRelease);

		camBeat = FlxG.camera;

		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new FNFTransition(0.5, true));

		super.create();

		// For debugging
		FlxG.watch.add(Conductor, "songPosition");
		FlxG.watch.add(this, "curBeat");
		FlxG.watch.add(this, "curStep");
		FlxG.watch.add(this, "curSection");
	}

	override function destroy()
	{
		// destroy controls;
		Controls.keyEventPress.remove(keyEventPress);
		Controls.keyEventRelease.remove(keyEventRelease);

		super.destroy();
	}

	public function keyEventPress(action:String, key:Int, state:KeyState) {}

	public function keyEventRelease(action:String, key:Int, state:KeyState) {}

	// class 'step' event
	override function update(elapsed:Float)
	{
		updateContents();

		Main.globalElapsed = elapsed;

		super.update(elapsed);
	}

	public function updateContents()
	{
		updateCurStep();
		updateBeat();

		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curStep / 16);

		// delta time bullshit
		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);
		for (i in oldStep...trueStep)
		{
			if (!storedSteps.contains(i) && i > 0)
			{
				curStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
			skippedSteps = [];
		curStep = trueStep;

		if (oldStep != curStep && !storedSteps.contains(curStep))
		{
			if (curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}
		oldStep = curStep;
	}

	var oldStep:Int = 0;
	var storedSteps:Array<Int> = [];
	var skippedSteps:Array<Int> = [];

	public function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	public function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getStepsOnSection());
		while(curStep >= stepsToDo)
		{
			var beats:Float = getStepsOnSection() / 4;
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}
	
	public function rollbackSection():Void
	{
		if(curStep < 0) return;

		lastSection = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getStepsOnSection());
				if(stepsToDo > curStep) break;
			}
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();

		if (!storedSteps.contains(curStep))
			storedSteps.push(curStep);

		if (lastStep >= curStep)
			return;

		if (curStep != lastStep)
			lastStep = curStep;
	}

	public function beatHit():Void
	{
		if (lastBeat >= curBeat)
			return;

		if (curBeat != lastBeat)
			lastBeat = curBeat;
	}

	public function sectionHit():Void
	{
		if (lastSection >= curSection)
			return;

		if (curSection != lastSection)
			lastSection = curSection;
	}

	public function getStepsOnSection()
	{
		var val:Null<Float> = 16;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].lengthInSteps;
		return val == null ? 16 : val;
	}

	var textField:FlxText;
	var fieldTween:FlxTween;

	public function logTrace(input:String, duration:Float, traceOnConsole:Bool = true)
	{
		if (traceOnConsole)
			trace(input);
		if (textField != null)
		{
			var oldField:FlxText = cast textField;
			FlxTween.tween(oldField, {alpha: 0}, 0.6, {
				onComplete: function(twn:FlxTween)
				{
					remove(oldField);
					oldField.destroy();
				}
			});
			textField = null;
		}

		if (fieldTween != null)
		{
			fieldTween.cancel();
			fieldTween = null;
		}

		if (input != '' && duration > 0)
		{
			textField = new FlxText(0, 0, FlxG.width, input);
			textField.setFormat(Paths.font("vcr"), 32, 0xFFFFFFFF, CENTER);
			textField.setBorderStyle(OUTLINE, 0xFF000000, 2);
			textField.alpha = 0;
			textField.screenCenter(X);
			textField.scrollFactor.set();
			add(textField);

			fieldTween = FlxTween.tween(textField, {alpha: 1}, 0.2, {
				onComplete: function(twn:FlxTween)
				{
					fieldTween = FlxTween.tween(textField, {alpha: 0}, 0.2, {
						startDelay: duration,
						onComplete: function(twn:FlxTween)
						{
							remove(textField);
							textField.destroy();
							textField = null;
							if (fieldTween == twn)
								fieldTween = null;
						}
					});
				}
			});
		}
	}
}

class MusicBeatSubstate extends FlxSubState
{
	private var lastStep:Int = 0;
	private var lastBeat:Int = 0;
	private var lastSection:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curSection:Int = 0;

	override function create()
	{
		// create controls event;
		Controls.keyEventPress.add(keyEventPress);
		Controls.keyEventRelease.add(keyEventRelease);

		super.create();
	}

	override function destroy()
	{
		// destroy controls;
		Controls.keyEventPress.remove(keyEventPress);
		Controls.keyEventRelease.remove(keyEventRelease);

		super.destroy();
	}

	public function keyEventPress(action:String, key:Int, state:KeyState) {}

	public function keyEventRelease(action:String, key:Int, state:KeyState) {}

	override function update(elapsed:Float)
	{
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);
		curSection = Math.floor(curStep / 16);

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();

		if (lastStep >= curStep)
			return;

		if (curStep != lastStep)
			lastStep = curStep;
	}

	public function beatHit():Void
	{
		if (lastBeat >= curBeat)
			return;

		if (curBeat != lastBeat)
			lastBeat = curBeat;
	}

	public function sectionHit():Void
	{
		if (lastSection >= curSection)
			return;

		if (curSection != lastSection)
			lastSection = curSection;
	}
}
