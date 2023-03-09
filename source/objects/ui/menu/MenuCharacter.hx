package objects.ui.menu;

import base.utils.FNFUtils.FNFSprite;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef StoryCharacter =
{
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idleAnim:Array<Dynamic>;
	var heyAnim:Array<Dynamic>;
	var flipX:Bool;
}

class MenuCharacter extends FNFSprite
{
	public var character:String = '';
	public var storyChar:StoryCharacter;

	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, newCharacter:String = 'bf')
	{
		super(x);
		y += 70;

		baseX = x;
		baseY = y;

		createCharacter(newCharacter);
	}

	public function createCharacter(newCharacter:String = 'bf', canChange:Bool = false)
	{
		this.character = newCharacter;

		var rawJson = null;
		var path:String = Paths.getPath('images/menus/base/storymenu/characters/' + newCharacter + '.json');

		if (!FileSystem.exists(path))
			path = Paths.getPath('images/menus/base/storymenu/characters/none.json');
		rawJson = File.getContent(path);

		storyChar = cast Json.parse(rawJson);

		var tex = Paths.getSparrowAtlas('menus/base/storymenu/characters/' + storyChar.image);
		frames = tex;

		if (newCharacter != null || newCharacter != '')
		{
			if (!visible)
				visible = true;

			animation.addByPrefix('idle', storyChar.idleAnim[0], storyChar.idleAnim[1], storyChar.idleAnim[2]);

			if (storyChar.heyAnim != null)
				animation.addByPrefix('hey', storyChar.heyAnim[0], storyChar.heyAnim[1], storyChar.heyAnim[2]);

			animation.play('idle');

			if (canChange)
			{
				setGraphicSize(Std.int(width * storyChar.scale));
				setPosition(baseX + storyChar.position[0], baseY + storyChar.position[1]);
				updateHitbox();
			}

			flipX = storyChar.flipX;
		}
		else
			visible = false;

		character = newCharacter;
	}
}
