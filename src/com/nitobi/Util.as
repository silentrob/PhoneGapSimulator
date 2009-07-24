package com.nitobi
{
	import com.nitobi.event.MaskEvent;
	
	import flash.display.NativeMenuItem;
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.WindowedApplication;
	
	public class Util
	{
		
		public static function parseXML(xml:XML):void
		{
			var model:PhoneGapSimulatorApp = PhoneGapSimulatorApp.getInstance();
			
			for (var i:int = 0; i < xml.children().length(); i++)
			{
				var child:XML = xml.children()[i];
				
				if (child.name() == 'skin')
				{
					var name:String = child.children().toString();
					var id:String = child.@id;
					var skinId:String = child.@skin;
					
					var size:Array = parseArray( child.@size.split(',') );
					var screen:Array = parseArray( child.@screen.split(',') );
					var button:Array = parseArray( child.@button.split(',') );					
					var rotationString:String = child.@rotation;
					var rotation:Boolean = true;
					if (rotationString == 'false') rotation = false;
					
					var header:Number = parseFloat(child.@header);
					var radius:Number = parseFloat(child.@radius);
					var scale:Number = parseFloat(child.@scale) || 1;
					
					function parseArray(ar:Array):Array
					{
						var temp:Array = [];
						
						for each (var item:String in ar)
						{
							temp.push( parseInt(item) );
						}
						
						return(temp);
					}
					
					model.skinData['SKIN_' + id] = skinId;
					model.skinData['MENU_' + id] = name;
					model.menuIdCollection.push(name);
					model.skinData['SIZE_' + id] = new Point(size[0], size[1]);
					model.skinData['SCREEN_' + id] = new Rectangle(screen[0], screen[1], screen[2], screen[3]);
					model.skinData['BUTTON_' + id] = new Rectangle(button[0], button[1], button[2], button[3]);
					model.skinData['ROTATION_' + id] = rotation;
					model.skinData['HEADER_' + id] = header;
					model.skinData['RADIUS_' + id] = radius;
					model.skinData['SCALE_' + id] = scale;
				}
				else if (child.name() == 'url')
				{
					//model.currentURL = child.children().toString();
				}
				else if (child.name() == 'useragent')
				{
					model.userAgent = child.children().toString();
				}
			}
		}
		
		public static function centerWindow(app:WindowedApplication):void
		{
			var rect:Rectangle = Screen.mainScreen.visibleBounds;
			app.nativeWindow.x = rect.width/2 - app.width/2;
			app.nativeWindow.y = rect.height/2 - app.height/2;
			
			if (app.nativeWindow.y < 0)
			{
				app.nativeWindow.y = rect.top ;
			}
		}
		
		public static function changeSkin(simulator:PhoneGapSimulator, selectedSkinString:String):void
		{
			var app:PhoneGapSimulatorApp = PhoneGapSimulatorApp.getInstance();
			
			for each (var item:NativeMenuItem in app.menuSkin.items)
			{
				if (item.label == selectedSkinString)
				{
					item.checked = true;
				}
				else 
				{
					item.checked = false;
				}
			}
			
			var id:String = selectedSkinString.toUpperCase().replace(' ', '_');
			
			app.skinString = app.skinData['SKIN_' + id];
			
			app.rotationEnabled = app.skinData['ROTATION_' + id];
			
			app.headerHeight = app.skinData['HEADER_' + id];
			
			app.cornerRadius = app.skinData['RADIUS_' + id];
			
			var size:Point = app.skinData['SIZE_' + id];
			app.width = size.x;
			app.height = size.y;
			app.edgeR = Math.atan( (app.height/2) / (app.width/2) );
			app.edgeL = (app.width/2) / Math.cos(app.edgeR);
			app.edgeD = (180/Math.PI)*app.edgeR;
			
			var screen:Rectangle = app.skinData['SCREEN_' + id];
			app.screenX= screen.x;
			app.screenY = screen.y;
			
			var scale:Number = app.skinData['SCALE_' + id];
			app.screenWidth = screen.width;
			app.screenHeight = screen.height;			
			app.screenScale = scale;
			
			var buttonRect:Rectangle = app.skinData['BUTTON_' + id];
			simulator.button.x = buttonRect.x;
			simulator.button.y = buttonRect.y;
			simulator.button.width = buttonRect.width;
			simulator.button.height = buttonRect.height;
			app.rotation = 0;
			
			app.dispatchEvent(new MaskEvent(MaskEvent.REDRAW_MASK));
		}
		
		public static function getWidth(edgeL:Number, rot:Number, edgeD:Number):Number
		{
			if (rot < 90) rot = 180-rot;
			if (rot > 180 && rot < 270) rot = 360- rot;
			var ang:Number = edgeD+rot;
			var n:Number = Math.cos((Math.PI/180)*(ang) )*(edgeL);
			n = n*2;
			
			if (n < 0) n = -n;
			
			//trace(rot, ang, n);
			return(n);
		}
		
		public static function getHeight(edgeL:Number, rot:Number, edgeR:Number):Number
		{
			var n:Number = Math.sin(edgeR + (Math.PI/180)*rot )*(edgeL*2);
			if (n < 0) n = -n;
			return(n);
		}
		
		public static function addRollOverFlowEffect(e:Event):void
		{
			e.target.addEventListener(MouseEvent.ROLL_OUT, out);
			e.target.addEventListener(MouseEvent.ROLL_OVER, over);
			e.target.addEventListener(MouseEvent.MOUSE_DOWN, out);
			e.target.addEventListener(MouseEvent.MOUSE_UP, over);
			
			function out(e:MouseEvent):void
			{
				e.target.filters = [];	
			}
			
			function over(e:MouseEvent):void
			{
				e.target.filters = [Const.GLOW_FILTER];
			}
		}

	}
}