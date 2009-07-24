package com.nitobi.event
{
	import flash.events.Event;
	
	public class BlinkEvent extends Event
	{
		
		public static const BLINK_START:String = 'blinkStart';
		
		
		public var data:*;
		
		public function BlinkEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}