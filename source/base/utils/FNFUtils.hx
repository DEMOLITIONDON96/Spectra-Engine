package base.utils;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import states.MusicBeatState.MusicBeatSubstate;

/**
 * Base Flixel Game override, for handling errors and other extra FNF Related stuff!
**/
class FNFGame extends FlxGame
{
	public function forceSwitch(next:FlxState)
	{
		_requestedState = next;
		switchState();
	}
}

/**
 * Transition overrides
 * @author Shadow_Mario_
**/
class FNFTransition extends MusicBeatSubstate
{
	public static var finishCallback:Void->Void;

	private var leTween:FlxTween = null;

	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool)
	{
		super();

		this.isTransIn = isTransIn;
		var width:Int = Std.int(FlxG.width);
		var height:Int = Std.int(FlxG.height);
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, 0xFF000000] : [0xFF000000, 0x0]));
		transGradient.scrollFactor.set();
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(width, height + 400, 0xFF000000);
		transBlack.scrollFactor.set();
		add(transBlack);

		transGradient.x -= (width - FlxG.width) / 2;
		transBlack.x = transGradient.x;

		if (isTransIn)
		{
			transGradient.y = transBlack.y - transBlack.height;
			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					close();
				},
				ease: FlxEase.linear
			});
		}
		else
		{
			transGradient.y = -transGradient.height;
			transBlack.y = transGradient.y - transBlack.height + 50;
			leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween)
				{
					if (finishCallback != null)
						finishCallback();
				},
				ease: FlxEase.linear
			});
		}
	}

	override function update(elapsed:Float)
	{
		if (isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		var camList = FlxG.cameras.list;
		camera = camList[camList.length - 1];
		transBlack.cameras = [camera];
		transGradient.cameras = [camera];

		super.update(elapsed);

		if (isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;
	}

	override function destroy()
	{
		if (leTween != null)
		{
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}

/**
 * Global FNF sprite utilities, all in one parent class!
 * You'll be able to easily edit functions and such that are used by sprites
**/
class FNFSprite extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var zDepth:Float = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();

		antialiasing = !Init.trueSettings.get('Disable Antialiasing');
	}

	/*
	 * Sorts through the Object's zDepth value and returns the object in a given order;
	 * @author Yoshubs;
	 */
	public static inline function depthSorting(Order:Int, Obj1:FNFSprite, Obj2:FNFSprite)
	{
		if (Obj1.zDepth > Obj2.zDepth)
			return -Order;
		return Order;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):FNFSprite
	{
		var graph:FlxGraphic = (FlxG.bitmap.add(Graphic, Unique, Key));
		if (graph == null)
			return this;

		if (Width == 0)
		{
			Width = Animated ? graph.height : graph.width;
			Width = (Width > graph.width) ? graph.width : Width;
		}

		if (Height == 0)
		{
			Height = Animated ? Width : graph.height;
			Height = (Height > graph.height) ? graph.height : Height;
		}

		if (Animated)
			frames = FlxTileFrames.fromGraphic(graph, FlxPoint.get(Width, Height));
		else
			frames = graph.imageFrame;

		return this;
	}

	override public function destroy()
	{
		// dump cache stuffs
		if (graphic != null)
			graphic.dump();

		super.destroy();
	}
}
