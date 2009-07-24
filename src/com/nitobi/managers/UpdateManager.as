package com.nitobi.managers

{
	import flash.desktop.NativeApplication;
	import flash.desktop.Updater;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;

	public class UpdateManager extends EventDispatcher
	{
		// retrieved from application, used for comparison with latestVersion
		private var _currentVersion:String;
		
		// retrieved from server (xml) to be compared with currentVersion
		private var _latestVersion:String;
		
		// used internally for downloading update
		private var _urlStream:URLStream;
		
		// used internally for downloading update
		private var _fileData:ByteArray;
		
		// location where the lastest air installation will be stored on the user's machine
		// this path is relative to 'applicationStorageDirectory' which may vary from machine to machine
		private var _downloadedFilePath:String = "PhoneGap Simulator.air";
		
		// contains the full server path to the new air installation
		private var _updateInstallUrl:String;
		
		public static var EVENT_UPDATE_AVAILABLE:String = "update_available";
		public static var EVENT_UPDATE_READY:String = "update_ready";
		
		/* This is a sample of the xml for version listings
		
			<?xml version="1.0" encoding="utf-8"?>
			<versions>
				<version path="http://localhost/content/air/OverlayTV.air">0.0.1945</version>
			</versions>
		*/
		public function UpdateManager(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function checkForUpdate(updateUrl:String):void
		{
			var loader:URLLoader = new URLLoader();       
	        
	        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
	        loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleHttpStatus);
	        loader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
	        loader.addEventListener(Event.COMPLETE, handleXmlLoadComplete);

			var request: URLRequest = new URLRequest();
	            request.url = updateUrl;
            	request.requestHeaders.push(new URLRequestHeader("pragma", "no-cache"));

            loader.load(request);
		}
		
		private function handleSecurityError(evt:SecurityErrorEvent):void
		{
			trace("UpdateManager::SECURITY_ERROR : " + evt.text);
			// TODO: Deal with this ...
		}
		
		private function handleHttpStatus(evt:HTTPStatusEvent):void	
		{
			trace("UpdateManager::HTTP_STATUS : " + evt.status);
			// TODO: Deal with this ...
		}
		
		private function handleIOError(evt:IOErrorEvent):void	
		{
			trace("UpdateManager::IO_ERROR : " + evt.text);
			// TODO: Deal with this ...
		}
		
		private function handleXmlLoadComplete(evt:Event):void
		{
			var xData:XML = new XML(evt.target.data);
			latestVersion = String(xData.version[0]);
			
			if(isUpdateAvailable)
			{
				trace("In UpdateManager::isUpdateAvailable is true");
				_updateInstallUrl = String(xData.version[0].@path);
				dispatchEvent(new Event(EVENT_UPDATE_AVAILABLE));
			}
		}
		
		/**
		 * Does a compare of the currently installed version and what the server is reporting as the latest version
		 */
		protected function get isUpdateAvailable():Boolean
		{
			return ( currentVersion.toLowerCase() < latestVersion.toLowerCase() );
		}
		
		/**
		 * Downloads the new AIR file to the users machine
		 * an event will be fired when the download has completed.
		*/
		public function downloadUpdate():void
		{
			_urlStream = new URLStream();
			_fileData = new ByteArray();
			_urlStream.addEventListener(Event.COMPLETE, loaded);
			_urlStream.load(new URLRequest(_updateInstallUrl));
		}


		/** 
		 * the url stream has been filled with the bytes of the update file
		 */
		protected function loaded(event:Event):void 
		{
		    _urlStream.readBytes(_fileData, 0, _urlStream.bytesAvailable);
		    writeUpdatedAirFile();
		}
		
		/**
		 * Helper to write the file bytes to the local file system
		 */
		protected function writeUpdatedAirFile():void 
		{
		    var file:File = File.applicationStorageDirectory.resolvePath(downloadedFilePath);
		    var fileStream:FileStream = new FileStream();
		    fileStream.addEventListener(Event.CLOSE, fileClosed);
		    fileStream.openAsync(file, FileMode.WRITE);
		    fileStream.writeBytes(_fileData, 0, _fileData.length);
		    fileStream.close();
		} 
		
		/**
		 * Signifies that the entire downloaded update has been written to the local file system
		 */
		protected function fileClosed(event:Event):void 
		{
		    this.dispatchEvent(new Event(EVENT_UPDATE_READY));
		}
		
		/**
		 * Presumably called after the user has agreed or at least been informed that the update
		 * is downloaded and ready to rock!
		 */
		public function installUpdate():void
		{
			try
			{
				var airFile:File = File.applicationStorageDirectory.resolvePath(downloadedFilePath);
				var updater:Updater = new Updater();
				updater.update(airFile, latestVersion);
			}
			catch(err:Error)
			{
				trace("Install is not supported if running from IDE");
			}
		}
		
		public function get latestVersion():String
		{
			return this._latestVersion
		}
		
		public function set latestVersion(str:String):void
		{
			this._latestVersion = str;
		}
		
		public function get currentVersion():String
		{
			if(this._currentVersion == null)
			{
				var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
				var ns:Namespace = appXml.namespace();
				this._currentVersion = appXml.ns::version[0];
			}
			return this._currentVersion;
		}
		
		public function get downloadedFilePath():String
		{
			return _downloadedFilePath;
		}
		
	}
}