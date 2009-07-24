package com.nitobi.event
{
	import flash.events.Event;
	
	public class VibrateEvent extends Event
	{
		
		public static const VIBRATE_EVENT_START:String = 'vibrateStart';
		
		
		public var data:*;
		
		public function VibrateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}