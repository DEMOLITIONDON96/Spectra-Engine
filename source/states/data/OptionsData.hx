package states.data;

typedef GroupData =
{
	var name:String;
	var type:String;
	@:optional var description:String;
}

/**
 * Stores Option Category Contents;
 * and data associated with it;
 */
class OptionsData
{
	/* == Preferences Group == */
	public static var preferences:Array<GroupData> = [
		//
		{name: "Gameplay Settings", type: "divider"},
		//
		{name: 'Downscroll', type: "option"},
		{name: 'Centered Notefield', type: "option"},
		{name: 'Ghost Tapping', type: "option"},
		//
		{name: "Timing Windows", type: "divider"},
		{name: "Timing Preset", type: "option"},
		/*
			{name: "Sick Timing Window", type: "option"},
			{name: "Good Timing Window", type: "option"},
			{name: "Bad Timing Window", type: "option"},
			{name: "Shit Timing Window", type: "option"},
		 */
		//
		{name: "Meta Settings", type: "divider"},
		//
		{name: 'Auto Pause', type: "option"},
		{name: 'Skip Text', type: "option"},
		{name: 'FPS Counter', type: "option"},
		{name: 'Memory Counter', type: "option"},
		{name: 'Framerate Cap', type: "option"},
	];

	/* == Accessibility Group == */
	public static var accessibility:Array<GroupData> = [
		//
		{name: "Screen Settings", type: "divider"},
		//
		{name: "Disable Antialiasing", type: "option"},
		{name: "Disable Flashing Lights", type: "option"},
		{name: "Disable Screen Shaders", type: "option"},
		//
		{name: "Motion Settings", type: "divider"},
		//
		{name: "Camera Position", type: "option"},
		{name: "No Camera Note Movement", type: "option"},
		{name: "Reduced Movements", type: "option"},
		//
		{name: "Misc Settings", type: "divider"},
		//
		{name: "Colored Health Bar", type: "option"},
		{name: "Stage Opacity", type: "option"},
		{name: "Filter", type: "option"}
	];

	/* == Visuals Group == */
	public static var visuals:Array<GroupData> = [
		//
		{name: "User Interface", type: "divider"},
		//
		{name: "UI Skin", type: "option"},
		{name: "Note Skin", type: "option"},
		{name: "Clip Style", type: "option"},
		//
		{name: "Note and Holds", type: "divider"},
		//
		{name: "Arrow Opacity", type: "option"},
		{name: "Hold Opacity", type: "option"},
		{name: "Splash Opacity", type: "option"},
		//
		{name: "Judgements and Combo", type: "divider"},
		//
		{name: "Fixed Judgements", type: "option"},
		{name: "Simply Judgements", type: "option"},
		{name: "Judgement Recycling", type: "option"},
		{name: "Display Miss Judgement", type: "option"},
		{name: "Display Timings", type: "option"},
		//
		{name: "Text Display", type: "divider"},
		//
		{name: "Counter", type: "option"},
		{name: 'Display Accuracy', type: "option"},
		{name: "Accuracy Hightlight", type: "option"},
	];
}
