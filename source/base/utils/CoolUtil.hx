package base.utils;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.io.Bytes;
import haxe.io.Path;
import lime.app.Application;
import lime.utils.Assets;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import states.PlayState;
import sys.io.File;

using StringTools;

#if sys
import sys.FileSystem;
#end

class CoolUtil
{
	public static var difficulties:Array<String> = []; // Custom Difficulties;
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"]; // Default Difficulties;
	public static var difficultyString:String = 'NORMAL'; // shows on HUD / Pause;

	public static var defaultDifficulty:String = 'NORMAL';

	private var SONG = PlayState.SONG;

	public function new()
	{
		staticAccess = this;
	}

	public static var staticAccess:CoolUtil;

	inline public static function difficultyFromNumber(number:Int):String
		return difficulties[number];

	inline public static function boundTo(value:Float, minValue:Float, maxValue:Float):Float
		return Math.max(minValue, Math.min(maxValue, value));

	inline public static function dashToSpace(string:String):String
		return string.replace("-", " ");

	inline public static function spaceToDash(string:String):String
		return string.replace(" ", "-");

	inline public static function swapSpaceDash(string:String):String
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);

	inline public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		return [for (i in 0...daList.length) daList[i].trim()];
	}

	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		var libraryArray:Array<String> = [];

		return try
		{
			for (folder in FileSystem.readDirectory('$subDir/$library'))
				if (!folder.contains('.'))
					libraryArray.push(folder);
			libraryArray;
		}
		catch (e)
		{
			trace('$subDir/$library is returning null');
			[];
		}
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
		return [for (i in min...max) i];

	/**
	 * Returns an array with the files of the specified directory.
	 * Example usage:
	 * var fileArray:Array<String> = CoolUtil.absoluteDirectory('scripts');
	 * trace(fileArray); -> ['mods/scripts/modchart.hx', 'assets/scripts/script.hx']
	**/
	inline public static function absoluteDirectory(file:String):Array<String>
	{
		if (!file.endsWith('/'))
			file = '$file/';

		var path:String = Paths.getPath(file);

		var absolutePath:String = FileSystem.absolutePath(path);
		var directory:Array<String> = FileSystem.readDirectory(absolutePath);

		if (directory != null)
		{
			var dirCopy:Array<String> = directory.copy();

			for (i in dirCopy)
			{
				var index:Int = dirCopy.indexOf(i);
				var file:String = '$path$i';
				dirCopy.remove(i);
				dirCopy.insert(index, file);
			}

			directory = dirCopy;
		}

		return if (directory != null) directory else [];
	}

	inline public static function normalizePath(path:String):String
	{
		path = Path.normalize(Sys.getCwd() + path);
		#if windows
		path = path.replace("/", "\\");
		#end
		return path;
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "Dunkin-Funkin" to something else
		so the engine saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'Dunkin-Funkin'):String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}
}
