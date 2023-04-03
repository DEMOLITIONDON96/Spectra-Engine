function generateNote(newNote)
{
	var pixelData:Array<Int> = [4, 5, 6, 7];

	newNote.loadGraphic(Paths.image("instakill/skins/pixel/KILLNOTE_assets", 'data/notetypes'), true, 17, 17);
	newNote.animation.add(Receptor.colors[newNote.noteData] + 'Scroll', [pixelData[newNote.noteData]], 12);
	newNote.animation.play(Receptor.colors[newNote.noteData] + 'Scroll');

	newNote.noteSuffix = "miss";
	newNote.ignoreNote = true;

	newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
	newNote.antialiasing = false;
	newNote.updateHitbox();
}

function generateSplash(splashNote, noteData)
	splashNote.kill();

function generateSustain(newNote)
{
	var pixelData:Array<Int> = [4, 5, 6, 7];
	
	newNote.loadGraphic(Paths.image("instakill/skins/pixel/HOLD_assets", 'data/notetypes'), true, 7, 6);
	newNote.animation.add(Receptor.colors[newNote.noteData] + 'holdend', [pixelData[newNote.noteData]]);
	newNote.animation.add(Receptor.colors[newNote.noteData] + 'hold', [pixelData[newNote.noteData] - 4]);
	newNote.animation.play(Receptor.colors[newNote.noteData] + 'holdend');

	newNote.noteSuffix = "miss";
	newNote.ignoreNote = true;

	newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
	newNote.antialiasing = false;
	newNote.updateHitbox();
}

function onHit(newNote)
{
	if (!newNote.canBeHit)
	{
		PlayState.health -= 0;
	}
	else
	{
		PlayState.health -= 5000;
	}
}
