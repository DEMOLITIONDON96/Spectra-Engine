package base.system;

//taken from Wednesday Infidelity cus lunar allowed it lmao !! (https://twitter.com/lunarcleint/status/1573550933530681344)
#if OnWindows
class CppAPI
{
	#if cpp
	public static function obtainRAM():Int
	{
		return WindowsData.obtainRAM();
	}

	public static function darkMode()
	{
		WindowsData.setWindowColorMode(DARK);

		// thank you memehovy for helping me fixing this love you no homo
        lime.app.Application.current.window.borderless = true;
		lime.app.Application.current.window.borderless = false;
	}

	public static function lightMode()
	{
		WindowsData.setWindowColorMode(LIGHT);
	}

    public static function sendNotification(title:String, desc:String)
    {
        WindowsSystem.sendNotification(title, desc);
    }

    public static function setWindowIcon(file:String)
    {
        lime.app.Application.current.window.setIcon(lime.graphics.Image.fromFile('${Paths.image('appIcons/$file')}'));
    }
	#end
}
#end