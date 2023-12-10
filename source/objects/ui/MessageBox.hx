package objects.ui;

import flixel.util.FlxSignal;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.text.FlxText;

class MessageBox extends FlxTypedGroup<FlxBasic>
{
    public var box:FlxSprite;
    public var boxText:FlxText;
    public var boxSubText:FlxText;

    // var onDeny = new FlxSignal();

    // stupid ahh tweens (they're extremly useless) !!
    var freeplayTxtTween:FlxTween;
	var freeplayTxtTween2:FlxTween;
	var freeplayTxtTween3:FlxTween;

    public function new(x:Float = 0, y:Float = 0, utils:Utils) {
        // null checks
        if (utils.text == null) utils.text = "this is a message";
        if (utils.subText == null) utils.subText = "this is a sub text";
        if (utils.font == null) utils.font = 'vcr';
        if (utils.textColor == null) utils.textColor = FlxColor.WHITE;
        if (utils.boxWidth == null) utils.boxWidth = 360;
        if (utils.boxHeight == null) utils.boxHeight = 90;
        if (utils.boxColor == null) utils.boxColor = FlxColor.BLACK;
        if (utils.camera == null) utils.camera = FlxG.cameras.list[FlxG.cameras.list.length - 1];

        super();

        boxText = new FlxText(x, y, 0, utils.text, 24);
		boxText.setFormat(Paths.font(utils.font), 32, 0xFFFFFFFF, EngineTools.setTextAlign('left'), FlxTextBorderStyle.OUTLINE, 0xFF000000);
		boxText.scrollFactor.set();
		boxText.camera = utils.camera;

		boxSubText = new FlxText(x, boxText.y + 30, 0, utils.subText, 24);
		boxSubText.setFormat(Paths.font(utils.font), 24, 0xFFFFFFFF, EngineTools.setTextAlign('left'), FlxTextBorderStyle.OUTLINE, 0xFF000000);
		boxSubText.scrollFactor.set();
		boxSubText.camera = utils.camera;

		box = new FlxSprite(x, boxText.y).makeGraphic(utils.boxWidth, utils.boxHeight, utils.boxColor);
		box.scrollFactor.set();
		box.camera = utils.camera;

        box.alpha = boxText.alpha = boxSubText.alpha = 0;

        add(box);
		add(boxText);
		add(boxSubText);
    }

    public function sendMessage(text:String = 'text', subText:String = '')
    {
        if (freeplayTxtTween != null)
            freeplayTxtTween.cancel();
        if (freeplayTxtTween2 != null)
            freeplayTxtTween2.cancel();
        if (freeplayTxtTween3 != null)
            freeplayTxtTween3.cancel();

        boxText.text = text;
        boxSubText.text = subText;

        freeplayTxtTween = FlxTween.tween(boxText, {
            alpha: 1,
            x: 0
        }, 0.8, {
            ease: FlxEase.sineOut,
            onComplete: function(twn:FlxTween)
            {
                freeplayTxtTween = FlxTween.tween(boxText, {
                    alpha: 0,
                    x: -400
                }, 1.5, {
                    startDelay: 3,
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        freeplayTxtTween = null;
                    }
                });
            }
        });
        freeplayTxtTween2 = FlxTween.tween(boxSubText, {
            alpha: 1,
            x: 0
        }, 0.8, {
            ease: FlxEase.sineOut,
            onComplete: function(twn:FlxTween)
            {
                freeplayTxtTween2 = FlxTween.tween(boxSubText, {
                    alpha: 0,
                    x: -400
                }, 1.5, {
                    startDelay: 3,
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        freeplayTxtTween2 = null;
                    }
                });
            }
        });
        freeplayTxtTween3 = FlxTween.tween(box, {
            alpha: 1,
            x: 0
        }, 0.8, {
            ease: FlxEase.sineOut,
            onComplete: function(twn:FlxTween)
            {
                freeplayTxtTween3 = FlxTween.tween(box, {
                    alpha: 0,
                    x: -400
                }, 1.5, {
                    startDelay: 3,
                    ease: FlxEase.sineInOut,
                    onComplete: function(twn:FlxTween)
                    {
                        freeplayTxtTween3 = null;
                    }
                });
            }
        });
    }
}