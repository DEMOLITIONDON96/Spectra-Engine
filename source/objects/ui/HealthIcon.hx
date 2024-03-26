package objects.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import sys.FileSystem;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public var canBounce:Bool = true;
	public var suffix:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public dynamic function updateAnim(health:Float)
	{
		if (frames.frames.length >= 5 && health < 10)
			animation.curAnim.curFrame = 3;
		else if (frames.frames.length >= 5 && health > 90)
			animation.curAnim.curFrame = 4;
		else if (frames.frames.length >= 3 && health > 80)
			animation.curAnim.curFrame = 2;
		else if (frames.frames.length >= 2 && health < 20)
			animation.curAnim.curFrame = 1;
		else
			animation.curAnim.curFrame = 0;
	}

	public function bop(elapsed:Float)
	{
		if (!canBounce)
			return;

		var mult:Float = Init.trueSettings.get("HUD Style") == "spectra" ? FlxMath.lerp(0.78, scale.x, FlxMath.bound(1 - (elapsed * 9), 0, 0.78)) : FlxMath.lerp(1, scale.x, FlxMath.bound(1 - (elapsed * 9), 0, 1));
		scale.set(mult, mult);
		updateHitbox();
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var trimmedChar:String = char;
		if (trimmedChar.contains('-'))
			trimmedChar = trimmedChar.substring(0, trimmedChar.indexOf('-'));

		var iconPath = char;
		if (!FileSystem.exists(Paths.getPath('data/characters/$iconPath/icon$suffix.png', IMAGE)))
		{
			if (iconPath != trimmedChar)
				iconPath = trimmedChar;
			else
				iconPath = 'placeholder';
		}

		antialiasing = true;

		var iconGraphic:FlxGraphic = Paths.image('$iconPath/icon$suffix', 'data/characters');
		var iconWidth:Int = 1;

		loadGraphic(iconGraphic); // get file size;

		// icons with endless frames;
		iconWidth = Std.int(iconGraphic.width / 150) - 1;
		iconWidth = iconWidth + 1;

		loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / iconWidth), iconGraphic.height); // then load it;

		initialWidth = width;
		initialHeight = height;

		animation.add('icon', [for (i in 0...frames.frames.length) i], 0, false, isPlayer);
		animation.play('icon');
		scrollFactor.set();
	}
}
