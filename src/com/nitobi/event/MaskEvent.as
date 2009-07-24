package com.nitobi.event
{
	import flash.events.Event;
	
	public class MaskEvent extends Event
	{
		
		public static const REDRAW_MASK:String = 'redrawMask';
		
		
		public var data:*;
		
		public function MaskEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}

	}
}