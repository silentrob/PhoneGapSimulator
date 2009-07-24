package com.nitobi
{
    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.StageScaleMode;
    import flash.geom.Rectangle;
    import flash.html.HTMLHost;
    import flash.html.HTMLLoader;
    import flash.text.TextField;

    public class CustomHost extends HTMLHost
    {
        import flash.html.*;
        
        [Bindable]
        public var statusField:TextField;
        
        public function CustomHost(defaultBehaviors:Boolean=true)
        {
            super(defaultBehaviors);
        }
        
        override public function windowClose():void
        {
            //htmlLoader.stage.window.close();
        }
        
        override public function createWindow(windowCreateOptions:HTMLWindowCreateOptions):HTMLLoader
        {
            var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
            var window:NativeWindow = new NativeWindow(initOptions);
            window.visible = true;
            var htmlLoader2:HTMLLoader = new HTMLLoader();
            htmlLoader2.width = window.width;
            htmlLoader2.height = window.height;
            window.stage.scaleMode = StageScaleMode.NO_SCALE;
            window.stage.addChild(htmlLoader2);
            return htmlLoader2;
        }
        override public function updateLocation(locationURL:String):void
        {
            trace(locationURL);
        }        
        override public function set windowRect(value:Rectangle):void
        {
            htmlLoader.stage.nativeWindow.bounds = value;
        }
        override public function updateStatus(status:String):void
        {
            statusField.text = status;
        }        
        override public function updateTitle(title:String):void
        {
            htmlLoader.stage.nativeWindow.title = title + "- Example Application";
        }
        override public function windowBlur():void
        {
            htmlLoader.alpha = 0.5;
        }
        override public function windowFocus():void
        {
            htmlLoader.alpha = 1;
        }
    }
}