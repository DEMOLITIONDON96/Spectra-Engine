package objects.ui;

import base.utils.FNFUtils.FNFSprite;

/**
 * Create the note splashes in week 7 whenever you get a sick!
**/
class NoteSplash extends FNFSprite
{
	public function new(noteData:Int)
	{
		super(x, y);
		alpha = 0;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// kill the note splash if it's done
		if (animation != null)
		{
			animation.finishCallback = function(name:String)
			{
				kill();
			}
		}
		//
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		// make sure the animation is visible
		if (Init.trueSettings.get('Splash Opacity') > 0 && this.visible)
			alpha = Init.trueSettings.get('Splash Opacity') * 0.01;

		super.playAnim(AnimName, Force, Reversed, Frame);
	}
}
