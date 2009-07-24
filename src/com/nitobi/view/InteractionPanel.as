package com.nitobi.view
{
	import com.nitobi.PhoneGapSimulatorApp;
	import com.nitobi.event.OrientationEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.managers.CursorManager;
	
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.primitives.Plane;
	

	public class InteractionPanel extends PaperBase
	{
		public var group:DisplayObject3D;
		
		private var mouseDrag:Boolean = false;
		
		[Bindable]
		private var app:PhoneGapSimulatorApp;
		
		private var mouseOffset:Point = new Point;
		
		private const SPACE_WIDTH:Number = DebugPanel.WINDOW_WIDTH;
		private const SPACE_HEIGHT:Number = DebugPanel.WINDOW_HEIGHT - DebugPanel.BUTTON_BAR_HEIGHT - 34;
		
		private const IPHONE_WIDTH:int = 120;
		private const IPHONE_HEIGHT:int = 225;
		private const IPHONE_DEPTH:int = 24;
		
		[Embed(source="assets/iphone3d/front.png")]
		private static const SKIN_FRONT:Class;
		
		[Embed(source="assets/iphone3d/left.png")]
		private static const SKIN_LEFT:Class;
		
		[Embed(source="assets/iphone3d/right.png")]
		private static const SKIN_RIGHT:Class;
		
		[Embed(source="assets/iphone3d/back.png")]
		private static const SKIN_BACK:Class;
		
		[Embed(source="assets/iphone3d/top.png")]
		private static const SKIN_TOP:Class;
		
		[Embed(source="assets/iphone3d/bottom.png")]
		private static const SKIN_BOTTOM:Class;
		
		private var lastRotationX:Number = 0;
		private var lastRotationY:Number = 0;
		
		
		public function InteractionPanel():void
		{
			init(SPACE_WIDTH, SPACE_HEIGHT);
			this.y = 1;
			create3DObject();
			useHandCursor = buttonMode = true;
			CursorManager
			addEventListener(Event.ADDED_TO_STAGE, addEvents)
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, SPACE_WIDTH, SPACE_HEIGHT);
			
		}
		
		private function addEvents(e:Event):void
		{
			app = PhoneGapSimulatorApp.getInstance();
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			app.addEventListener(OrientationEvent.ORIENTATION_CHANGED, onOrientationChanged);
		}
		
		private function onOrientationChanged(e:OrientationEvent):void
		{
			var rot:Number = e.data;
			group.rotationZ = rot;
		}
		
		private function onDown(e:MouseEvent):void
		{
			trace(e.localX, e.localY);
			mouseOffset = new Point(mouseX, mouseY);
			mouseDrag = true;
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			mouseDrag = false;
			lastRotationX = group.rotationX;
			lastRotationY = group.rotationY;
		}
		
		private function create3DObject():void
		{
			group = new DisplayObject3D;
			
			var w:int = IPHONE_WIDTH;
			var h:int = IPHONE_HEIGHT;
			var d:int = IPHONE_DEPTH;
			var offsetX:int = 10;
			var offsetY:int = 10;
			var offsetZ:int = -7;
			var offsetBack:int = 10;
			
			var front:Plane = createPlane(SKIN_FRONT, w, h, {x:0, y:0, z:offsetZ}, {x:0, y:0, z:0});
			var back:Plane = createPlane(SKIN_BACK, w, h, {x:0, y:0, z:offsetBack}, {x:0, y:180, z:0});
			var left:Plane = createPlane(SKIN_LEFT, d, h, {x:-w/2+offsetX, y:0, z:0}, {x:0, y:110, z:0});
			var right:Plane = createPlane(SKIN_RIGHT, d, h, {x:w/2-offsetX, y:0, z:0}, {x:0, y:-110, z:0});
			var top:Plane = createPlane(SKIN_TOP, w, d, {x:0, y:h/2-offsetY, z:0}, {x:110, y:0, z:0});
			var bottom:Plane = createPlane(SKIN_BOTTOM, w, d, {x:0, y:-h/2+offsetY, z:0}, {x:-110, y:0, z:0});
			
			function onClick(e:MouseEvent):void
			{
				var container:Sprite = e.target as Sprite;
				container.alpha = Math.random();
				
			}
			
			group.z = -500;
			default_scene.addChild(group);
			
			function createPlane(skin:Class, w:int, h:int, locate:Object, rotate:Object):Plane
			{
				var s:int = 2;
				var bm:Bitmap = new skin();
				var mat:BitmapMaterial = new BitmapMaterial( bm.bitmapData );
				var plane:Plane = new Plane(mat, w, h, s);
				plane.x = locate.x; plane.y = locate.y; plane.z = locate.z;
				plane.rotationX = rotate.x; plane.rotationY = rotate.y; plane.rotationZ = rotate.z;
				
				group.addChild(plane);
						
				return(plane);
			}
		}
		
		override public function processFrame():void
		{
			if (mouseDrag)
			{
				//if (lastRotationX > 180) lastRotationX = -(lastRotationX-180);
				//if (lastRotationY > 180) lastRotationY = -(lastRotationY-180);
				
				group.rotationX = -(( (mouseY - mouseOffset.y ) / SPACE_HEIGHT) * 180) + lastRotationX;
				group.rotationY = -(( (mouseX - mouseOffset.x  ) / SPACE_WIDTH) * 180) + lastRotationY;
				
				if (group.rotationX > 360) group.rotationX = 0 + (group.rotationX - 360);
				else if (group.rotationX < -360) group.rotationX = 0 - (group.rotationX + 360);
				
				if (group.rotationY > 360) group.rotationY = 0 + (group.rotationY - 360);
				else if (group.rotationY < -360) group.rotationY = 0 - (group.rotationY + 360);
				
				if (group.rotationX > 180) group.rotationX = -(360-group.rotationX);
				if (group.rotationX < -180) group.rotationX = 360+group.rotationX;
				if (group.rotationY > 180) group.rotationY = -(360-group.rotationY);
				if (group.rotationY < -180) group.rotationY = 360+group.rotationY;
				
				app.rotationX = group.rotationX;
				app.rotationY = group.rotationY;
			}
		}
		
		
	}
}