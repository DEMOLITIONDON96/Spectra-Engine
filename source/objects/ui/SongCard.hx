package objects.ui;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.group.FlxSpriteGroup;
import states.PlayState;

using flixel.util.FlxSpriteUtil;

class SongCard extends FlxSpriteGroup
{	
      // Pre-made Text
      //public var composer:String = PlayState.SONG.composer;
      public var songTitle:String = PlayState.SONG.song;

      // Files to look for
      public var fontStuff:String = "vcr";
      public var fileName:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
      public var pIconName:String = PlayState.boyfriend.characterData.icon;
      public var oIconName:String = PlayState.opponent.characterData.icon;

      // Base Card Setup
      public var cardTxt:FlxText;
      public var cardSprite:FlxSprite;

      // Health Icons
      public var opponentIcon:HealthIcon;
      public var playerIcon:HealthIcon;
  
      function setupCardData()
      {
           switch (PlayState.SONG.song)
           {
               // For adding custom fonts to your songs
               default: 
                 fontStuff = "vcr";
           }
      }
  
     public function new()
     {
         super();

         // Loads your fonts
         setupCardData();

         cardTxt = new FlxText(cardSprite.x, cardSprite.y, 0, '- ${songTitle} -');
       
         if (!FileSystem.exists('./assets/images/card/${fileName}.png'))
             cardSprite = new FlxSprite().makeGraphic(600, 350, 0xFF000000);
         else
             cardSprite = new FlxSprite().loadGraphic(Paths.image('menus/Funkin_avi/card/${fileName}'));

         cardTxt.setFormat(Paths.font(fontStuff), 38, FlxColor.WHITE, CENTER);

         cardSprite.alpha = 0.001;
         cardSprite.screenCenter();

         opponentIcon = new HealthIcon(oIconName, false);
         opponentIcon.animation.curAnim.curFrame = 2;
         opponentIcon.x = cardSprite.x - 90;
         opponentIcon.y = cardSprite.y - 50;
         opponentIcon.alpha = 0.001;

         playerIcon = new HealthIcon(pIconName, true);
         playerIcon.animation.curAnim.curFrame = 2;
         playerIcon.x = cardSprite.x + 525;
         playerIcon.y = cardSprite.y + 280;
         playerIcon.alpha = 0.001;

         cardTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
         cardTxt.screenCenter();
         cardTxt.alpha = 0.001;

         add(cardSprite);
         add(cardTxt);
         add(opponentIcon);
         add(playerIcon);
     }

      // This is a function in case you want the card to show up later in the song instead of instantly
     public function playCardAnim(delaySet:Float = 0)
     {	
      // Fade Stuff
      FlxTween.tween(cardSprite, {alpha: 0.85}, 1.5, {ease: FlxEase.sineInOut, startDelay: delaySet,
            onComplete: function(twn:FlxTween)
            {
              FlxTween.tween(cardSprite, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3.5});
            }
        });
      FlxTween.tween(cardTxt, {alpha: 1}, 2, {ease: FlxEase.sineInOut, startDelay: delaySet,
            onComplete: function(twn:FlxTween)
            {
              FlxTween.tween(cardTxt, {alpha: 0}, 2, {ease: FlxEase.sineInOut, startDelay: 3.5});
            }
        });
      FlxTween.tween(opponentIcon, {alpha: 1}, 2.2, {ease: FlxEase.sineInOut, startDelay: delaySet,
            onComplete: function(twn:FlxTween)
            {
              FlxTween.tween(opponentIcon, {alpha: 0}, 2.2, {ease: FlxEase.sineInOut, startDelay: 3.5});
            }
        });
      FlxTween.tween(playerIcon, {alpha: 1}, 2.2, {ease: FlxEase.sineInOut, startDelay: delaySet,
            onComplete: function(twn:FlxTween)
            {
              FlxTween.tween(playerIcon, {alpha: 0}, 2.2, {ease: FlxEase.sineInOut, startDelay: 3.5});
            }
        });
      }

      override function add(Object:FlxSprite):FlxSprite
    {
      if (Std.isOfType(Object, FlxText))
        cast(Object, FlxText).antialiasing = !Init.trueSettings.get('Disable Antialiasing');
      if (Std.isOfType(Object, FlxSprite))
        cast(Object, FlxSprite).antialiasing = !Init.trueSettings.get('Disable Antialiasing');
      return super.add(Object);
    }
}
