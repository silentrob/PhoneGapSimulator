package com.nitobi.event
{
	import flash.events.Event;
	
	public class MarkerUpdateEvent extends Event
	{
		
		public static const MARKER_MOVED:String = 'MarkerMoved';
		
		
		public var data:*;
		
		public function MarkerUpdateEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}