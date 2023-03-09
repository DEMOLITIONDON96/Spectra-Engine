package states.substates;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.fonts.Alphabet;
import states.MusicBeatState.MusicBeatSubstate;

class OptionsSubstate extends MusicBeatSubstate
{
	private var curSelection = 0;

	private var submenuGroup:FlxTypedGroup<FlxBasic>;
	private var submenuoffsetGroup:FlxTypedGroup<FlxBasic>;
	private var submenuResetGroup:FlxTypedGroup<FlxBasic>;

	private var offsetTemp:Float;

	// the controls class thingy
	override public function create():Void
	{
		// call the options menu
		var bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.color = 0xD8B168;
		bg.antialiasing = true;
		add(bg);

		super.create();

		keyOptions = generateOptions();
		updateSelection();

		submenuGroup = new FlxTypedGroup<FlxBasic>();
		submenuoffsetGroup = new FlxTypedGroup<FlxBasic>();
		submenuResetGroup = new FlxTypedGroup<FlxBasic>();

		submenu = new FlxSprite(0, 0).makeGraphic(FlxG.width - 200, FlxG.height - 200, FlxColor.fromRGB(250, 253, 109));
		submenu.screenCenter();

		// submenu group
		var submenuText = new Alphabet(0, 0, "Press any key to rebind", true, false);
		submenuText.screenCenter();
		submenuText.y -= 32;
		submenuGroup.add(submenuText);

		var submenuText2 = new Alphabet(0, 0, "FTEN to Cancel", true, false);
		submenuText2.screenCenter();
		submenuText2.y += 32;
		submenuGroup.add(submenuText2);

		// submenuoffset group
		// this code by codist
		var submenuOffsetText = new Alphabet(0, 0, "Left or Right to edit", true, false);
		submenuOffsetText.screenCenter();
		submenuOffsetText.y -= 144;
		submenuoffsetGroup.add(submenuOffsetText);

		var submenuOffsetText2 = new Alphabet(0, 0, "Negative is Late", true, false);
		submenuOffsetText2.screenCenter();
		submenuOffsetText2.y -= 100;
		submenuoffsetGroup.add(submenuOffsetText2);

		var submenuOffsetText3 = new Alphabet(0, 0, "Escape to Cancel", true, false);
		submenuOffsetText3.screenCenter();
		submenuOffsetText3.y += 102;
		submenuoffsetGroup.add(submenuOffsetText3);

		var submenuOffsetText4 = new Alphabet(0, 0, "Enter to Save", true, false);
		submenuOffsetText4.screenCenter();
		submenuOffsetText4.y += 204;
		submenuoffsetGroup.add(submenuOffsetText4);

		var submenuOffsetValue:FlxText = new FlxText(0, 0, 0, "< 0ms >", 50, false);
		submenuOffsetValue.screenCenter();
		submenuOffsetValue.borderColor = FlxColor.BLACK;
		submenuOffsetValue.borderSize = 5;
		submenuOffsetValue.borderStyle = FlxTextBorderStyle.OUTLINE;
		submenuoffsetGroup.add(submenuOffsetValue);

		// alright back to my code :ebic:

		// submenu reset texts;
		var submenuResetText = new Alphabet(0, 0, "This cannot be undone", true, false);
		submenuResetText.screenCenter();
		submenuResetText.y -= 144;
		submenuResetGroup.add(submenuResetText);

		var submenuResetText2 = new Alphabet(0, 0, "Are you sure", true, false);
		submenuResetText2.screenCenter();
		submenuResetText2.y -= 50;
		submenuResetGroup.add(submenuResetText2);

		var submenuResetText3 = new Alphabet(0, 0, "Escape to Cancel", true, false);
		submenuResetText3.screenCenter();
		submenuResetText3.y += 102;
		submenuResetGroup.add(submenuResetText3);

		var submenuResetText4 = new Alphabet(0, 0, "Enter to Proceed", true, false);
		submenuResetText4.screenCenter();
		submenuResetText4.y += 164;
		submenuResetGroup.add(submenuResetText4);

		add(submenu);
		add(submenuGroup);
		add(submenuoffsetGroup);
		add(submenuResetGroup);
		submenu.visible = false;
		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
		submenuResetGroup.visible = false;
	}

	private var keyOptions:FlxTypedGroup<Alphabet>;
	private var otherKeys:FlxTypedGroup<Alphabet>;

	private function generateOptions()
	{
		keyOptions = new FlxTypedGroup<Alphabet>();

		var myControls:Array<String> = [];
		// re-sort everything according to the list numbers
		for (controlString in Controls.actions.keys())
			myControls[Controls.actionSort.get(controlString)] = controlString;

		//
		myControls.push('');
		#if !neko myControls.push("EDIT OFFSET"); #end // append edit offset to the end of the array
		// myControls.push('RESET KEYBINDS');

		for (i in 0...myControls.length)
		{
			// generate key options lol
			var optionsText:Alphabet = new Alphabet(0, 0, myControls[i].replace('_', ' '), true, false);
			optionsText.screenCenter();
			optionsText.y += (90 * (i - (myControls.length / 2)));
			optionsText.targetY = i;
			optionsText.disableX = true;
			optionsText.isMenuItem = true;
			optionsText.alpha = 0.6;

			keyOptions.add(optionsText);
		}

		// stupid shubs you always forget this
		add(keyOptions);

		generateExtra(myControls);

		return keyOptions;
	}

	private function generateExtra(myControls:Array<String>)
	{
		otherKeys = new FlxTypedGroup<Alphabet>();
		for (i in 0...myControls.length)
		{
			for (j in 0...2)
			{
				var keyString = "";

				if (Controls.actions.exists(myControls[i]))
					keyString = Controls.returnStringKey(Controls.actions.get(myControls[i])[j]);

				var secondaryText:Alphabet = new Alphabet(0, 0, keyString, false, false);
				secondaryText.screenCenter();
				secondaryText.y += (90 * (i - (myControls.length / 2)));
				secondaryText.targetY = i;
				secondaryText.disableX = true;
				secondaryText.xTo += ((j + 1) * 420);
				secondaryText.isMenuItem = true;
				secondaryText.alpha = 0.6;

				otherKeys.add(secondaryText);
			}
		}
		add(otherKeys);

		myControls = [];
	}

	private function updateSelection(equal:Int = 0)
	{
		if (equal != curSelection)
			FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
		var prevSelection:Int = curSelection;

		// wrap the current selection
		curSelection = FlxMath.wrap(equal, 0, keyOptions.length - 1);

		//
		for (i in 0...keyOptions.length)
		{
			keyOptions.members[i].alpha = 0.6;
			keyOptions.members[i].targetY = (i - curSelection) / 2;
		}
		keyOptions.members[curSelection].alpha = 1;

		///*
		for (i in 0...otherKeys.length)
		{
			otherKeys.members[i].alpha = 0.6;
			otherKeys.members[i].targetY = (((Math.floor(i / 2)) - curSelection) / 2) - 0.25;
		}
		otherKeys.members[(curSelection * 2) + curHorizontalSelection].alpha = 1;
		// */
		if (keyOptions.members[curSelection].text == '' && curSelection != prevSelection)
			updateSelection(curSelection + (curSelection - prevSelection));
	}

	private var curHorizontalSelection = 0;

	private function updateHorizontalSelection()
	{
		var left = Controls.getPressEvent("ui_left");
		var right = Controls.getPressEvent("ui_right");
		var horizontalControl:Array<Bool> = [left, false, right];

		if (horizontalControl.contains(true))
		{
			for (i in 0...horizontalControl.length)
			{
				if (horizontalControl[i] == true)
				{
					curHorizontalSelection += (i - 1);

					if (curHorizontalSelection < 0)
						curHorizontalSelection = 1;
					else if (curHorizontalSelection > 1)
						curHorizontalSelection = 0;

					// update stuffs
					FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
				}
			}

			updateSelection(curSelection);
			//
		}
	}

	private var submenuOpen:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!submenuOpen)
		{
			var up = Controls.getPressEvent("ui_up", "pressed");
			var down = Controls.getPressEvent("ui_down", "pressed");
			var up_p = Controls.getPressEvent("ui_up");
			var down_p = Controls.getPressEvent("ui_down");
			var controlArray:Array<Bool> = [up, down, up_p, down_p];

			if (controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					// here we check which keys are pressed
					if (controlArray[i] == true)
					{
						// if single press
						if (i > 1)
						{
							// up is 2 and down is 3
							// paaaaaiiiiiiinnnnn
							if (i == 2)
								updateSelection(curSelection - 1);
							else if (i == 3)
								updateSelection(curSelection + 1);
						}
					}
					//
				}
			}

			//
			updateHorizontalSelection();

			if (Controls.getPressEvent("accept"))
			{
				FlxG.sound.play(Paths.sound('base/menus/confirmMenu'));
				submenuOpen = true;

				FlxFlicker.flicker(otherKeys.members[(curSelection * 2) + curHorizontalSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
				{
					if (submenuOpen)
						openSubmenu();
				});
			}
			else if (Controls.getPressEvent("back"))
				close();
		}
		else
			subMenuControl();
	}

	override public function close()
	{
		//
		Init.saveControls(); // for controls
		Init.saveSettings(); // for offset
		super.close();
	}

	private var submenu:FlxSprite;

	private function openSubmenu()
	{
		offsetTemp = Init.trueSettings['Offset'];

		submenu.visible = true;
		switch (keyOptions.members[curSelection].text)
		{
			case "RESET KEYBINDS":
				submenuResetGroup.visible = true;
			case "EDIT OFFSET":
				submenuoffsetGroup.visible = true;
			default:
				submenuGroup.visible = true;
		}
	}

	private function closeSubmenu()
	{
		submenuOpen = false;
		submenu.visible = false;

		submenuGroup.visible = false;
		submenuoffsetGroup.visible = false;
		submenuResetGroup.visible = false;
	}

	private function subMenuControl()
	{
		// I dont really like hardcoded shit so I'm probably gonna change this lmao
		switch (keyOptions.members[curSelection].text)
		{
			case "RESET KEYBINDS":
				if (FlxG.keys.justPressed.ENTER)
				{
					Controls.actions = Controls.defaultActions;
					FlxG.save.data.actionBinds == null;
					closeSubmenu();
				}
				else if (FlxG.keys.justPressed.ESCAPE)
					closeSubmenu();

			case "EDIT OFFSET":
				if (FlxG.keys.justPressed.ENTER)
				{
					Init.trueSettings['Offset'] = offsetTemp;
					closeSubmenu();
				}
				else if (FlxG.keys.justPressed.ESCAPE)
					closeSubmenu();

				var move = 0;
				if (FlxG.keys.pressed.LEFT)
					move = -1;
				else if (FlxG.keys.pressed.RIGHT)
					move = 1;

				offsetTemp += move * 0.1;

				submenuoffsetGroup.forEachOfType(FlxText, str ->
				{
					str.text = "< " + Std.string(Math.floor(offsetTemp * 10) / 10) + " >";
					str.screenCenter(X);
				});

			default:
				// be able to close the submenu
				if (FlxG.keys.justPressed.F10)
					closeSubmenu();
				else if (FlxG.keys.justPressed.ANY)
				{
					// loop through existing keys and see if there are any alike
					var checkKey = FlxG.keys.getIsDown()[0].ID;

					// now check if its the key we want to change
					Controls.actions.get(keyOptions.members[curSelection].text.replace(' ', '_'))[curHorizontalSelection] = checkKey;
					otherKeys.members[(curSelection * 2) + curHorizontalSelection].text = Controls.returnStringKey(checkKey);

					var keyText:String = keyOptions.members[curSelection].text.toLowerCase();

					// set the new key for the selected action;
					Controls.setActionKey(keyText, curHorizontalSelection, checkKey);

					// close the submenu
					closeSubmenu();
				}
				//
		}
	}
}
