package base.utils;

import flixel.FlxG;
import states.PlayState;

typedef Judgement =
{
	var name:String; // default: sick
	var score:Int; // default: 350
	var health:Float; // default: 100
	var accuracy:Float; // default : 100
	var timing:Float; // default: 45
	var timingCap:Float; // default: 45
	var comboStatus:String; // default: none
}

/*
	Class that saves Score data and calculates Accuracy for Songs;
	Unified Highscore.hx and Timings.hx for better managment later;
 */
class ScoreUtils
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	public static var weekScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var weekScores:Map<String, Int> = new Map<String, Int>();
	#end

	//
	public static var score:Int = 0;
	public static var combo:Int = 0;
	public static var misses:Int = 0;

	public static var accuracy(get, default):Float;
	public static var notesAccuracy:Float;
	public static var notesHit:Int = 0;
	public static var minesHit:Int = 0;

	inline static function get_accuracy():Float
		return notesAccuracy / notesHit;

	public static final judges:Array<Judgement> = [
		{
			name: "sick",
			score: 350,
			health: 100,
			accuracy: 100,
			timing: 45,
			timingCap: 45,
			comboStatus: "MFC"
		},
		{
			name: "good",
			score: 150,
			health: 50,
			accuracy: 85,
			timing: 90,
			timingCap: 90,
			comboStatus: "GFC"
		},
		{
			name: "bad",
			score: 50,
			health: 20,
			accuracy: 50,
			timing: 125,
			timingCap: 125,
			comboStatus: 'FC'
		},
		{
			name: "shit",
			score: -50,
			health: -50,
			accuracy: 0,
			timing: 150,
			timingCap: 150,
			comboStatus: null
		},
		{
			name: "miss",
			score: -100,
			health: -100,
			accuracy: 0,
			timing: 175,
			timingCap: 175,
			comboStatus: null
		}
	];

	public static var msThreshold:Float = 0;

	// set the score judgements for later use
	public static final scoreRating:Map<String, Int> = [
		"S+" => 100,
		"S" => 95,
		"A" => 90,
		"B" => 85,
		"C" => 80,
		"D" => 75,
		"E" => 70,
		"F" => 65,
	];

	// left to right, preset name, timings (sick, good, bad, shit);
	public static final timingPresets:Map<String, Array<Float>> = [
		"judge four" => [45, 90, 135, 180],
		"itg" => [43, 102, 135, 180],
		"funkin" => [33.33, 91.67, 133.33, 166.67],
		"forever" => [45, 90, 125, 150]
	];

	public static var curRating:String = null;
	public static var curCombo:String = null;

	public static var gottenJudgements:Map<String, Int> = [];
	public static var smallestRating:Int;

	public static var perfectCombo:Bool = false;

	/*
		----------------------

		SCORE SAVING / LOADING

		----------------------
	 */
	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		FlxG.save.bind("HighScores", "Feather");
		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
				setScore(daSong, score);
		}
		else
			setScore(daSong, score);
	}

	public static function saveWeekScore(week:Int = 1, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong('week' + week, diff);

		FlxG.save.bind("WeekScores", "Feather");
		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else
			setWeekScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	inline static function setScore(song:String, score:Int):Void
	{
		FlxG.save.bind("HighScores", "Feather");
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}

	inline static function setWeekScore(song:String, score:Int):Void
	{
		FlxG.save.bind("WeekScores", "Feather");
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(song, score);
		FlxG.save.data.setWeekScore = weekScores;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(diff).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		daSong += difficulty;

		return daSong;
	}

	inline public static function getScore(song:String, diff:Int):Int
	{
		FlxG.save.bind("HighScores", "Feather");
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff));
	}

	inline public static function getWeekScore(week:Int, diff:Int):Int
	{
		FlxG.save.bind("WeekScores", "Feather");
		if (!weekScores.exists(formatSong('week' + week, diff)))
			setWeekScore(formatSong('week' + week, diff), 0);

		return weekScores.get(formatSong('week' + week, diff));
	}

	inline public static function loadScores():Void
	{
		FlxG.save.bind("HighScores", "Feather");
		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		FlxG.save.bind("WeekScores", "Feather");
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;
	}

	/*
		--------------------------------

		ACCURACY CALCULATIONS AND RANKING

		--------------------------------
	 */
	public static function resetAccuracy()
	{
		// reset score;
		score = 0;
		combo = 0;
		misses = 0;
		accuracy = 0;
		notesHit = 0;
		notesAccuracy = 0.001;

		// reset ms threshold
		var biggestThreshold:Float = 0;
		for (i in 0...judges.length)
			if (judges[i].timing > biggestThreshold)
				biggestThreshold = judges[i].timing;
		msThreshold = biggestThreshold;

		// set the gotten judgement amounts
		for (judgement in 0...judges.length)
			gottenJudgements.set(judges[judgement].name, 0);

		smallestRating = 0;
		perfectCombo = true;
		curRating = "N/A";
		curCombo = null;

		var preset = Init.trueSettings.get("Timing Preset");

		if (preset != null)
		{
			for (i in 0...judges.length)
				setJudgeTiming(i, timingPresets.get(preset)[i]);
		}
	}

	public static function updateInfo(judge:Int, ?isSustain:Bool = false, segCount:Int = 1)
	{
		// update accuracy;
		if (!isSustain)
		{
			notesHit++;
			notesAccuracy += (Math.max(0, judge));
		}
		else
			notesAccuracy += (Math.max(0, judge) / segCount);

		// update ranking;
		if (!isSustain)
			updateRanking();
	}

	inline public static function returnAccuracy()
	{
		var accuracyFinal:String = 'N/A';
		accuracyFinal = '${Math.floor(accuracy * 100) / 100}%';
		return accuracyFinal;
	}

	inline public static function returnRankingStatus():String
	{
		var rankingFinal:String = '[$curRating]';

		if (curCombo != null && curCombo != '')
			rankingFinal = '[$curRating - $curCombo]';

		return ' $rankingFinal';
	}

	public static function updateRanking()
	{
		var biggest:Int = 0;
		for (score in scoreRating.keys())
		{
			if ((scoreRating.get(score) <= accuracy) && (scoreRating.get(score) >= biggest))
			{
				biggest = scoreRating.get(score);
				curRating = score;
			}
		}

		curCombo = "";
		// Update FC Display;
		if (judges[smallestRating].comboStatus != null)
			curCombo = judges[smallestRating].comboStatus;

		if (misses > 0 && misses < 10)
			curCombo = 'SDCB';

		// this updates the most so uh
		PlayState.uiHUD.updateScoreText();
		PlayState.uiHUD.colorHighlight(curRating);
	}

	public static function setJudgeTiming(rating:Int, newTiming:Float)
	{
		//
		if (newTiming != 0 /* && newTiming <= judges[rating].timingCap*/)
			judges[rating].timing = newTiming;
	}

	public static function increaseCombo()
	{
		if (combo < 0)
			combo = 0;
		combo += 1;
	}

	public static function decreaseCombo()
	{
		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		score -= 10;
		misses++;

		perfectCombo = false;
		updateInfo(0);
	}
}
