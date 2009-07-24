package com.nitobi.event
{
	import flash.events.Event;
	
	public class OrientationEvent extends Event
	{
		
		public static const ORIENTATION_CHANGED:String = 'OrientationChanged';
		
		
		public var data:*;
		
		public function OrientationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}