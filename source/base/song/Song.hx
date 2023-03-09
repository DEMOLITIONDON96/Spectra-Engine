package base.song;

import base.song.SongFormat.SwagSection;
import base.song.SongFormat.SwagSong;
import haxe.Json;
import sys.io.File;

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var instType:String = "Legacy";
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson:String = null;
		var rawEvent:String = null;

		rawJson = getData(rawJson, folder, jsonInput);
		rawEvent = getData(rawJson, folder, 'events');

		dataCleanup(rawJson);
		dataCleanup(rawEvent);

		return parseSong(rawJson, rawEvent);
	}

	public static function parseSong(rawJson:String, rawEvent:String):SwagSong
	{
		if (rawJson == null)
			return cast {
				song: "ERROR, CHECK YOUR CHART JSON!",
				player1: "placeholder",
				player2: "placeholder",
				gfVersion: "placeholder",
				stage: "",
				speed: 1,
				bpm: 100,
				notes: [],
				events: [],
				noteSkin: "",
				splashSkin: "noteSplashes",
				needsVoices: false,
				instType: "Legacy",
				validScore: false,
				assetModifier: "base"
			};

		var oldSong:SwagSong = cast Json.parse(rawJson).song;
		oldSong.validScore = true;
		oldSong.copy = function()
		{
			return cast {
				song: oldSong.song,
				player1: oldSong.player1,
				player2: oldSong.player2,
				gfVersion: oldSong.gfVersion,
				stage: oldSong.stage,
				speed: oldSong.speed,
				bpm: oldSong.bpm,
				notes: oldSong.notes,
				events: [],
				splashSkin: oldSong.splashSkin,
				noteSkin: oldSong.noteSkin,
				needsVoices: oldSong.needsVoices,
				instType: oldSong.instType,
				validScore: true,
				assetModifier: oldSong.assetModifier,
			};
		};

		oldSong.events = parseEvent(rawEvent).copy();
		if (oldSong.events == null)
			oldSong.events = [];

		return oldSong;
	}

	static function parseEvent(rawEvent:String)
	{
		return try
		{
			var array:Array<Dynamic> = cast haxe.Json.parse(rawEvent).events;
			array.copy();
		}
		catch (e)
		{
			[];
		}
	}

	static function getData(data:String, path:String, secondPath:String)
	{
		return try
		{
			data = File.getContent(Paths.songJson(path.toLowerCase(), secondPath.toLowerCase())).trim();
		}
		catch (e)
		{
			return data = null;
		}
	}

	static function dataCleanup(raw:String)
	{
		if (raw != null)
		{
			while (!raw.endsWith("}"))
				raw = raw.substr(0, raw.length - 1);
		}
	}
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var sectionBeats:Float = 4;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	public function new(lengthInSteps:Int = 16, sectionBeats:Float = 4)
	{
		this.lengthInSteps = lengthInSteps;
		this.sectionBeats = sectionBeats;
	}
}
