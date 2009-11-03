package
{
	import flash.display.DisplayObject;
	import flash.net.*;
	import flash.events.*;
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import flash.errors.*;

	public class TargetLoad extends Loader
	{
		var callObj:Object;
		var httpStatusType:String;
		var objectName:String;
		
		public function TargetLoad(callObj_p:Object):void
		{
			super();
			objectName
			this.callObj=callObj_p;
			configureListeners(this);
		}
		
		public function loadItem(item:String)
		{
			objectName = item;
			try
			{
				load(new URLRequest(item));
			}
			catch(e:Error)
			{
				trace("caught or naught?");
				trace(e.getStackTrace());
			}
		}

        private function configureListeners(dispatcher:Loader):void {
            dispatcher.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.contentLoaderInfo.addEventListener(Event.OPEN, openHandler);
            dispatcher.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        private function completeHandler(event:Event):void {
            var content:Object = event.target.content;
            trace("completeHandler: " + content + objectName);
			unload();
			callObj.onData(content);
			objectName = "";
        }

        private function openHandler(event:Event):void {
            trace("openHandler: " + event + " for object " + objectName);
        }

        private function progressHandler(event:ProgressEvent):void {
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal + " of " + objectName);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event + " for " + objectName);
//            objectName = "";
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event + " for object " + objectName);
        }
		
		public function onData(src:String):void
		{
			callObj.onData(src);
//            objectName = "";
		}
		
		public function onHTTPStatus(httpStatus:Number):void
		{
			if(httpStatus < 100) {
				this.httpStatusType = "flashError";
			}
			else if(httpStatus < 200) {
				this.httpStatusType = "informational";
			}
			else if(httpStatus < 300) {
				this.httpStatusType = "successful";
			}
			else if(httpStatus < 400) {
				this.httpStatusType = "redirection";
			}
			else if(httpStatus < 500) {
				this.httpStatusType = "clientError";
			}
			else if(httpStatus < 600) {
				this.httpStatusType = "serverError";
			}
		}
	}
}// package ThreeDCanvas 3DEngine