package
{
	import flash.net.*;
	import flash.events.*;

	public class TargetLoadVars extends URLLoader
	{
		var callObj:Object;
		var httpStatusType:String;
		var objectName:String;
		
		public function TargetLoadVars(callObj_p:Object):void
		{
			super();
			objectName = "";
			this.callObj=callObj_p;
			configureListeners(this);
		}
		
		public function loadItem(item:String)
		{
			objectName = item;
			load(new URLRequest("http://localhost/website/3DEngine/bin/"+item));
		}

        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
//            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
        }

        private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            trace("completeHandler: " + " for object " + objectName);// + loader.data);
    		
    		callObj.onData(loader.data);
//            var vars:URLVariables = new URLVariables(loader.data);
//            trace("The answer is " + vars.answer);
			objectName = "";
        }

        private function openHandler(event:Event):void {
            trace("openHandler: " + event + " for object " + objectName);
        }

        private function progressHandler(event:ProgressEvent):void {
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal + " for object " + objectName);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event + " for object " + objectName);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event + " for object " + objectName);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event + " for object " + objectName);
			event.stopPropagation();
        }
		
		public function onData(src:String):void
		{
			callObj.onData(src);
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