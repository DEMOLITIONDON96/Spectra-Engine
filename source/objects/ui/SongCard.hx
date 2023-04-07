package objects.ui;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import haxe.Json;
import states.PlayState;
import sys.FileSystem;
import sys.io.File;

using flixel.util.FlxSpriteUtil;

/* 
* The stupid default black box that pops up in front of your screen at the start
* until you give it the desired changes you want
* 
* @author DEMOLITIONDON96
*/

/*
* # Custom Song Card Modifiers
*
* This is the json file variables that can be used to create a custom card.
* Feel free to add more variables to your customizing needs, for there's more
* stuff to be added soon :)
*
* @param font - Your custom font file (found in "assets/fonts")
* @param customArt - Your custom card skin/image (found in "assets/images/cardSkins")
* @param playerIcon - Your custom icon you want to use ("assets/data/character/your-icon/name/icon.png")
* @param opponentIcon - Same as "playerIcon" but for opponent
* @param playerOffset - Sets the position of the BF/Player icon
* @param opponentOffset - same as "playerOffset" but for opponent
* @param cardAlpha - Determines the alpha value when it fades in
*
* Check "assets/data/cardData" for a more detailed explanation and how to use this!
*/
typedef SongCardData =
{
	var font:String;
	var customArt:String;
	var playerIcon:String;
	var opponentIcon:String;
	var playerOffset:Array<Float>;
	var opponentOffset:Array<Float>;
	var cardAlpha:Array<Float>;
}

class SongCard extends FlxSpriteGroup
{	
	// Pre-made Text
	public var composer:String = PlayState.SONG.composer;
	public var songTitle:String = PlayState.SONG.song;

	// Files to look for
	public var fontStuff:String = "vcr";
	public var artFile:String = "test";
	public var fileName:String = CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase());
	public var pIconName:String = PlayState.boyfriend.characterData.icon;
	public var oIconName:String = PlayState.opponent.characterData.icon;

	// Card Data Stuff
	public var cardData:SongCardData;

	// Base Card Setup
	public var cardTxt:FlxText;
	public var cardSprite:FlxSprite;

	// Health Icons
	public var opponentIcon:HealthIcon;
	public var playerIcon:HealthIcon;

	// Only use this if you plan on hardcoding your fonts
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
		cardTxt = new FlxText(cardSprite.x, cardSprite.y, 0, '- ${songTitle} -\nBy: ${composer}');

		if (FileSystem.exists('./assets/data/cardData/${fileName}.json')) 
		{
			var rawJson = File.getContent(Paths.getPath('data/cardData/${fileName}.json', TEXT));
			cardData = cast Json.parse(rawJson).customCardData;

			artFile = cardData.customArt;
			pIconName = (cardData.playerIcon != null ? cardData.playerIcon : PlayState.boyfriend.characterData.icon);
			oIconName = (cardData.opponentIcon != null ? cardData.opponentIcon : PlayState.opponent.characterData.icon);
			fontStuff = (cardData.font != null ? cardData.font : "vcr");

			opponentIcon = new HealthIcon(oIconName, false);
			if (cardData.opponentOffset != null)
			{
				opponentIcon.x = cardData.opponentOffset[0];
				opponentIcon.y = cardData.opponentOffset[1];
			}
			else
			{
				opponentIcon.x = 260;
				opponentIcon.y = 130;
			}

			playerIcon = new HealthIcon(pIconName, true);
			if (cardData.playerOffset != null)
			{
				playerIcon.x = cardData.playerOffset[0];
				playerIcon.y = cardData.playerOffset[1];
			}
			else
			{
				playerIcon.x = 850;
				playerIcon.y = 460;
			}

			if (!FileSystem.exists('./assets/images/cardSkins/${artFile}.png'))
				cardSprite.makeGraphic(600, 350, 0xFF000000);
			else
				cardSprite.loadGraphic(Paths.image('cardSkins/${artFile}'));

			cardTxt.setFormat(Paths.font(fontStuff), 42, FlxColor.WHITE, CENTER);
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

			cardTxt.setFormat(Paths.font(fontStuff), 42, FlxColor.WHITE, CENTER);
		}

		cardSprite.alpha = 0.001;
		cardSprite.screenCenter();

		opponentIcon.animation.curAnim.curFrame = 2;
		opponentIcon.alpha = 0.001;

		playerIcon.animation.curAnim.curFrame = 2;
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
		if (FileSystem.exists('./assets/data/cardData/${fileName}.json'))
		{
			var rawJson = File.getContent(Paths.getPath('data/cardData/${fileName}.json', TEXT));
			cardData = cast Json.parse(rawJson).customCardData;

			var alphaValue = (cardData.cardAlpha != null ? cardData.cardAlpha[0] : 1);

			FlxTween.tween(cardSprite, {alpha: alphaValue}, 1.5, {ease: FlxEase.sineInOut, startDelay: delaySet,
				onComplete: function(twn:FlxTween)
				{
					FlxTween.tween(cardSprite, {alpha: 0}, 1.5, {ease: FlxEase.sineInOut, startDelay: 3.5});
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
		}

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
