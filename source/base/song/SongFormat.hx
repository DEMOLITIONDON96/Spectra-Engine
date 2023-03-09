package base.song;

// stores typedefs for song info and such;

/*
	[LEGACY] Song Format, from Friday Night Funkin' v0.2.7.1/0.2.8;
 */
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var instType:String;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var noteSkin:String;
	var splashSkin:String;
	var assetModifier:String;
	var validScore:Bool;

	@:optional dynamic function copy():SwagSong;
}

/*
	[LEGACY] Section Format, from Friday Night Funkin' v0.2.7.1/0.2.8;
 */
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

/*
	Timed Event Format for Forever Engine Feather;
 */
typedef TimedEvent =
{
	var name:String;
	var step:Float;
	var values:Array<String>;
	// var color:Array<Int>;
	// var stack:Array<TimedEvent>;
}
