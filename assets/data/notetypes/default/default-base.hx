function generateReceptor(receptor)
{
	var stringSect:String = Receptor.actions[receptor.strumData];

	receptor.frames = Paths.getSparrowAtlas(getSkinPath("NOTE_assets", "default"), 'data/notetypes');

	receptor.animation.addByPrefix('static', 'arrow' + stringSect.toUpperCase());
	receptor.animation.addByPrefix('pressed', stringSect + ' press', 24, false);
	receptor.animation.addByPrefix('confirm', stringSect + ' confirm', 24, false);

	receptor.setGraphicSize(Std.int(receptor.width * 0.7));
	receptor.antialiasing = true;

	var offsetMiddleX = 0;
	var offsetMiddleY = 0;
	if (receptor.strumData > 0 && receptor.strumData < 3)
	{
		offsetMiddleX = 2;
		offsetMiddleY = 2;
		if (receptor.strumData == 1)
		{
			offsetMiddleX -= 1;
			offsetMiddleY += 2;
		}
	}

	receptor.addOffset('static');
	receptor.addOffset('pressed', -2, -2);
	receptor.addOffset('confirm', 36 + offsetMiddleX, 36 + offsetMiddleY);
	receptor.playAnim('static');
}

function generateNote(newNote)
{
	var stringSect = Receptor.colors[newNote.noteData];
	var dirSect = Receptor.actions[newNote.noteData];

	if (StringTools.startsWith(Init.trueSettings.get("Note Skin"), "quant"))
	{
		newNote.determineQuantIndex(newNote.strumTime, newNote);

		//
		newNote.loadGraphic(Paths.image("default/skins/quant/base/NOTE_quants", 'data/notetypes'), true, 157, 157);
		newNote.animation.add('leftScroll', [0 + (newNote.noteQuant * 4)]);
		// LOL downscroll thats so funny to me
		newNote.animation.add('downScroll', [1 + (newNote.noteQuant * 4)]);
		newNote.animation.add('upScroll', [2 + (newNote.noteQuant * 4)]);
		newNote.animation.add('rightScroll', [3 + (newNote.noteQuant * 4)]);
		newNote.playAnim(dirSect + 'Scroll');
	}
	else
	{
		newNote.frames = Paths.getSparrowAtlas(getSkinPath('NOTE_assets', 'default'), 'data/notetypes');
		newNote.animation.addByPrefix(stringSect + 'Scroll', stringSect + '0');
		newNote.playAnim(stringSect + 'Scroll');
	}

	newNote.setGraphicSize(Std.int(newNote.width * 0.7));
	newNote.antialiasing = true;
	newNote.updateHitbox();
}

function generateSustain(newNote)
{
	var stringSect = Receptor.colors[newNote.noteData];

	if (StringTools.startsWith(Init.trueSettings.get("Note Skin"), "quant"))
	{
		newNote.determineQuantIndex(newNote.strumTime, newNote);
		newNote.holdHeight = 0.862;

		//
		newNote.loadGraphic(Paths.image("default/skins/quant/base/HOLD_quants", 'data/notetypes'), true, 109, 52);
		newNote.animation.add('hold', [0 + (newNote.noteQuant * 4)]);
		newNote.animation.add('holdend', [1 + (newNote.noteQuant * 4)]);
		newNote.animation.add('rollhold', [2 + (newNote.noteQuant * 4)]);
		newNote.animation.add('rollend', [3 + (newNote.noteQuant * 4)]);
		newNote.setGraphicSize(Std.int(newNote.width * 0.7));

		newNote.playAnim('holdend');
		if (newNote.prevNote != null && newNote.prevNote.isSustainNote)
			newNote.prevNote.playAnim('hold');
	}
	else
	{
		newNote.frames = Paths.getSparrowAtlas(getSkinPath('NOTE_assets', 'default'), 'data/notetypes');
		newNote.animation.addByPrefix(stringSect + 'holdend', stringSect + ' hold end');
		newNote.animation.addByPrefix(stringSect + 'hold', stringSect + ' hold piece');
		newNote.animation.addByPrefix('purpleholdend', 'pruple end hold'); // PA god dammit.
		newNote.setGraphicSize(Std.int(newNote.width * 0.7));

		newNote.playAnim(stringSect + 'holdend');
		if (newNote.prevNote != null && newNote.prevNote.isSustainNote)
			newNote.prevNote.playAnim(stringSect + 'hold');
	}

	newNote.antialiasing = true;
	newNote.updateHitbox();
}

function generateSplash(noteSplash, noteData)
{
	if (Init.trueSettings.get("UI Skin") == "forever")
	{
		noteSplash.loadGraphic(Paths.image(getSkinPath('noteSplashes', 'default'), 'data/notetypes'), true, 210, 210);
		noteSplash.animation.add('anim1', [
			(noteData * 2 + 1),
			8 + (noteData * 2 + 1),
			16 + (noteData * 2 + 1),
			24 + (noteData * 2 + 1),
			32 + (noteData * 2 + 1)
		], 24, false);
		noteSplash.animation.add('anim2', [
			(noteData * 2),
			8 + (noteData * 2),
			16 + (noteData * 2),
			24 + (noteData * 2),
			32 + (noteData * 2)
		], 24, false);

		noteSplash.addOffset('anim1', 25, 25);
		noteSplash.addOffset('anim2', 25, 25);
	}
	else
	{
		noteSplash.frames = Paths.getSparrowAtlas(getSkinPath('noteSplashesOG', 'default'), 'data/notetypes');
		noteSplash.animation.addByPrefix('anim1', 'note impact 1 ' + Receptor.colors[noteData], 24, false);
		noteSplash.animation.addByPrefix('anim2', 'note impact 2 ' + Receptor.colors[noteData], 24, false);
		noteSplash.animation.addByPrefix('anim1', 'note impact 1  blue', 24, false); // HE DID IT AGAIN EVERYONE;

		noteSplash.addOffset('anim1', 65, 60);
		noteSplash.addOffset('anim2', 65, 60);
		noteSplash.updateHitbox();
	}

	noteSplash.playAnim('anim' + FlxG.random.int(1, 2));
	noteSplash.alpha = Init.trueSettings.get("Splash Opacity") * 0.01;
}

function getSkinPath(skin:String, path:String):String
{
	var noteSkin = Init.trueSettings.get("Note Skin");
	return ForeverTools.returnSkinAsset(skin, 'base', noteSkin, 'default/skins', path);
}
