function generateNote(newNote)
{
	var framesArg:String = 'mines';

	newNote.loadGraphic(Paths.image('mine/skins/pixel/mines', 'data/notetypes'), true, 17, 17);
	newNote.animation.add(Receptor.actions[newNote.noteData] + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7], 12);
	newNote.animation.play(stringSect + 'Scroll');

	newNote.isMine = true;
	newNote.noteSuffix = "miss";
	newNote.antialiasing = false;

	newNote.setGraphicSize(Std.int(newNote.width * PlayState.daPixelZoom));
	newNote.updateHitbox();
}

function generateSplash(splashNote, noteData)
	splashNote.kill();

function generateSustain(newNote)
	newNote.kill();

function onHit(newNote)
{
	PlayState.health -= 0.0875;
	game.decreaseCombo(true);
}
