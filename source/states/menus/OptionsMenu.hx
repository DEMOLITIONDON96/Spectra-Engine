package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import objects.fonts.Alphabet;
import states.data.BaseOptions;
import states.data.OptionsData;

class OptionsMenu extends BaseOptions
{
	var bg:FlxSprite;
	var infoText:FlxText;

	override public function create()
	{
		super.create();

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.set(0, 0.18);
		bg.color = 0xD8B168;
		bg.antialiasing = true;
		add(bg);

		generateOptions(categoriesMap.get("main"));

		infoText = new FlxText(5, 0, 0, "", 32);
		infoText.setFormat(Paths.font("vcr"), 20, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = 0xFF000000;

		// add above everything;
		insert(members.indexOf(aboveGroup), infoText);

		updateSelections(curSelected);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// typical controls array tomfoolery
		var up = Controls.getPressEvent("ui_up", "pressed");
		var down = Controls.getPressEvent("ui_down", "pressed");
		var up_p = Controls.getPressEvent("ui_up");
		var down_p = Controls.getPressEvent("ui_down");
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if ((controlArray.contains(true)))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up == 2 - down == 3
						if (i == 2)
							updateSelections(curSelected - 1);
						else if (i == 3)
							updateSelections(curSelected + 1);

						FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
					}
				}
				//
			}
		}

		var optionText = alphabetGroup.members[curSelected].text;

		if (Controls.getPressEvent("accept"))
		{
			if (activeGroup[curSelected].type == "keybinds")
			{
				//
				FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
				openSubState(new states.substates.OptionsSubstate());
				updateSelections(curSelected);
			}
			else if (activeGroup[curSelected].type == "subgroup")
			{
				FlxG.sound.play(Paths.sound('base/menus/scrollMenu'));
				switchCategory(optionText.toLowerCase());
				updateSelections(curSelected);
			}
		}

		if (Init.gameSettings.get(optionText) != null)
		{
			switch (Init.gameSettings.get(optionText)[1])
			{
				case Init.SettingTypes.Checkmark:
					if (Controls.getPressEvent("accept"))
						updateCheckmarks();
				case Init.SettingTypes.Selector:
					updateSelectors();
			}
		}

		if (Controls.getPressEvent("back"))
		{
			FlxG.sound.play(Paths.sound('base/menus/cancelMenu'));
			if (curCategory != 'main')
			{
				switchCategory('main');
				updateSelections(curSelected);
			}
			else
			{
				if (states.substates.PauseSubstate.toOptions)
					Main.switchState(this, new PlayState());
				else
					Main.switchState(this, new MainMenu());
			}
		}
	}

	override public function updateSelections(newSelection:Int)
	{
		super.updateSelections(newSelection);

		if (activeGroup[curSelected].description != null)
		{
			infoText.text = activeGroup[curSelected].description;
			infoText.y = FlxG.height - infoText.height - 2; // line breaking;
			infoText.screenCenter(X);
		}
		else
			infoText.text = '';
	}
}
