package states.editors;

import base.dependency.Discord;
import base.dependency.FeatherDeps.Events;
import base.song.*;
import base.song.Conductor.BPMChangeEvent;
import base.song.SongFormat;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import objects.*;
import objects.Character;
import objects.ui.*;
import openfl.display.BlendMode;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import states.MusicBeatState;

/**
 * In case you dont like the forever engine chart editor, here's the base game one instead.
**/
class OriginalChartingState extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	var curNoteType:String = 'default';

	var events:Map<FlxSprite, Array<Dynamic>> = new Map();

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;

	public static var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedEvents:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var curRenderedTexts:FlxTypedGroup<AbsoluteText> = new FlxTypedGroup<AbsoluteText>();

	var gridBG:FlxSprite;

	var gridGroup:FlxTypedGroup<FlxObject>;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	/*
	 * WILL BE THE CURRENT / LAST PLACED EVENT
	**/
	var curSelectedEvent:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;
	
	var bf_vocals:FlxSound;
	var opp_vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var playTicksBf:FlxUICheckBox = null;
	var playTicksDad:FlxUICheckBox = null;

	public var blockPressInputText:Array<FlxUIInputText>;
	public var blockPressNumStepper:Array<FlxUINumericStepper>;
	public var blockPressDropDown:Array<FlxUIDropDownMenu>;

	override function create()
	{
		super.create();

		PlayState.gameplayMode = CHARTING;

		blockPressInputText = [];
		blockPressNumStepper = [];
		blockPressDropDown = [];

		curSection = Std.int(lastSection);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
			_song = Song.loadFromJson('test', 'test');

		generateBackground();

		gridGroup = new FlxTypedGroup<FlxObject>();
		add(gridGroup);

		generateGrid();

		generateHeads();

		FlxG.mouse.visible = true;
		FlxG.save.bind('chartSettings', "Feather");

		tempBpm = _song.bpm;

		addSection();
		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		#if DISCORD_RPC
		Discord.changePresence('CHART EDITOR', 'Song: ' + _song.song);
		#end

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song Data'},
			{name: "Section", label: 'Section Data'},
			{name: "Note", label: 'Note Data'},
			{name: "Events", label: 'Event Data'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 50;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedEvents);
		add(curRenderedTexts);
	}

	function addSongUI():Void
	{
		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";

		var saveButton:FlxButton = new FlxButton(10, 10, "Save", function()
		{
			pauseMusic();
			openSubState(new states.substates.editors.ExportSubstate(CHART, _song));
		});

		var saveEvent:FlxButton = new FlxButton(saveButton.x + 90, saveButton.y, "Save Events", function()
		{
			pauseMusic();

			if (_song.events.length > 0)
				openSubState(new states.substates.editors.ExportSubstate(CHART, _song, true));
			else
				logTrace('No Events Found.', 3);
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x, saveButton.y + 30, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(saveEvent.x, saveEvent.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var check_voices = new FlxUICheckBox(saveEvent.x + 100, saveEvent.y, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
		};
		
		var check_inst_type = new FlxUICheckBox(check_voices.x, check_voices.y + 25, null, null, "Inst Type: " + _song.instType, 100);
		check_inst_type.checked = (_song.instType == "Legacy" || _song.instType == null) ? false : true;
		check_inst_type.callback = function()
		{
			if (check_inst_type.checked)
			{
				check_inst_type.text = "Inst Type: " + _song.instType;
				_song.instType = "New";
			}
			else
			{
				check_inst_type.text = "Inst Type: " + _song.instType;
				_song.instType = "Legacy";
			}
		};

		var check_mute_inst = new FlxUICheckBox(10, 250, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			if (_song.instType == "Legacy" || _song.instType == null)
			{
				var vol:Float = 1;

				if (check_mute_inst.checked)
					vol = 0;

				songMusic.volume = vol;
			}
			
			if (_song.instType == "New")
			{
				var vol:Float = 1;
				
				if (check_mute_inst.checked)
					vol = 0;
					
				songMusicNew.volume = vol;
			}
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor) [LEGACY]", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if (vocals != null)
			{
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};
		
		var check_mute_vocals_bf = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y + 22, null, null, "Mute Player Vocals (in editor)", 100);
		check_mute_vocals_bf.checked = false;
		check_mute_vocals_bf.callback = function()
		{
			if (bf_vocals != null)
			{
				var vol:Float = 1;

				if (check_mute_vocals_bf.checked)
					vol = 0;

				bf_vocals.volume = vol;
			}
		};

		var check_mute_vocals_opp = new FlxUICheckBox(check_mute_vocals_bf.x, check_mute_inst.y + 45, null, null, "Mute Opponent Vocals (in editor)", 100);
		check_mute_vocals_opp.checked = false;
		check_mute_vocals_opp.callback = function()
		{
			if (opp_vocals != null)
			{
				var volOpp:Float = 1;

				if (check_mute_vocals_opp.checked)
					volOpp = 0;

				opp_vocals.volume = volOpp;

			}

		};

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressNumStepper.push(stepperSpeed);

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressNumStepper.push(stepperBPM);

		var assetModifiers:Array<String> = CoolUtil.returnAssetsLibrary('UI/default');
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/characterList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('data/stageList'));

		var player1DropDown = new FlxUIDropDownMenu(10, stepperSpeed.y + 45, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.player1 = characters[Std.parseInt(character)];
				updateHeads(true);
			});
		player1DropDown.dropDirection = Down;
		player1DropDown.selectedLabel = _song.player1;
		blockPressDropDown.push(player1DropDown);

		var gfVersionDropDown = new FlxUIDropDownMenu(player1DropDown.x, player1DropDown.y + 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.gfVersion = characters[Std.parseInt(character)];
				updateHeads();
			});
		gfVersionDropDown.dropDirection = Down;
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		blockPressDropDown.push(gfVersionDropDown);

		var player2DropDown = new FlxUIDropDownMenu(player1DropDown.x, gfVersionDropDown.y + 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true),
			function(character:String)
			{
				_song.player2 = characters[Std.parseInt(character)];
				updateHeads(true);
			});
		player2DropDown.dropDirection = Down;
		player2DropDown.selectedLabel = _song.player2;
		blockPressDropDown.push(player2DropDown);

		var stageDropDown = new FlxUIDropDownMenu(player1DropDown.x + 140, player1DropDown.y, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true),
			function(stage:String)
			{
				_song.stage = stages[Std.parseInt(stage)];
			});
		stageDropDown.dropDirection = Down;
		stageDropDown.selectedLabel = _song.stage;
		blockPressDropDown.push(stageDropDown);

		var assetModifierDropDown = new FlxUIDropDownMenu(stageDropDown.x, gfVersionDropDown.y, FlxUIDropDownMenu.makeStrIdLabelArray(assetModifiers, true),
			function(asset:String)
			{
				_song.assetModifier = assetModifiers[Std.parseInt(asset)];
			});
		assetModifierDropDown.dropDirection = Down;
		assetModifierDropDown.selectedLabel = _song.assetModifier;
		blockPressDropDown.push(assetModifierDropDown);

		playTicksBf = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 25, null, null, 'Play Hitsounds (Boyfriend - in editor)', 100);
		playTicksBf.checked = false;

		playTicksDad = new FlxUICheckBox(check_mute_inst.x, playTicksBf.y + 32, null, null, 'Play Hitsounds (Opponent - in editor)', 100);
		playTicksDad.checked = false;

		tab_group_song.add(check_voices);
		tab_group_song.add(check_inst_type);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vocals);
		tab_group_song.add(check_mute_vocals_bf);
		tab_group_song.add(check_mute_vocals_opp);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvent);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(playTicksBf);
		tab_group_song.add(playTicksDad);
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(new FlxText(gfVersionDropDown.x, gfVersionDropDown.y - 15, 0, 'Spectator:'));
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Player:'));
		tab_group_song.add(player1DropDown);
		tab_group_song.add(new FlxText(assetModifierDropDown.x, assetModifierDropDown.y - 15, 0, 'Asset Modifier:'));
		tab_group_song.add(assetModifierDropDown);
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var value3InputText:FlxUIInputText;
	var value3Text:FlxText;
	var eventDropDown:FlxUIDropDownMenu;
	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var descText:FlxText;

	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		Events.getScriptEvents();

		descText = new FlxText(20, 225, 0, '');

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);

		var leEvents:Array<String> = [];
		for (i in 0...Events.eventArray.length)
			leEvents.push(Events.eventArray[i]);

		eventDropDown = new FlxUIDropDownMenu(20, 50, FlxUIDropDownMenu.makeStrIdLabelArray(leEvents.copy(), true), function(pressed:String)
		{
			var selectedEvent:Int = Std.parseInt(pressed);
			if (curSelectedEvent != null)
			{
				curSelectedEvent[0] = Events.eventArray[selectedEvent];
				updateGrid();
			}

			descText.text = Events.returnEventDescription(Events.eventArray[selectedEvent]);
		});
		eventDropDown.dropDirection = Down;
		blockPressDropDown.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressInputText.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressInputText.push(value2InputText);

		value3Text = new FlxText(20, 170, 0, "Value 3:");
		tab_group_event.add(value3Text);
		value3InputText = new FlxUIInputText(20, 190, 100, "");
		blockPressInputText.push(value3InputText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(value3InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";
		blockPressNumStepper.push(stepperLength);

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';
		blockPressNumStepper.push(stepperSectionBPM);

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);
		blockPressNumStepper.push(stepperCopy);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var noteSuffixInput:FlxUIInputText;
	var noteStringInput:FlxUIInputText;
	var stepperNoteTimer:FlxUINumericStepper;
	var stepperSusLength:FlxUINumericStepper;
	var tempNoteDropDown:FlxUIDropDownMenu;
	var stepperType:FlxUINumericStepper;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressNumStepper.push(stepperSusLength);

		var noteTypes:Array<String> = CoolUtil.returnAssetsLibrary('data/notetypes', 'assets');

		tempNoteDropDown = new FlxUIDropDownMenu(10, stepperSusLength.y + 30, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes, false), function(type:String)
		{
			curNoteType = type;
			if (curSelectedNote != null)
			{
				curSelectedNote[3] = curNoteType;
				updateGrid();
			}
		});
		blockPressDropDown.push(tempNoteDropDown);

		noteSuffixInput = new FlxUIInputText(10, tempNoteDropDown.y + 35, 180, "");
		blockPressInputText.push(noteSuffixInput);

		stepperNoteTimer = new FlxUINumericStepper(200, noteSuffixInput.y, 0.1, 0, 0, 10, 1);
		blockPressNumStepper.push(stepperNoteTimer);

		noteStringInput = new FlxUIInputText(10, noteSuffixInput.y + 35, 180, "");
		blockPressInputText.push(noteStringInput);

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(10, tempNoteDropDown.y - 15, 0, 'Note Type:'));
		tab_group_note.add(new FlxText(10, noteSuffixInput.y - 15, 0, 'Note Animation (replaces singing animations):'));
		tab_group_note.add(new FlxText(10, noteStringInput.y - 15, 0, 'Note Animation Suffix (e.g: -alt, miss):'));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(noteStringInput);
		tab_group_note.add(noteSuffixInput);
		tab_group_note.add(stepperNoteTimer);
		tab_group_note.add(tempNoteDropDown);

		UI_box.addGroup(tab_group_note);
		// I'm genuinely tempted to go around and remove every instance of the word "sus" it is genuinely killing me inside
	}

	var songMusic:FlxSound;
	var songMusicNew:FlxSound;

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();
		
		if (songMusic != null)
			songMusicNew.stop();

		if (vocals != null)
			vocals.stop();
		
		if (bf_vocals != null)
			bf_vocals.stop();
		
		if (opp_vocals != null)
			opp_vocals.stop();

		if (_song.instType == "Legacy" || _song.instType == null)
		{
			songMusic = new FlxSound().loadEmbedded(Paths.inst(daSong), false, true);
			songMusicNew = new FlxSound();
		}
		
		if (_song.instType == "New")
		{
			songMusicNew = new FlxSound().loadEmbedded(Paths.instNew(daSong, CoolUtil.difficultyString.toLowerCase()), false, true);
			songMusic = new FlxSound();
		}

		if (_song.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong), false, true);
			bf_vocals = new FlxSound().loadEmbedded(Paths.voicesPlayer(daSong, CoolUtil.difficultyString.toLowerCase()), false, true);
			opp_vocals = new FlxSound().loadEmbedded(Paths.voicesOpp(daSong, CoolUtil.difficultyString.toLowerCase()), false, true);
		}
		else
		{
			vocals = new FlxSound();
			bf_vocals = new FlxSound();
			opp_vocals = new FlxSound();
		}
		
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(songMusicNew);
		FlxG.sound.list.add(bf_vocals);
		FlxG.sound.list.add(opp_vocals);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		songMusicNew.play();
		bf_vocals.play();
		opp_vocals.play();
		vocals.play();

		pauseMusic();

		if (_song.instType == "Legacy" || _song.instType == null)
		{
			songMusic.onComplete = function()
			{
				ForeverTools.killMusic([songMusic, songMusicNew, vocals, bf_vocals, opp_vocals]);
				loadSong(daSong);
				changeSection();
			};
		}
		
		if (_song.instType == "New")
		{
			songMusicNew.onComplete = function()
			{
				ForeverTools.killMusic([songMusic, songMusicNew, vocals, bf_vocals, opp_vocals]);
				loadSong(daSong);
				changeSection();
			};
		}
		//
	}

	function pauseMusic()
	{
		if (_song.instType == "Legacy" || _song.instType == null)
		{
			songMusic.time = Math.max(songMusic.time, 0);
			songMusic.time = Math.min(songMusic.time, songMusic.length);
			songMusic.pause();
		}
		
		if (_song.instType == "New")
		{
			songMusicNew.time = Math.max(songMusicNew.time, 0);
			songMusicNew.time = Math.min(songMusicNew.time, songMusicNew.length);
			songMusicNew.pause();
		}

		bf_vocals.pause();
		opp_vocals.pause();
		vocals.pause();
	}

	function generateGrid():Void
	{
		gridGroup.clear();

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, GRID_SIZE * 16);
		gridGroup.add(gridBG);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridGroup.add(gridBlackLine);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridGroup.add(gridBlackLine);
	}

	function generateBackground():Void
	{
		var bg:FlxSprite = cast new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(19, 21, 33));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		var ooohFridayNightFunkiin:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/chart/bg'));
		ooohFridayNightFunkiin.setGraphicSize(Std.int(FlxG.width));
		ooohFridayNightFunkiin.scrollFactor.set();
		ooohFridayNightFunkiin.blend = BlendMode.DIFFERENCE;
		ooohFridayNightFunkiin.screenCenter();
		ooohFridayNightFunkiin.alpha = 0;
		add(ooohFridayNightFunkiin);
		FlxTween.tween(ooohFridayNightFunkiin, {alpha: 0.07}, 0.4);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;
					updateHeads();
				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);

			// ew what was this before? made it switch cases instead of else if
			switch (wname)
			{
				case 'section_length':
					_song.notes[curSection].lengthInSteps = Std.int(nums.value); // change length
					updateGrid(); // vrrrrmmm
				case 'song_speed':
					_song.speed = nums.value; // change the song speed
				case 'song_bpm':
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
					_song.bpm = tempBpm;
				case 'note_susLength': // STOP POSTING ABOUT AMONG US
					curSelectedNote[2] = nums.value; // change the currently selected note's length
					updateGrid(); // oh btw I know sus stands for sustain it just bothers me
				// set the new note type for when placing notes next!
				case 'section_bpm':
					_song.notes[curSection].bpm = Std.int(nums.value); // redefine the section's bpm
					updateGrid(); // update the note grid
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			var castedSender = cast sender;
			var senderName = castedSender.name;

			if (curSelectedEvent != null)
			{
				if (sender == value1InputText)
					curSelectedEvent[2][0][0] = value1InputText.text;
				if (sender == value2InputText)
					curSelectedEvent[2][0][1] = value2InputText.text;
				if (sender == value3InputText)
					curSelectedEvent[2][0][2] = value3InputText.text;
				updateGrid();
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection + add)
		{
			if (_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += 4 * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var lastSongPos:Null<Float> = null;

	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if (_song.instType == "Legacy" || _song.instType == null)
			Conductor.songPosition = songMusic.time;

		if (_song.instType == "New")
			Conductor.songPosition = songMusicNew.time;

		if (curStep > -1)
			strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		value3InputText.visible = Events.needsValue3.contains(eventDropDown.selectedLabel);
		value3Text.visible = value3InputText.visible;
		value3InputText.active = value3InputText.visible;

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null)
				addSection();
			changeSection(curSection + 1, false);
		}
		else if (strumLine.y < -10)
			changeSection(curSection - 1, false);

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
							selectNote(note);
						else
							deleteNote(note);
					}
				});
			}
			else if (FlxG.mouse.overlaps(curRenderedEvents))
			{
				curRenderedEvents.forEach(function(event:FlxSprite)
				{
					if (FlxG.mouse.overlaps(event))
					{
						var event = events.get(event);

						if (FlxG.keys.pressed.CONTROL)
							selectEvent(event);
						else
							deleteEvent(event);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
					if (Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) > -1)
						addNote();
					else
						addEvent();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		var lockedBinds:Bool = false;
		for (inputText in blockPressInputText)
		{
			if (inputText.hasFocus)
			{
				lockedBinds = true;
				break;
			}
		}

		if (!lockedBinds)
		{
			for (stepper in blockPressNumStepper)
			{
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if (leText.hasFocus)
				{
					lockedBinds = true;
					break;
				}
			}

			for (dropDownMenu in blockPressDropDown)
			{
				if (dropDownMenu.dropPanel.visible)
				{
					lockedBinds = true;
					break;
				}
			}
		}

		if (!lockedBinds)
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				lastSection = curSection;

				PlayState.SONG = _song;
				songMusic.stop();
				songMusicNew.stop();
				bf_vocals.stop();
				opp_vocals.stop();
				vocals.stop();
				Main.switchState(this, new PlayState());
			}

			if (FlxG.keys.justPressed.BACKSPACE)
			{
				songMusic.stop();
				songMusicNew.stop();
				bf_vocals.stop();
				opp_vocals.stop();
				vocals.stop();
				Main.switchState(this, new states.menus.FreeplayMenu());
			}

			if (FlxG.keys.justPressed.E)
				changeNoteSustain(Conductor.stepCrochet);
			if (FlxG.keys.justPressed.Q)
				changeNoteSustain(-Conductor.stepCrochet);

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				if (songMusic.playing || songMusicNew.playing)
				{
					songMusic.pause();
					vocals.pause();
					bf_vocals.pause();
					opp_vocals.pause();
					songMusicNew.pause();
				}
				else
				{
					vocals.play();
					bf_vocals.play();
					opp_vocals.play();
					songMusicNew.play();
					songMusic.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				if (curStep < 0)
					return resetSection();

				songMusic.pause();
				songMusicNew.pause();
				bf_vocals.pause();
				opp_vocals.pause();
				vocals.pause();

				if (_song.instType == "Legacy" || _song.instType == null)
				{
					songMusic.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
					vocals.time = songMusic.time;
					bf_vocals.time = songMusic.time;
					opp_vocals.time = songMusic.time;
				}
				
				if (_song.instType == "New")
				{
					songMusicNew.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
					vocals.time = songMusicNew.time;
					bf_vocals.time = songMusicNew.time;
					opp_vocals.time = songMusicNew.time;
				}
				
			}

			var holdingShift = FlxG.keys.pressed.SHIFT;
			var holdingW = FlxG.keys.pressed.W;

			// painful if statement;
			if ((!holdingShift && holdingW || FlxG.keys.pressed.S) || (holdingShift && FlxG.keys.justPressed.W || FlxG.keys.justPressed.S))
			{
				if (curStep < 0)
					return resetSection();

				songMusic.pause();
				songMusicNew.pause();
				vocals.pause();
				bf_vocals.pause();
				opp_vocals.pause();

				var daTime:Float = (FlxG.keys.pressed.SHIFT ? Conductor.stepCrochet * 2 : 700 * FlxG.elapsed);

				if ((!holdingShift && holdingW) || (holdingShift && FlxG.keys.justPressed.W))
				{
					songMusic.time -= daTime;
					songMusicNew.time -= daTime;
				}
				else
				{
					songMusic.time += daTime;
					songMusicNew.time += daTime;
				}

				if (_song.instType == "Legacy" || _song.instType == null)
				{
					vocals.time = songMusic.time;
					bf_vocals.time = songMusic.time;
					opp_vocals.time = songMusic.time;
				}
				
				if (_song.instType == "New")
				{
					vocals.time = songMusicNew.time;
					bf_vocals.time = songMusicNew.time;
					opp_vocals.time = songMusicNew.time;
				}
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;
			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
				changeSection(curSection - shiftThing);
		}

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(songMusic.length / 1000, 2))
			+ "\nMeasure: "
			+ curSection
			+ "\nBeat: "
			+ curBeat
			+ "\nStep: "
			+ curStep;
		super.update(elapsed);

		// real thanks for the help with this ShadowMario, you are the best @BeastlyGhost
		var playedSound:Array<Bool> = [];
		for (i in 0...8)
			playedSound.push(false);
		curRenderedNotes.forEachAlive(function(note:Note)
		{
			if (note.strumTime < songMusic.time)
			{
				var data:Int = note.noteData % 4;

				if (songMusic.playing && !playedSound[data] && note.noteData > -1 && note.strumTime >= lastSongPos
				   	|| songMusicNew.playing && !playedSound[data] && note.noteData > -1 && note.strumTime >= lastSongPos)
				{
					if ((playTicksBf.checked) && (note.mustPress) || (playTicksDad.checked) && (!note.mustPress))
					{
						FlxG.sound.play(Paths.sound('base/menus/chart/soundNoteTick'));
						playedSound[data] = true;
					}
				}
			}
		});

		lastSongPos = Conductor.songPosition;
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (_song.instType == "Legacy" || _song.instType == null)
				if (songMusic.time > Conductor.bpmChangeMap[i].songTime)
					lastChange = Conductor.bpmChangeMap[i];

			if (_song.instType == "New")
				if (songMusicNew.time > Conductor.bpmChangeMap[i].songTime)
					lastChange = Conductor.bpmChangeMap[i];
		}

		if (_song.instType == "Legacy" || _song.instType == null)
			curStep = lastChange.stepTime + Math.floor((songMusic.time - lastChange.songTime) / Conductor.stepCrochet);
		
		if (_song.instType == "New")
			curStep = lastChange.stepTime + Math.floor((songMusicNew.time - lastChange.songTime) / Conductor.stepCrochet);

		curBeat = Math.floor(curStep / 4);

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		songMusic.pause();
		songMusicNew.pause();
		vocals.pause();
		bf_vocals.pause();
		opp_vocals.pause();

		// Basically old shit from changeSection???
		if (_song.instType == "Legacy" || _song.instType == null)
			songMusic.time = sectionStartTime();

		if (_song.instType == "New")
			songMusicNew.time = sectionStartTime();

		if (songBeginning)
		{
			songMusic.time = 0;
			songMusicNew.time = 0;
			curSection = 0;
		}

		if (_song.instType == "Legacy" || _song.instType == null)
		{
			vocals.time = songMusic.time;
			bf_vocals.time = songMusic.time;
			opp_vocals.time = songMusic.time;
		}
		
		if (_song.instType == "New")
		{
			vocals.time = songMusicNew.time;
			bf_vocals.time = songMusicNew.time;
			opp_vocals.time = songMusicNew.time;
		}
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			if (sec < 0)
				return resetSection();

			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				songMusic.pause();
				songMusicNew.pause();
				vocals.pause();
				bf_vocals.pause();
				opp_vocals.pause();
				
				if (_song.instType == "Legacy" || _song.instType == null)
				{
					songMusic.time = sectionStartTime();
					vocals.time = songMusic.time;
					bf_vocals.time = songMusic.time;
					opp_vocals.time = songMusic.time;
				}
				
				if (_song.instType == "New")
				{
					songMusicNew.time = sectionStartTime();
					vocals.time = songMusicNew.time;
					bf_vocals.time = songMusicNew.time;
					opp_vocals.time = songMusicNew.time;
				}
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads(regenIcons:Bool = false):Void
	{
		if (regenIcons)
			generateHeads();
		if (!_song.notes[curSection].mustHitSection)
		{
			leftIcon.setPosition(gridBG.width / 2, -100);
			rightIcon.setPosition(0, -100);
		}
		else
		{
			leftIcon.setPosition(0, -100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
	}

	function generateHeads()
	{
		if (leftIcon != null)
		{
			leftIcon.destroy();
			remove(leftIcon);
		}
		if (rightIcon != null)
		{
			rightIcon.destroy();
			remove(rightIcon);
		}
		var boyfriend:objects.Boyfriend = new objects.Boyfriend();
		var opponent:objects.Character = new objects.Character();

		boyfriend.setCharacter(0, 0, _song.player1);
		opponent.setCharacter(0, 0, _song.player2);

		leftIcon = new HealthIcon(boyfriend.characterData.icon);
		rightIcon = new HealthIcon(opponent.characterData.icon);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		boyfriend.destroy();
		opponent.destroy();

		updateHeads();
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[1] > -1) // if the note data is valid;
			{
				stepperSusLength.value = curSelectedNote[2];

				if (curSelectedNote[3] != null)
					curNoteType = tempNoteDropDown.selectedLabel;

				if (curSelectedNote[4] != null)
					curSelectedNote[4] = noteStringInput.text;
				if (curSelectedNote[5] != null)
					curSelectedNote[5] = noteSuffixInput.text;
				if (curSelectedNote[6] != null)
					curSelectedNote[6] = stepperNoteTimer.value;
			}
		}
	}

	function updateGrid():Void
	{
		curRenderedNotes.clear();
		curRenderedSustains.clear();

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daNoteType:String = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4, daNoteType);
			Note.resetNote(null, Init.trueSettings.get("Note Skin"), _song.assetModifier, note);
			note.antialiasing = true;

			// var note:Note = ForeverAssets.generateArrow(null, _song.assetModifier, daStrumTime, daNoteInfo % 4, 0, daNoteType);

			note.sustainLength = daSus;
			note.noteType = daNoteType;

			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE + GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
			note.mustPress = _song.notes[curSection].mustHitSection;

			if (i[1] > 3)
				note.mustPress = !note.mustPress;

			curRenderedNotes.add(note);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}

			// attach a text to their respective notetype;
			var typeName:AbsoluteText = new AbsoluteText(100, Std.string('[$daNoteType]'));
			typeName.setForm(24);
			typeName.offsetX = -32;
			typeName.offsetY = 6;
			typeName.borderSize = 1;
			curRenderedTexts.add(typeName);
			typeName.parent = note;
		}
		updateEventGrid();
	}

	private function addSection(lengthInSteps:Int = 16, sectionBeats:Float = 4):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			sectionBeats: sectionBeats,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] != curSelectedNote && i[0] == note.strumTime && i[1] == note.noteData)
				curSelectedNote = i;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var data:Null<Int> = note.noteData;

		if (data > -1 && note.mustPress != _song.notes[curSection].mustHitSection)
			data += 4;

		if (data > -1)
		{
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == data)
				{
					FlxG.log.add('FOUND EVIL NUMBER');
					_song.notes[curSection].sectionNotes.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
			_song.notes[daSection].sectionNotes = [];

		updateGrid();
	}

	function clearEvents():Void
		_song.events = [];

	function selectEvent(event:Array<Dynamic>):Void
	{
		for (i in _song.events)
		{
			if (i[1] == event[1])
			{
				curSelectedEvent = i;
				break;
			}
		}

		updateGrid();
	}

	function deleteEvent(event:Array<Dynamic>):Void
	{
		for (i in _song.events)
		{
			if (i[0] == event[0])
			{
				_song.events.remove(i);
				break;
			}
		}

		updateGrid();
	}

	function updateEventGrid()
	{
		curRenderedEvents.clear();
		curRenderedTexts.clear();

		if (_song.events != null)
		{
			for (i in _song.events)
			{
				if (sectionStartTime(1) > i[1] && i[1] >= sectionStartTime())
				{
					var event:FlxSprite = new FlxSprite().loadGraphic(Paths.image('eventNote-base', 'images/menus/chart'));
					event.y = Math.floor(getYfromStrum((i[1] - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
					event.setGraphicSize(GRID_SIZE, GRID_SIZE);
					event.updateHitbox();
					event.antialiasing = true;
					events.set(event, i);
					curRenderedEvents.add(event);

					var daText:AbsoluteText = new AbsoluteText(300,
						'Event: ' + i[0] + ' [Time: ' + Math.fround(i[1]) + ' ms]' + '\nValues: ' + i[2][0][0] + ' - ' + i[2][0][1], 12);
					daText.setForm(12);
					daText.offsetX = -270;
					daText.offsetY = -10;
					daText.borderSize = 1;
					curRenderedTexts.add(daText);
					daText.parent = event;

					if (i[2][0][2] != null)
						daText.text += ' - ' + i[2][0][2];
				}
			}
		}

		updateEventUI();
	}

	function updateEventUI():Void
	{
		if (curSelectedEvent == null)
			return;

		eventDropDown.selectedLabel = curSelectedEvent[0];
		value1InputText.text = curSelectedEvent[2][0][0];
		value2InputText.text = curSelectedEvent[2][0][1];
		value3InputText.text = curSelectedEvent[2][0][2];
	}

	function addEvent():Void
	{
		var event:String = Events.eventArray[Std.parseInt(eventDropDown.selectedId)];
		var step:Float = getStrumTime(dummyArrow.y) + sectionStartTime();
		var values:Array<String> = [value1InputText.text, value2InputText.text, value3InputText.text];
		var colors:Array<Int> = [255, 255, 255];

		// order: event name, trigger step, [values in a string array]
		_song.events.push([event, step, [values /*, colors*/]]);
		curSelectedEvent = _song.events[_song.events.length - 1];

		updateGrid();
	}

	function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteType = curNoteType; // define notes as the current type
		var noteSus = 0; // ninja you will NOT get away with this
		var noteString = noteStringInput.text; // define the note's animation override;
		var noteSuffix = noteSuffixInput.text; // define the note's animation suffix;
		var noteTimer = stepperNoteTimer.value; // define the note's animation timer;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType, noteSuffix, noteString, noteTimer]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteType]);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);

	function getYfromStrum(strumTime:Float):Float
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseSong(FlxG.save.data.autosave, null);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}
}

private final class AbsoluteText extends FlxText
{
	public var offsetX:Float;
	public var offsetY:Float;
	public var parent:FlxSprite;

	public function new(width:Int, text:String, ?offsetX:Float = 0, ?offsetY:Float = 0)
	{
		super(0, 0, width, text);
	}

	public function setForm(size:Int):AbsoluteText
	{
		setFormat(Paths.font("vcr"), size, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		return this;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (parent != null)
		{
			setPosition(parent.x + offsetX, parent.y + offsetY);
			alpha = parent.alpha;
		}
	}
}
