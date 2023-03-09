function generateReceptor(receptor)
{
	receptor.loadGraphic(Paths.image("default/skins/default/pixel/NOTE_assets", 'data/notetypes'), true, 17, 17);
	receptor.animation.add('static', [receptor.strumData]);
	receptor.animation.add('pressed', [4 + receptor.strumData, 8 + receptor.strumData], 12, false);
	receptor.animation.add('confirm', [12 + receptor.strumData, 16 + receptor.strumData], 24, false);

	receptor.setGraphicSize(Std.int(receptor.width * PlayState.daPixelZoom));
	receptor.updateHitbox();
	receptor.antialiasing = false;

	receptor.addOffset('static', -67, -50);
	receptor.addOffset('pressed', -67, -50);
	receptor.addOffset('confirm', -67, -50);
}

function generateNote(newNote)
{
	var pixelData:Array<Int> = [4, 5, 6, 7];

	if (StringTools.startsWith(Init.trueSettings.get("Note Skin"), "quant"))
	{
		newNote.determineQuantIndex(newNote.strumTime, newNote);

		//
		newNote.loadGraphic(Paths.image("default/skins/quant/pixel/NOTE_quants", 'data/notetypes'), true, 17, 17);
		newNote.animation.add('leftScroll', [0 + (newNote.noteQuant * 4)]);
		// LOL downscroll thats so funny to me
		newNote.animation.add('downScroll', [1 + (newNote.noteQuant * 4)]);
		newNote.animation.add('upScroll', [2 + (newNote.noteQuant * 4)]);
		newNote.animation.add('rightScroll', [3 + (newNote.noteQuant * 4)]);
		newNote.playAnim(Receptor.actions[newNote.noteData] + 'Scroll');
	}
	else
	{
		newNote.loadGraphic(Paths.image("default/skins/default/pixel/NOTE_assets", 'data/notetypes'), true, 17, 17);
		newNote.animation.add(Receptor.colors[newNote.noteData] + 'Scroll', [pixelData[newNote.noteData]], 12);
		newNote.animation.play(Receptor.colors[newNote.noteData] + 'Scroll');
	}

	newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
	newNote.antialiasing = false;
	newNote.updateHitbox();
}

function generateSustain(newNote)
{
	var pixelData:Array<Int> = [4, 5, 6, 7];

	if (StringTools.startsWith(Init.trueSettings.get("Note Skin"), "quant"))
	{
		newNote.determineQuantIndex(newNote.strumTime, newNote);
		newNote.holdHeight = 0.862;

		//
		newNote.loadGraphic(Paths.image("default/skins/quant/pixel/HOLD_quants", 'data/notetypes'), true, 17, 6);
		newNote.animation.add('hold', [0 + (newNote.noteQuant * 4)]);
		newNote.animation.add('holdend', [1 + (newNote.noteQuant * 4)]);
		newNote.animation.add('rollhold', [2 + (newNote.noteQuant * 4)]);
		newNote.animation.add('rollend', [3 + (newNote.noteQuant * 4)]);

		newNote.playAnim('holdend');
		if (newNote.prevNote != null && newNote.prevNote.isSustainNote)
			newNote.prevNote.playAnim('hold');
	}
	else
	{
		newNote.loadGraphic(Paths.image("default/skins/default/pixel/HOLD_assets", 'data/notetypes'), true, 7, 6);
		newNote.animation.add(Receptor.colors[newNote.noteData] + 'holdend', [pixelData[newNote.noteData]]);
		newNote.animation.add(Receptor.colors[newNote.noteData] + 'hold', [pixelData[newNote.noteData] - 4]);
		newNote.animation.play(Receptor.colors[newNote.noteData] + 'holdend');
	}

	newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
	newNote.antialiasing = false;
	newNote.updateHitbox();
}

function generateSplash(noteSplash, noteData)
{
	noteSplash.loadGraphic(Paths.image("default/skins/default/pixel/noteSplashes", 'data/notetypes'), true, 34, 34);
	noteSplash.animation.add('anim1', [noteData, 4 + noteData, 8 + noteData, 12 + noteData], 24, false);
	noteSplash.animation.add('anim2', [16 + noteData, 20 + noteData, 24 + noteData, 28 + noteData], 24, false);
	noteSplash.animation.play('anim1');
	noteSplash.addOffset('anim1', -60, -35);
	noteSplash.addOffset('anim2', -60, -35);
	noteSplash.setGraphicSize(Std.int(noteSplash.width * PlayState.daPixelZoom));

	noteSplash.playAnim('anim' + FlxG.random.int(1, 2));
	noteSplash.alpha = Init.trueSettings.get("Splash Opacity") * 0.01;
}

function getSkinPath(skin:String, path:String):String
{
	var noteSkin = Init.trueSettings.get("Note Skin");
	return ForeverTools.returnSkinAsset(skin, "pixel", noteSkin, 'default/skins', path);
}
