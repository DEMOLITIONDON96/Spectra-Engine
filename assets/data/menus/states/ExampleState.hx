import states.menus.MainMenu;

function create() {}

function postCreate()
{
	updatePresence('EXAMPLE MENU', 'Scriptable State');

	var bg:FlxSprite = new FlxSprite();
	bg.loadGraphic(Paths.image('menus/chart/bg'));
	add(bg);

	logTrace('Hello, this is an Example State, made with HScript!', 3);
}

function update(elapsed:Float)
{
	if (Controls.getPressEvent("back"))
		Main.switchState(this, new MainMenu());
}

function postUpdate(elapsed:Float) {}
function beatHit(curBeat:Int) {}
function stepHit(curStep:Int) {}
function onFocus() {}
function onFocusLost() {}
function destroy() {}
function openSubState() {}
function closeSubState() {}
