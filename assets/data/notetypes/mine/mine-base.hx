function generateNote(newNote)
{
	var stringSect = Receptor.actions[newNote.noteData];
	var framesArg:String = 'mines';

	newNote.loadGraphic(Paths.image('mine/skins/base/mines', 'data/notetypes'), true, 133, 128);
	newNote.animation.add(stringSect + 'Scroll', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 12);
	newNote.animation.play(stringSect + 'Scroll');

	newNote.isMine = true;
	newNote.noteSuffix = "miss";

	newNote.setGraphicSize(Std.int(newNote.width * 0.8));
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
