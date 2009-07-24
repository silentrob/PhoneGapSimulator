package com.nitobi
{
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	
	public class Const
	{
		// General
		public static const SKIN_XML_URL:String = 'settings.xml';
		public static const FILTER_DROPSHADOW:DropShadowFilter = new DropShadowFilter(5, 90, 0x000000, 0.5, 15, 15);
		public static const GLOW_FILTER:GlowFilter = new GlowFilter(0x66d0dd, 0.82, 8, 8, 2, 2);
		
		// Menu
		public static const MENU_EXIT:String = 'Exit';
		public static const MENU_URL:String = 'Change URL';
		public static const MENU_DEBUG:String = 'Debug';
		public static const MENU_RELOAD:String = 'Reload';
		public static const MENU_DEMO:String = 'Demo';
		
		// Time
		public static const DUR_ROTATION:Number = 0.25;
		public static const DUR_RESET_ROTATION:Number = 0.75;
		
		//URLS
		public static const NITOBI_URL:String = 'http://www.nitobi.com';
		public static const PHONEGAP_URL:String = 'http://www.phonegap.com';
		
		// Sound
		[Embed(source="/assets/sound/beep.mp3")]
		public static const AUDIO_BEEP:Class;
		
	}
}