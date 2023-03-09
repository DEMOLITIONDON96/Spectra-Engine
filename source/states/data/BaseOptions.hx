package states.data;

import base.dependency.Discord;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import objects.fonts.Alphabet;
import objects.ui.menu.Checkmark;
import objects.ui.menu.Selector;
import states.MusicBeatState;
import states.data.OptionsData.GroupData;

/**
 * The Base Options class manages Option Attachments;
 * among some useful functions for the main options menu;
 *
 * simply put, it initializes elements like Checkmarks and Selectors;
 * along with having neat little functions to go from a section to another;
 */
class BaseOptions extends MusicBeatState
{
	/*
		== OPTIONS DOCUMENTATION ==

		to set up a category, add to the categoriesMap
		format should be this;

		"categoryName" => [
			{name: "option name", type: "option type"}
		]

		type may be: "option", "subgroup", or "divider";
		additionally, you can create your own types by adding
		an action to a specific type;

		subgroups - create a new category and sets options for them;
		options for subgroups can be set in the OptionsData class

		options - your usual options, can be toggled on or off, or sometimes can have different values set by you;
		options can be created in the Init class, and can be added to this menu with the OptionsData class

		divider - an unselectable option, can be used as a category name of sorts;

		keybinds - triggers the "Controls" Menu;
	 */
	public var categoriesMap:Map<String, Array<GroupData>> = [
		"main" => [
			{name: "preferences", type: "subgroup", description: "Define your Game Preferences."},
			{name: "accessibility", type: "subgroup", description: "Make the game more accessible for yourself."},
			{name: "visuals", type: "subgroup", description: "Define your Visuals, such as Note Skins or Judgements!"},
			{name: "keybinds", type: "keybinds", description: "Define your preferred keys for use during Gameplay."}
		],
	];

	public var alphabetGroup:FlxTypedGroup<Alphabet>;
	public var attachmentsGroup:FlxTypedGroup<FlxBasic>;
	public var attachmentsMap:Map<Alphabet, Dynamic>;

	public var aboveGroup:FlxTypedGroup<FlxBasic>;

	public var activeGroup:Array<GroupData> = [];

	public var curSelected:Int = 0;
	public var curCategory:String = 'main';

	override public function create()
	{
		super.create();

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		// set up category contents;
		categoriesMap.set("preferences", OptionsData.preferences);
		categoriesMap.set("accessibility", OptionsData.accessibility);
		categoriesMap.set("visuals", OptionsData.visuals);

		updateDiscord();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (attachmentsGroup != null)
			repositionAttachments();

		if (activeGroup != null)
		{
			for (i in 0...activeGroup.length)
			{
				if (activeGroup[i].type == "divider") // skip dividers;
					alphabetGroup.members[i].alpha = 0.6;
			}
		}
	}

	function repositionAttachments()
	{
		// move the attachments if there are any
		for (setting in attachmentsMap.keys())
		{
			if ((setting != null) && (attachmentsMap.get(setting) != null))
			{
				var thisAttachment = attachmentsMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}
	}

	public function updateDiscord(?forcedPresence:String)
	{
		var myPresence:String = curCategory == 'main' ? 'Navigating through Categories' : 'Changing $curCategory';

		#if DISCORD_RPC
		// changes depending on your current category;
		Discord.changePresence(forcedPresence == null ? myPresence.toUpperCase() : forcedPresence, 'Options Menu');
		#end
	}

	public function callAttachments()
	{
		// destroy existing instances of groups;
		if (attachmentsGroup != null)
			remove(attachmentsGroup);

		// re-add
		attachmentsMap = generateAttachments(alphabetGroup);
		attachmentsGroup = new FlxTypedGroup<FlxBasic>();
		for (setting in alphabetGroup)
			if (attachmentsMap.get(setting) != null)
				attachmentsGroup.add(attachmentsMap.get(setting));
		add(attachmentsGroup);

		repositionAttachments();
	}

	public function switchCategory(newCategory:String)
	{
		curCategory = newCategory;
		updateDiscord();

		generateOptions(categoriesMap.get(newCategory));

		// reset selection;
		curSelected = 0;
		updateSelections(curSelected);
	}

	public function updateSelections(newSelection:Int)
	{
		// direction increment finder
		var directionIncrement = ((newSelection < curSelected) ? -1 : 1);
		curSelected = FlxMath.wrap(newSelection, 0, activeGroup.length - 1);

		// define the description;
		if (Init.gameSettings.get(alphabetGroup.members[curSelected].text) != null)
		{
			var currentSetting = Init.gameSettings.get(alphabetGroup.members[curSelected].text);
			var textValue = currentSetting[2];

			if (activeGroup[curSelected].description == null)
				activeGroup[curSelected].description = textValue == null ? '' : textValue;
		}

		var bullShit:Int = 0;
		for (item in alphabetGroup)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
				item.alpha = 1;

			if (attachmentsMap != null)
				setAttachmentAlpha(attachmentsMap.get(item), item.alpha);
		}

		for (i in 0...activeGroup.length)
		{
			if (activeGroup[curSelected].type == "divider")
				updateSelections(curSelected + directionIncrement);
		}
	}

	inline function setAttachmentAlpha(attachment:flixel.FlxSprite, newAlpha:Float)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.alpha = newAlpha;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	public function generateOptions(groupArray:Array<GroupData>)
	{
		activeGroup = groupArray;

		if (alphabetGroup != null)
		{
			alphabetGroup.clear();
			alphabetGroup.kill();
			remove(alphabetGroup);
		}

		alphabetGroup = new FlxTypedGroup<Alphabet>();

		for (i in 0...groupArray.length)
		{
			var option = groupArray[i];

			if (option.type != null
				&& (Init.gameSettings.get(option.name) == null || Init.gameSettings.get(option.name) != Init.SettingState.FORCED))
			{
				var thisOption:Alphabet = new Alphabet(160, 0, option.name, true, false);
				if (option.type != "divider")
				{
					thisOption.screenCenter();
					thisOption.y += (125 * (i - Math.floor(groupArray.length / 2)) + 75);
				}
				else
				{
					// hardcoded divider centering lol;
					thisOption.screenCenter(X);
					thisOption.forceX = thisOption.x;
					thisOption.yAdd = -55;
					thisOption.scrollFactor.set();
				}
				thisOption.targetY = i;
				thisOption.disableX = true;
				// the main category shouldn't scroll;
				if (curCategory != 'main')
					thisOption.isMenuItem = true;
				thisOption.alpha = 0.6;
				alphabetGroup.add(thisOption);
			}
		}

		// call the attachments
		callAttachments();

		add(alphabetGroup);

		// add group that goes over attachments;
		if (aboveGroup != null)
		{
			aboveGroup.clear();
			aboveGroup.kill();
			remove(aboveGroup);
		}

		aboveGroup = new FlxTypedGroup<FlxBasic>();
		add(aboveGroup);
	}

	public function generateAttachments(alpha:FlxTypedGroup<Alphabet>)
	{
		var tempMap:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();
		for (option in alpha)
		{
			if (Init.gameSettings.get(option.text) != null)
			{
				switch (Init.gameSettings.get(option.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, option.y, 'checkboxThingie', 'base', Init.trueSettings.get("UI Skin"), 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(option.text)) + ' finished');
						checkmark.scrollFactor.set();
						tempMap.set(option, checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(10, option.y, option.text, Init.gameSettings.get(option.text)[4]);
						selector.scrollFactor.set();
						tempMap.set(option, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return tempMap;
	}

	/*
		Checkmarks!
	 */
	public function updateCheckmarks()
	{
		if (Controls.getPressEvent("accept"))
		{
			FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

			if (Init.trueSettings.get(alphabetGroup.members[curSelected].text) != null)
				Init.trueSettings.set(alphabetGroup.members[curSelected].text, !Init.trueSettings.get(alphabetGroup.members[curSelected].text));

			attachmentsMap.get(alphabetGroup.members[curSelected]).playAnim(Std.string(Init.trueSettings.get(alphabetGroup.members[curSelected].text)));
			// trace('${alphabetGroup.members[curSelected].text} is: ${Init.trueSettings.get(alphabetGroup.members[curSelected].text)}');

			// save the setting
			Init.saveSettings();
		}
	}

	/*
		Selectors!
	 */
	public function updateSelectors()
	{
		//
		var selector:Selector = attachmentsMap.get(alphabetGroup.members[curSelected]);

		if (!Controls.getPressEvent("ui_left", "pressed"))
			selector.selectorPlay('left');
		if (!Controls.getPressEvent("ui_right", "pressed"))
			selector.selectorPlay('right');

		if (Controls.getPressEvent("ui_left"))
			updateSelector(selector, -1);
		if (Controls.getPressEvent("ui_right"))
			updateSelector(selector, 1);
	}

	public function updateSelector(selector:Selector, updateBy:Int)
	{
		if (selector.isNumber)
		{
			switch (selector.name)
			{
				case 'Framerate Cap':
					setupSelector(updateBy, selector, 30, 360, 15);
				case 'Darkness Opacity':
					setupSelector(updateBy, selector, 0, 100, 5);
				default:
					setupSelector(updateBy, selector);
			}
		}
		else
		{
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null)
			{
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.chosenOptionString)
						storedNumber = curOption;
				}

				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

			selector.chosenOptionString = selector.options[newSelection];

			Init.trueSettings.set(selector.name, selector.chosenOptionString);
			Init.saveSettings();

			// trace('${selector.name} is: ${selector.chosenOptionString}');
		}
	}

	public function setupSelector(updateBy:Int, selector:Selector, min:Float = 0, max:Float = 100, inc:Float = 5)
	{
		// lazily hardcoded selector generator.
		var originalValue = Init.trueSettings.get(selector.name);
		var increase = inc * updateBy;
		// min
		if (originalValue + increase < min)
			increase = 0;
		// max
		if (originalValue + increase > max)
			increase = 0;

		if (updateBy == -1)
			selector.selectorPlay('left', 'press');
		else
			selector.selectorPlay('right', 'press');

		FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));

		originalValue += increase;
		selector.chosenOptionString = Std.string(originalValue);
		Init.trueSettings.set(selector.name, originalValue);
		Init.saveSettings();
	}
}
