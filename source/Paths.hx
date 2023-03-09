package;

/*
	Aw hell yeah! something I can actually work on!
 */
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import objects.CharacterData;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;

class Paths
{
	// Here we set up the paths class. This will be used to
	// Return the paths of assets and call on those assets as well.
	inline public static final SOUND_EXT = "ogg";

	// level we're loading
	static var currentLevel:String;

	public static var scriptExts:Array<String> = ['hx', 'hxs', 'hscript', 'hxc'];

	// set the current level top the condition of this function if called
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	// stealing my own code from psych engine
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> = [
		getSound('music/freakyMenu'),
		getSound('music/foreverMenu'),
		getSound('music/breakfast'),
	];

	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		var counter:Int = 0;
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				var obj = currentTrackedAssets.get(key);
				if (obj != null)
				{
					var isTexture:Bool = currentTrackedTextures.exists(key);
					if (isTexture)
					{
						var texture = currentTrackedTextures.get(key);
						texture.dispose();
						texture = null;
						currentTrackedTextures.remove(key);
					}
					@:privateAccess
					if (openfl.Assets.cache.hasBitmapData(key))
					{
						openfl.Assets.cache.removeBitmapData(key);
						FlxG.bitmap._cache.remove(key);
					}
					obj.destroy();
					currentTrackedAssets.remove(key);
					counter++;
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];

	public static function clearStoredMemory(?cleanUnused:Bool = false)
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
	}

	public static function returnGraphic(key:String, ?folder:String, ?library:String, ?gpuRender:Bool = false)
	{
		var path = getPath(folder.length > 1 ? '$folder/$key.png' : '$key.png', IMAGE, library);
		if (FileSystem.exists(path))
		{
			if (!currentTrackedAssets.exists(key))
			{
				var bitmap = BitmapData.fromFile(path);
				var newGraphic:FlxGraphic;
				if (gpuRender)
				{
					var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
					texture.uploadFromBitmapData(bitmap);
					currentTrackedTextures.set(key, texture);
					bitmap.dispose();
					bitmap.disposeImage();
					bitmap = null;
					newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
				}
				else
				{
					newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
				}
				newGraphic.persist = true;
				currentTrackedAssets.set(key, newGraphic);
			}
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		trace('graphic is returning null at $key');
		return null;
	}

	public static function getTextFile(key:String, type:AssetType = TEXT, ?library:Null<String>):String
	{
		if (FileSystem.exists(getPath(key, type, library)))
			return File.getContent(getPath(key, type, library));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			levelPath = getLibraryPathForce(key, '');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		return Assets.getText(getPath(key, type, library));
	}

	public static function returnSound(path:String, key:String, ?library:String)
	{
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		var extensionPath = getSound('$path/$key');

		if (FileSystem.exists(extensionPath))
			gottenPath = extensionPath;

		// gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
			currentTrackedSounds.set(gottenPath, Sound.fromFile(gottenPath));
		localTrackedAssets.push(key);
		return currentTrackedSounds.get(gottenPath);
	}

	// kind of an afterthought, I don't think i'm gonna clean this up and make it an actual feature until I rework this class or something;
	public static function getSound(path:String, ?library:String)
	{
		final returnExtension:String = SOUND_EXT; // defaults to "ogg";
		final SOUND_EXTS:Array<String> = [".mp3", ".ogg", ".wav", ".flac"];

		for (i in 0...SOUND_EXTS.length)
		{
			var caughtExtension:String = null;
			if (SOUND_EXTS != null)
			{
				if (FileSystem.exists(getPath(path + SOUND_EXTS[i], SOUND, library)))
					caughtExtension = SOUND_EXTS[i];
			}
			// return it;
			if (caughtExtension != null)
			{
				// trace('returning $caughtExtension for $path');
				return path + caughtExtension;
			}
		}
		// trace('returning $returnExtension for $path');
		return path + returnExtension;
	}

	//
	inline public static function getPath(file:String, ?type:AssetType, ?library:Null<String>)
	{
		/*
				Okay so, from what I understand, this loads in the current path based on the level
				we're in (if a library is not specified), say like week 1 or something, 
				then checks if the assets you're looking for are there.
				if not, it checks the shared assets folder.
			// */

		// well I'm rewriting it so that the library is the path and it looks for the file type
		// later lmao I don't really wanna rn

		if (library != null)
			return getLibraryPath(file, library);

		/*
			if (currentLevel != null)
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;

				levelPath = getLibraryPathForce(file, "shared");
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
		}*/

		var levelPath = getLibraryPathForce(file, "mods");
		if (OpenFlAssets.exists(levelPath, type))
			return levelPath;

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		var returnPath:String = 'assets/$file';
		if (!FileSystem.exists(returnPath))
			returnPath = CoolUtil.swapSpaceDash(returnPath);
		return returnPath;
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('songs/$key.json', TEXT, library);
	}

	inline static public function songJson(song:String, secondSong:String, ?library:String)
		return getPath('songs/${song.toLowerCase()}/${secondSong.toLowerCase()}.json', TEXT, library);

	static public function sound(key:String, folder:String = 'sounds', ?library:String):Dynamic
	{
		var sound:Sound = returnSound(folder, key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, folder:String = 'sounds', min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), folder, library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	/*
	* NEW SONG FILE FORMAT
	*
	* "diff" allows you to add remixes of a song under the same folder, for example, an erect remix.
	*
	* Opponent & Player Voices are separate to add some quality of life to the music, especially during duels
	* when you're missing like fucking crazy for some reason.
	*
	* @author DEMOLITIONDON96
	*/
	inline static public function voicesPlayer(song:String, diff:String = 'normal'):Any
	{
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Voices-${diff}';
		var voices = returnSound('songs', songKey);
		return voices;
	}
	
	inline static public function voicesOpp(song:String, diff:String = 'normal'):Any
	{
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/VoicesOpp-${diff}';
		var voices = returnSound('songs', songKey);
		return voices;
	}
	
	inline static public function instNew(song:String, diff:String = 'normal'):Any
	{
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Inst-${diff}';
		var inst = returnSound('songs', songKey);
		return inst;
	}
	
	/*
	* LEGACY SONG FORMATS
	*
	* The original engine's song format for those that would rather use this.
	*/
	inline static public function voices(song:String):Any
	{
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${CoolUtil.swapSpaceDash(song.toLowerCase())}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, folder:String = 'images', ?library:String, ?gpuRender:Bool = false)
	{
		var returnAsset:FlxGraphic = returnGraphic(key, folder, library, gpuRender);
		return returnAsset;
	}

	public static function font(key:String, ?library:String)
	{
		var font:String = getPath('fonts/$key.ttf', TEXT, library);
		var extensions:Array<String> = ['.ttf', '.otf'];

		for (extension in extensions)
		{
			var newPath:String = getPath('fonts/$key$extension', TEXT, library);
			if (FileSystem.exists(newPath))
			{
				/*
					clear any dots, means that something like "vcr.tff" would become "vcr";
					we are doing this because we already added an extension earlier;
					EDIT: does this even work?;
				 */
				if (key.contains('.'))
					key.substring(0, key.indexOf('.'));
				return newPath;
			}
		}

		return font; // fallback in case the font or path doesn't exist;
	}

	inline static public function getSparrowAtlas(key:String, folder:String = 'images', ?library:String)
	{
		var graphic:FlxGraphic = returnGraphic(key, folder, library);
		return (FlxAtlasFrames.fromSparrow(graphic, File.getContent(file('$folder/$key.xml', library))));
	}

	inline static public function getPackerAtlas(key:String, folder:String = 'images', ?library:String)
	{
		return (FlxAtlasFrames.fromSpriteSheetPacker(image(key, folder, library), file('$folder/$key.txt', library)));
	}

	inline static public function module(key:String, folder:String = 'scripts', ?library:String)
	{
		var extension = '.hx';

		for (j in scriptExts)
		{
			if (FileSystem.exists(getPath('$folder/$key.$j', TEXT, library)))
				extension = '.$j';
			else
				extension = '.hx';
		}
		return getPath('$folder/$key' + extension);
	}

	inline static public function characterModule(folder:String, character:String, ?type:CharacterOrigin, ?library:String)
	{
		var extension:String = '';

		if (folder == null)
			folder = 'placeholder';

		if (character == null)
			character = 'placeholder';

		switch (type)
		{
			case PSYCH_ENGINE:
				extension = '.json';
			case FOREVER_FEATHER:
				// this is diabolic;
				for (j in scriptExts)
				{
					if (FileSystem.exists(getPath('data/characters/$folder/$character.$j', TEXT, library)))
						extension = '.$j';
					else
						extension = '.hx';
				}
				extension = '.hx';
			case FUNKIN_COCOA:
				extension = '.yaml';
			default:
				extension = '';
		}
		return getPath('data/characters/$folder/$character' + extension, TEXT, library);
	}
}
