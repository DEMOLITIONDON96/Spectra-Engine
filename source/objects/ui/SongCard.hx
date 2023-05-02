package objects.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import haxe.Json;
import states.PlayState;
import sys.FileSystem;
import sys.io.File;

using flixel.util.FlxSpriteUtil;

class SongCard extends FlxSpriteGroup
{	
	// Pre-made Text
	public var composer:String = PlayState.SONG.composer;
	public var songTitle:String = PlayState.SONG.song;

	// JSON Var Helpers
	public var fontStuff:String = "vcr";
	public var artFile:String = "test";
	public var fileName:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
	public var pIconName:String = PlayState.boyfriend.characterData.icon;
	public var oIconName:String = PlayState.opponent.characterData.icon;
	public var fontColor:FlxColor = FlxColor.WHITE;
	public var fontSize:Int = 42;
	public var fontOffsetX:Float = 0;
	public var fontOffsetY:Float = 0;
	public var cardScaleX:Float = 1;
	public var cardScaleY:Float = 1;
	public var animName:String = "card";
	public var animFPS:Int = 24;
	public var alignString:String = "center";
	public var fontScaleX:Float = 1;
	public var fontScaleY:Float = 1;
	public var tweenInVal:String = "linear";
	public var tweenOutVal:String = "linear";
	public var cardIntroPosX:Float = 0;
	public var cardIntroPosY:Float = 0;
	public var playerIntroPosX:Float = 0;
	public var playerIntroPosY:Float = 0;
	public var oppIntroPosX:Float = 0;
	public var oppIntroPosY:Float = 0;
	public var fontIntroPosX:Float = 0;
	public var fontIntroPosY:Float = 0;
	public var cardOutroPosX:Float = 0;
	public var cardOutroPosY:Float = 0;
	public var playerOutroPosX:Float = 0;
	public var playerOutroPosY:Float = 0;
	public var oppOutroPosX:Float = 0;
	public var oppOutroPosY:Float = 0;
	public var fontOutroPosX:Float = 0;
	public var fontOutroPosY:Float = 0;
	public var cardShader:FlxRuntimeShader;
	public var cardShaderName:String = "vhs";
	public var playerShader:FlxRuntimeShader;
	public var pShaderName:String = "vhs";
	public var opponentShader:FlxRuntimeShader;
	public var oShaderName:String = "vhs";
	public var cardBlend:String = "normal";
	public var playerBlend:String = "normal";
	public var opponentBlend:String = "normal";
	
	// Card Data Categories
	public var cardData:SongCardData;
	public var cardAdvanced:SongCardData;
	public var cardAnimation:SongCardData;
	public var cardIcons:SongCardData;
	public var cardFont:SongCardData;
	public var cardTween:SongCardData;
	public var cardFX:SongCardData;

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
				default: 
					fontStuff = "vcr";
			}
	}
	
	 public function new()
	 {
		   super();

		   setupCardData();

		   cardSprite = new FlxSprite();

		   if (FileSystem.exists('./assets/data/cardData/${fileName}.json')) 
		   {
				var rawJson = File.getContent(Paths.getPath('data/cardData/${fileName}.json', TEXT));
				cardData = cast Json.parse(rawJson).baseSettings;
				cardAdvanced = cast Json.parse(rawJson).extraSettings;
				cardIcons = cast Json.parse(rawJson).iconSettings;
				cardFont = cast Json.parse(rawJson).fontSettings;
				cardAnimation = cast Json.parse(rawJson).animationSettings;
				cardFX = cast Json.parse(rawJson).graphicSettings;

				// baseSettings
				artFile = cardData.customArt;
				pIconName = (cardData.playerIcon != null ? cardData.playerIcon : PlayState.boyfriend.characterData.icon);
				oIconName = (cardData.opponentIcon != null ? cardData.opponentIcon : PlayState.opponent.characterData.icon);

				// fontSettings
				fontStuff = (cardFont.font != null ? cardFont.font : "vcr");
				fontSize = (cardFont.fontSize != null ? cardFont.fontSize[0] : 42);
				fontColor = (cardFont.fontColor != null ? FlxColor.fromRGBFloat(cardFont.fontColor[0], cardFont.fontColor[1], cardFont.fontColor[2], cardFont.fontColor[3]) : FlxColor.WHITE);
				alignString = cardFont.fontAlignType;
				fontScaleX = (cardFont.fontScale != null ? cardFont.fontScale[0] : 1);
				fontScaleY = (cardFont.fontScale != null ? cardFont.fontScale[1] : 1);
				fontOffsetX = (cardFont.fontOffset != null ? cardFont.fontOffset[0] : 0);
				fontOffsetY = (cardFont.fontOffset != null ? cardFont.fontOffset[1] : 0);

				// extraSettings
				cardScaleX = (cardAdvanced.cardScale != null ? cardAdvanced.cardScale[0] : 1);
				cardScaleY = (cardAdvanced.cardScale != null ? cardAdvanced.cardScale[1] : 1);

				cardBlend = cardFX.cardBlend;
				playerBlend = cardFX.playerBlend;
				opponentBlend = cardFX.opponentBlend;

				if (!Init.trueSettings.get('Disable Screen Shaders'))
				{
					cardShaderName = cardFX.cardShader;
					oShaderName = cardFX.opponentShader;
					pShaderName = cardFX.playerShader;

					if (cardShaderName != null) cardShader = new FlxRuntimeShader(File.getContent('./assets/shaders/${cardShaderName}.frag'), null, 150);
					if (pShaderName != null) playerShader = new FlxRuntimeShader(File.getContent('./assets/shaders/${pShaderName}.frag'), null, 150);
					if (oShaderName != null) opponentShader = new FlxRuntimeShader(File.getContent('./assets/shaders/${oShaderName}.frag'), null, 150);
				}

				opponentIcon = new HealthIcon(oIconName, false);
				if (cardIcons.opponentOffset != null)
				{
					opponentIcon.x = cardIcons.opponentOffset[0];
					opponentIcon.y = cardIcons.opponentOffset[1];
				}
				else
				{
					opponentIcon.x = 260;
					opponentIcon.y = 130;
				}

				if (cardIcons.opponentScale != null)
					opponentIcon.scale.set(cardIcons.opponentScale[0], cardIcons.opponentScale[1]);

				playerIcon = new HealthIcon(pIconName, true);
				if (cardIcons.playerOffset != null)
				{
					playerIcon.x = cardIcons.playerOffset[0];
					playerIcon.y = cardIcons.playerOffset[1];
				}
				else
				{
					playerIcon.x = 850;
		   			playerIcon.y = 460;
				}

				if (cardIcons.playerScale != null)
					playerIcon.scale.set(cardIcons.playerScale[0], cardIcons.playerScale[1]);

				if (!FileSystem.exists('./assets/images/cardSkins/${artFile}.png'))
				{
				  	cardSprite.makeGraphic(600, 350, 0xFF000000);
				}
				else
				{
					if (cardAnimation.isAnimated)
					{
						animName = (cardAnimation.animName != null ? cardData.animName : "idle");
						animFPS = (cardAnimation.animFramerate >= 0 ? cardData.animFramerate : 24);

						cardSprite.frames = Paths.getSparrowAtlas('cardSkins/${artFile}');
						cardSprite.animation.addByPrefix('idle', animName, animFPS, cardAnimation.isLooped);
						cardSprite.animation.play('idle');
					}
					else
					{
				  		cardSprite.loadGraphic(Paths.image('cardSkins/${artFile}'));
					}
				}

				cardSprite.scale.set(cardScaleX, cardScaleY);

				if (!Init.trueSettings.get('Disable Screen Shaders'))
				{
					if (cardShaderName != null) cardSprite.shader = cardShader;
					if (pShaderName != null) playerIcon.shader = playerShader;
					if (oShaderName != null) opponentIcon.shader = opponentShader;
				}

				cardSprite.blend = (cardBlend != null ? ForeverTools.returnBlendMode(cardBlend) : NORMAL);
				playerIcon.blend = (playerBlend != null ? ForeverTools.returnBlendMode(playerBlend) : NORMAL);
				opponentIcon.blend = (opponentBlend != null ? ForeverTools.returnBlendMode(opponentBlend) : NORMAL);

				if (cardAdvanced.cardOffsets != null)
				{
					cardSprite.x = cardAdvanced.cardOffsets[0];
					cardSprite.y = cardAdvanced.cardOffsets[1];
				}
				else
				{
					cardSprite.x = 300;
					cardSprite.y = 150;
				}

				if (cardAdvanced.isScreenCenter) cardSprite.screenCenter();

				cardTxt = new FlxText(fontOffsetX, fontOffsetY, 0, '- ${songTitle} -\nBy: ${composer}');
				cardTxt.setFormat(Paths.font(fontStuff), fontSize, fontColor, (alignString != null ? ForeverTools.setTextAlign(alignString) : CENTER));
				cardTxt.scale.set(fontScaleX, fontScaleY);
		   }
		   else
		   {
				opponentIcon = new HealthIcon(oIconName, false);
				opponentIcon.x = 260;
				opponentIcon.y = 130;

				playerIcon = new HealthIcon(pIconName, true);
				playerIcon.x = 850;
		   		playerIcon.y = 460;

				if (!FileSystem.exists('./assets/images/cardSkins/${fileName}.png'))
					cardSprite.makeGraphic(600, 350, 0xFF000000);
			  	else
					cardSprite.loadGraphic(Paths.image('cardSkins/${fileName}'));

				  cardSprite.screenCenter();

				 cardTxt = new FlxText(cardSprite.x, cardSprite.y, 0, '- ${songTitle} -\nBy: ${composer}');
			 	 cardTxt.setFormat(Paths.font(fontStuff), 42, FlxColor.WHITE, CENTER);
				 cardTxt.screenCenter();
		   }

		   cardSprite.alpha = 0.001;

		   opponentIcon.animation.curAnim.curFrame = 2;
		   opponentIcon.alpha = 0.001;

		   playerIcon.animation.curAnim.curFrame = 2;
		   playerIcon.alpha = 0.001;

		   cardTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		   cardTxt.alpha = 0.001;

		   add(cardSprite);
		   add(cardTxt);
		   add(opponentIcon);
		   add(playerIcon);
	 }
  
	  // This is a function in case you want the card to show up later in the song instead of instantly
	 public function playCardAnim(delaySet:Float = 0)
	 {	
		if (FileSystem.exists('./assets/data/cardData/${fileName}.json'))
		{
			var rawJson = File.getContent(Paths.getPath('data/cardData/${fileName}.json', TEXT));
			cardAdvanced = cast Json.parse(rawJson).extraSettings;
			cardIcons = cast Json.parse(rawJson).iconSettings;
			cardFont = cast Json.parse(rawJson).fontSettings;
			cardTween = cast Json.parse(rawJson).tweenSettings;

			var alphaValue = (cardAdvanced.cardAlpha != null ? cardAdvanced.cardAlpha[0] : 1);
			var playerValue = (cardIcons.playerAlpha != null ? cardIcons.playerAlpha[0] : 1);
			var opponentValue = (cardIcons.opponentAlpha != null ? cardIcons.opponentAlpha[0] : 1);
			var fontValue = (cardFont.fontAlpha != null ? cardFont.fontAlpha[0] : 1);

			tweenInVal = cardTween.tweenIn;
			tweenOutVal = cardTween.tweenOut;

			cardIntroPosX = (cardTween.cardMoveIntro != null ? cardTween.cardMoveIntro[0] : 0);
			cardIntroPosY = (cardTween.cardMoveIntro != null ? cardTween.cardMoveIntro[1] : 0);
			cardOutroPosX = (cardTween.cardMoveOutro != null ? cardTween.cardMoveOutro[0] : 0);
			cardOutroPosY = (cardTween.cardMoveOutro != null ? cardTween.cardMoveOutro[1] : 0);
			playerIntroPosX = (cardTween.playerMoveIntro != null ? cardTween.playerMoveIntro[0] : 0);
			playerIntroPosY = (cardTween.playerMoveIntro != null ? cardTween.playerMoveIntro[1] : 0);
			playerOutroPosX = (cardTween.playerMoveOutro != null ? cardTween.playerMoveOutro[0] : 0);
			playerOutroPosY = (cardTween.playerMoveOutro != null ? cardTween.playerMoveOutro[1] : 0);
			oppIntroPosX = (cardTween.oppMoveIntro != null ? cardTween.oppMoveIntro[0] : 0);
			oppIntroPosY = (cardTween.oppMoveIntro != null ? cardTween.oppMoveIntro[1] : 0);
			oppOutroPosX = (cardTween.oppMoveOutro != null ? cardTween.oppMoveOutro[0] : 0);
			oppOutroPosY = (cardTween.oppMoveOutro != null ? cardTween.oppMoveOutro[1] : 0);
			fontIntroPosX = (cardTween.fontMoveIntro != null ? cardTween.fontMoveIntro[0] : 0);
			fontIntroPosY = (cardTween.fontMoveIntro != null ? cardTween.fontMoveIntro[1] : 0);
			fontOutroPosX = (cardTween.fontMoveOutro != null ? cardTween.fontMoveOutro[0] : 0);
			fontOutroPosY = (cardTween.fontMoveOutro != null ? cardTween.fontMoveOutro[1] : 0);

			// Fade Stuff
			FlxTween.tween(cardSprite, 
				{
					alpha: alphaValue,
					x: cardIntroPosX,
					y: cardIntroPosY
				}, 
				1.5, {ease: (tweenInVal != null ? ForeverTools.returnTweenEase(tweenInVal) : FlxEase.sineInOut), startDelay: delaySet,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(cardSprite, 
								{
									alpha: 0,
									x: cardOutroPosX,
									y: cardOutroPosY
								}, 
								1.5, {ease: (tweenOutVal != null ? ForeverTools.returnTweenEase(tweenOutVal) : FlxEase.sineInOut), startDelay: 3.5});
						}
				});
			FlxTween.tween(opponentIcon, 
				{
					alpha: opponentValue,
					x: oppIntroPosX,
					y: oppIntroPosY
				}, 
				2.2, {ease: (tweenInVal != null ? ForeverTools.returnTweenEase(tweenInVal) : FlxEase.sineInOut), startDelay: delaySet,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(opponentIcon, 
								{
									alpha: 0,
									x: oppOutroPosX,
									y: oppOutroPosY
								}, 
								2.2, {ease: (tweenOutVal != null ? ForeverTools.returnTweenEase(tweenOutVal) : FlxEase.sineInOut), startDelay: 3.5});
						}
				});
			FlxTween.tween(playerIcon, 
				{
					alpha: playerValue,
					x: playerIntroPosX,
					y: playerIntroPosY
				}, 
				 2.2, {ease: (tweenInVal != null ? ForeverTools.returnTweenEase(tweenInVal) : FlxEase.sineInOut), startDelay: delaySet,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(playerIcon, 
								{
									alpha: 0,
									x: playerOutroPosX,
									y: playerOutroPosY
								}, 
								2.2, {ease: (tweenOutVal != null ? ForeverTools.returnTweenEase(tweenOutVal) : FlxEase.sineInOut), startDelay: 3.5});
						}
				});
			FlxTween.tween(cardTxt, 
				{
					alpha: fontValue,
					x: fontIntroPosX,
					y: fontIntroPosY
				}, 
				2, {ease: (tweenInVal != null ? ForeverTools.returnTweenEase(tweenInVal) : FlxEase.sineInOut), startDelay: delaySet,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(cardTxt, 
								{
									alpha: 0,
									x: fontOutroPosX,
									y: fontOutroPosY
								}, 
								2, {ease: (tweenOutVal != null ? ForeverTools.returnTweenEase(tweenOutVal) : FlxEase.sineInOut), startDelay: 3.5});
						}
				});
		}
		else
		{
			FlxTween.tween(cardSprite, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut, startDelay: delaySet,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(cardSprite, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3.5});
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
			FlxTween.tween(cardTxt, {alpha: 1}, 2, {ease: FlxEase.sineInOut, startDelay: delaySet,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(cardTxt, {alpha: 0}, 2, {ease: FlxEase.sineInOut, startDelay: 3.5});
						}
				});
		}
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