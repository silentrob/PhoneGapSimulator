package com.nitobi
{
	import com.google.maps.LatLng;
	import com.nitobi.event.BlinkEvent;
	import com.nitobi.event.MaskEvent;
	import com.nitobi.event.OrientationEvent;
	import com.nitobi.event.VibrateEvent;
	import com.nitobi.managers.UpdateManager;
	import com.nitobi.view.DebugPanel;
	
	import flash.display.NativeMenu;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.HTML;
	
	[Bindable]
	
	public class PhoneGapSimulatorApp extends EventDispatcher
	{
		
		public static const ALLOWED_EXTENSIONS:String = "js|html";
		private static const UPDATE_PATH:String = "http://www.nitobi.com/yohei/phonegap/builds.xml";
		public var updateManager:UpdateManager;
		
		// HTML Related
		public var currentURL:String = '';
		public var userAgent:String = '';
		public var loading:Boolean = true;
		public var host:CustomHost = new CustomHost;
		public var html:HTML;
		
		//Menu Related
		public var menuMain:NativeMenu = new NativeMenu;
		public var menuSkin:NativeMenu = new NativeMenu;
		public var menuIdCollection:Array = [];
		
		// Skin Related
		public var skinString:String;
		public var skinData:Object = {};
		public var horizontalOrientation:Boolean = false;
		private var tempOrientation:Boolean = false;
		public var screenRotation:Number = 0;
		
		// UI Related
		public var width:int = 0;
		public var height:int = 0;
		public var screenX:int = 0;
		public var screenY:int = 0;
		public var screenWidth:int = 320;
		public var screenHeight:int = 480;
		public var screenOffsetX:int = 0;
		public var screenOffsetY:int = 0;
		public var screenScale:Number = 1;
		public var headerHeight:int = 20;
		public var cornerRadius:int = 0;
		
		// Orientation
		private var _rotation:Number = 0;
		public var edgeL:Number = 0;
		public var edgeD:Number = 0;
		public var edgeR:Number = 0;
		
		
		// Interaction
		private var _rotationX:Number = 0;
		private var _rotationY:Number = 0;
		
		// Acceleration
		public var accelerationX:Number = 0;
		public var accelerationY:Number = 0;
		public var accelerationZ:Number = 0;
		
		// Geolocation
		public var latLng:LatLng;
		
		// Component
		private static var instance:PhoneGapSimulatorApp;
		public var debug:DebugPanel = new DebugPanel;
		
		// Debugger related
		public var rotationEnabled:Boolean = true;
		
		
		public function PhoneGapSimulatorApp()
		{
			if( PhoneGapSimulatorApp.instance != null ) 
			{
				throw new Error( "PhoneGapSimulatorModelLocator is a singleton." );
			}
			
			latLng = new LatLng(49.28, -123.12);
			updateManager = new UpdateManager(this);
		}
		
		public function checkForUpdate():void
		{
			updateManager.checkForUpdate(UPDATE_PATH);
		}
		
		
		public static function getInstance():PhoneGapSimulatorApp
		{
			if( PhoneGapSimulatorApp.instance == null ) 
			{
				PhoneGapSimulatorApp.instance = new PhoneGapSimulatorApp();
			}
			
			return PhoneGapSimulatorApp.instance;
		}
		
		public function set rotation(value:Number):void
		{
			_rotation = value;
			if (_rotation > 45 && _rotation <= 135 || _rotation <= -225 && _rotation > -315) 
			{
				horizontalOrientation = true;
				screenRotation = -90;
				screenOffsetY = screenHeight;
				screenOffsetX = 0;
			}
			else if (_rotation < -45 && _rotation >= -135 || _rotation >= 225 && _rotation < 315) 
			{
				horizontalOrientation = true;
				screenRotation = 90;
				screenOffsetX = screenWidth;
				screenOffsetY = 0;
			}
			else if (_rotation > 135 && _rotation < 225 || _rotation < -135 && _rotation > -225)
			{
				horizontalOrientation = false;
				screenRotation = 180;	
				screenOffsetX = screenWidth;
				screenOffsetY = screenHeight;
			}
			else 
			{
				horizontalOrientation = false;
				screenRotation = 0;	
				screenOffsetX = 0;
				screenOffsetY = 0;
			}
			
			var oriEvent:OrientationEvent = new OrientationEvent(OrientationEvent.ORIENTATION_CHANGED);
			oriEvent.data = -_rotation;
			dispatchEvent(oriEvent);

			if (tempOrientation != horizontalOrientation)
			{
				tempOrientation = horizontalOrientation;
				dispatchEvent(new MaskEvent(MaskEvent.REDRAW_MASK));
			}
			
		}
		
		public function get rotation():Number
		{
			return _rotation;
		}
		
		
		// RotationX & RotationY on 3D model
		
		public function set rotationX(value:Number):void
		{
			_rotationX = value;
		}
		
		public function get rotationX():Number
		{
			return _rotationX;
		}
		
		public function set rotationY(value:Number):void
		{
			_rotationY = value;
		}
		
		public function get rotationY():Number
		{
			return _rotationY;
		}
		
		
		// Dom related
		
		private var loadCount:int;
		private var currentLoad:int;
		private var loadOnce:Boolean = false;
		
		public function domInitializer():void
		{
			html.domWindow.console = null;
			// Notification
			if (html.domWindow.navigator && html.domWindow.navigator.notification)
			{
           		html.domWindow.navigator.notification.vibrate = vibrate;
            	html.domWindow.navigator.notification.beep = beep;
            	html.domWindow.navigator.notification.blink = blink;
   			}
   			
   			// Device
   			html.domWindow.Device = {};
   			html.domWindow.Device.platform = skinString;
   			html.domWindow.Device.version = 1.0;
   			html.domWindow.Device.uuid = 'NA';
   			
   			// Geolocation
   			updateLatLng();
   			updateDomAcceleration();
		}
		
		public function checkHeader():void
		{	
			if (loadOnce)
			{
				loadOnce = false;
				return;
			}
			
			domInitializer();
			var len:int = parseInt(html.domWindow.document.getElementsByTagName('script').length);
			var src:String;
			var j:int;
			var len2:int;
			var pass:Boolean;
			var name:String;
			currentLoad = 0;
			
			for (var i:int = 0; i < len; i++)
			{
				src = "";
				pass = true;
				trace(html.domWindow.document.getElementsByTagName('script').item(i).attributes);
				len2 = parseInt(html.domWindow.document.getElementsByTagName('script').item(i).attributes.length)
				
				for (j = 0; j < len2; j++)
				{
					name = html.domWindow.document.getElementsByTagName('script').item(i).attributes[j].nodeName;
					if (name.toLowerCase() == 'src') 
					{
						src = html.domWindow.document.getElementsByTagName('script').item(i).src;
						pass = false;
					}
				}
				
				if (!pass)
				{
					html.domWindow.document.getElementsByTagName('head').item(0).removeChild(
						html.domWindow.document.getElementsByTagName('script').item(i));
					replaceScript(src);
					i--;
					len--;
					loadCount++;
				}
			}
		}
		
		public function reRenderPage():void
		{
			loadOnce = true;
			var temp:String = html.domWindow.document.getElementsByTagName('html').item(0).innerHTML;
			temp = "<html>" + temp + "</html>";
			trace(temp);
			html.domWindow.document = temp;
			//html.htmlLoader.loadString(temp);
			//html.domWindow.document.write(temp);
			domInitializer();
		}
		
		public function replaceScript(scriptURL:String):void
		{
			var fileLocation:String = File.applicationDirectory.nativePath.replace(/\\/g, "/");
			var loader:URLLoader = new URLLoader;
			loader.addEventListener(Event.COMPLETE, handleXHR);
			loader.load(new URLRequest(scriptURL));
		}
		
		private function handleXHR(e:Event):void
		{
			var loader:URLLoader = e.target as URLLoader;
			var script:String = loader.data;
			
			script = script.replace(/document.location = "gap/g, '//document.location = "gap');
			var js:* = html.domWindow.document.createElement('script');    
				js.setAttribute('type', 'text/javascript');
				js.setAttribute('charset', 'utf-8');
				js.text = script;
				html.domWindow.document.getElementsByTagName('head').item(0).appendChild(js);
			checkLoad();
		}
		
		private function checkLoad():void
		{
			currentLoad++;
			if (currentLoad >= loadCount)
			{
				reRenderPage();
			}
		}
		
		
		public function loadFireBug():void
		{
			if (!html.domWindow.firebug)
			{
				var fileLocation:String = File.applicationDirectory.nativePath.replace(/\\/g, "/");
				var js:* = html.domWindow.document.createElement('link');    
				js.setAttribute('rel', 'stylesheet');
   				js.setAttribute('href', 'file://' + fileLocation + '/www/firebug-lite/firebug-lite.css');
				js.setAttribute('type', 'text/css');
				js.setAttribute('charset', 'utf-8');

				html.domWindow.document.getElementsByTagName('head').item(0).appendChild(js);
				
				html.domWindow.document.location = "javascript:var firebug=document.createElement('script');firebug.setAttribute('src','file://" + 
					fileLocation + "/www/firebug-lite/firebug-lite-runtime.js');document.body.appendChild(firebug);(function(){if(window.firebug.version){firebug.init();}else{setTimeout(arguments.callee);}})();void(firebug);";
				//html.domWindow.firebug.env.css = "file:///Users/yoheishimomae/Documents/Flex%20Builder%203/PhoneGap/src/www/firebug-lite/firebug-lite.css";
			} 
			else
			{
				trace(html.domWindow.firebug.visible );
				if (html.domWindow.firebug.visible == false)
				{
					html.domWindow.firebug.win.show();
					html.domWindow.firebug.win.maximize();
				}
				else
				{
					html.domWindow.firebug.win.hide();
				}
			}
		}
		
		
		// Notification
		private var client:*;
		
		public function vibrate(ms:Number=250):void
		{
			var vibeEvent:VibrateEvent = new VibrateEvent(VibrateEvent.VIBRATE_EVENT_START);
			vibeEvent.data = int(ms*0.03);
			dispatchEvent( vibeEvent );
		}
		
		public function beep(count:int=0):void
		{
			var sound:Sound = new Const.AUDIO_BEEP;
			sound.play(0, count);
			html.domWindow.navigator._accelX = accelerationX;
		}
		
		public function blink(count:int=1, color:uint=0xffffff):void
		{
			var blinkEvent:BlinkEvent = new BlinkEvent(BlinkEvent.BLINK_START);
			blinkEvent.data = {color:color, count:count};
			dispatchEvent( blinkEvent );
		}
		
		
		// Geolocation
		public function updateGeolocation(_latLng:LatLng):void
		{
			latLng = _latLng;
			updateLatLng();
		}
		
		public function updateLatLng():void
		{
			html.domWindow.geo = {};
			html.domWindow.geo.lat = latLng.lat();
			html.domWindow.geo.lng = latLng.lng();	
		}
		
		
		// Acceleration
		public function updateDomAcceleration():void
		{
			html.domWindow._accel = {};
			html.domWindow._accel.x = accelerationX;
			html.domWindow._accel.y = accelerationY;
			html.domWindow._accel.z = accelerationZ;
		}
		
		

	}
}