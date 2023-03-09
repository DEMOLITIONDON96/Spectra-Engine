package objects;

enum abstract CharacterOrigin(String) to String
{
	var FOREVER_FEATHER = "forever_feather";
	var PSYCH_ENGINE = "psych_engine";
	var FUNKIN_COCOA = "funkin_cocoa";
}

typedef CharacterData =
{
	var flipX:Bool;
	var flipY:Bool;
	var offsets:Array<Float>;
	var camOffsets:Array<Float>;
	var quickDancer:Bool;
	var singDuration:Float;
	var headBopSpeed:Int;
	var healthColor:Array<Float>;
	var antialiasing:Bool;
	var adjustPos:Bool;
	var missColor:Array<Int>; // for fake misses;
	var icon:String;
}

/*
	FOR PSYCH ENGINE CHARACTER COMPATIBILITY
	author @Shadow_Mario_
 */
typedef PsychEngineChar =
{
	var animations:Array<PsychAnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Float>;
}

typedef PsychAnimArray =
{
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}
