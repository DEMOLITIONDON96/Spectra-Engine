package states.substates.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUITabMenu;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import haxe.Json;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import states.MusicBeatState.MusicBeatSubstate;

enum ExportFile
{
	CHART;
	CHARACTER;
	STAGE;
}

enum ChartType
{
	VANILLA;
	PSYCH;
}

class ExportSubstate extends MusicBeatSubstate
{
	var _file:FileReference;
	var UI_box:FlxUITabMenu;

	public var exportType:ExportFile = CHART;
	public var chartType:ChartType = VANILLA;

	public var _saveData:Dynamic;
	public var isEvent:Bool = false;

	public function new(exportType:ExportFile, _saveData:Dynamic, ?isEvent:Bool = false)
	{
		super();

		this.exportType = exportType;
		this._saveData = _saveData;
		this.isEvent = isEvent;
	}

	override public function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		// create a little UI Box for exporting stuffs
		UI_box = new FlxUITabMenu(null, [{name: "Export Data", label: 'Export Data'}], true);

		UI_box.resize(120, 90);
		UI_box.x = Math.floor((FlxG.width / 2) - (UI_box.width / 2));
		UI_box.screenCenter(Y);
		UI_box.scrollFactor.set();
		UI_box.alpha = 0;
		add(UI_box);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(UI_box, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

		addExportUI();
	}

	var UI_title:FlxUIInputText;

	function addExportUI():Void
	{
		var tab_group_save = new FlxUI(null, UI_box);
		tab_group_save.name = 'Export Data';

		UI_title = new FlxUIInputText(10, 10, 90, isEvent ? 'events' : _saveData.song, 8);
		var saveButton:FlxButton = new FlxButton(10, 30, "Export", function()
		{
			if (isEvent)
				saveLevelEvents();
			else
				saveLevel();
		});

		/*
			var chartTypeDD = new FlxUIDropDownMenu(10, saveButton + 90, FlxUIDropDownMenu.makeStrIdLabelArray([VANILLA, PSYCH], false), function(type:ChartType)
			{
				chartType = type;
			});
		 */

		tab_group_save.add(UI_title);
		tab_group_save.add(saveButton);

		UI_box.addGroup(tab_group_save);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.pressed.ESCAPE)
			close();
	}

	/*
	 *    CHART SAVING
	 */
	function saveLevel()
	{
		if (UI_title.text != null && UI_title.text.length > 1)
			_saveData.song = UI_title.text;

		var json = {
			"song": _saveData
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _saveData.song + ".json");
		}
	}

	function saveLevelEvents()
	{
		var json = cast {
			"events": _saveData.events.copy()
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Data was saved successfully.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving data");
	}
}
