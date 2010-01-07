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
		var childLoaders:Array;
		var childNames:Array
		
		public function TargetLoad(callObj_p:Object):void
		{
			super();
			this.callObj=callObj_p;
			childLoaders = new Array();
			childNames = new Array();
			configureListeners(this.contentLoaderInfo, "TargetLoad");
			this.name = "TargetLoad";
		}
		
		public function loadItem(item:String)
		{
			objectName = item;
			try
			{
				load(new URLRequest(item));
				trace("loadItem():"+objectName);
				trace("childLoaders.length:"+childLoaders.length);
				registerQueueTuple(contentLoaderInfo, item);
			}
			catch(e:Error)
			{
				trace("caught or naught?");
				trace(e.getStackTrace());
			}
		}

        public function configureListeners(dispatcher:LoaderInfo, loaderString:String, isChildQueue:Boolean = false):void {
			if (isChildQueue)
			{
				dispatcher.addEventListener(Event.COMPLETE, completeChildHandler);
				registerQueueTuple(dispatcher, loaderString);
			}
			else
			{
				dispatcher.addEventListener(Event.COMPLETE, completeHandler);
			}
				
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			trace("childLoaders.length:"+childLoaders.length);
       }
	   
	    public function registerQueueTuple(eventTarget:LoaderInfo, name:String)
		{
			childLoaders.push(eventTarget);
			childNames.push(name);
			ThreeDApp.loader.registerLoadingItem(name);
		}
	    public function unRegisterQueueTuple(eventTarget:LoaderInfo)
		{
			var index:uint = childLoaders.indexOf(eventTarget);
			ThreeDApp.loader.unRegisterLoadingItem(childNames[index]);
			childLoaders.splice(index, 1);
			childNames.splice(index, 1);
		}

        private function completeHandler(event:Event):void {
            var content:Object = event.target.content;
            trace("completeHandler: " + content + objectName);
			unload();
			unRegisterQueueTuple(event.target as LoaderInfo);
			callObj.onData(content);
			objectName = "";
        }

		private function completeChildHandler(event:Event):void
		{
			var index:uint = childLoaders.indexOf(event.currentTarget);
			unRegisterQueueTuple(event.target as LoaderInfo);
			trace("childLoaders.length:"+childLoaders.length);
		}

        private function openHandler(event:Event):void {
 			var index:uint = childLoaders.indexOf(event.currentTarget);
			trace(childNames);
			trace(childLoaders);
           trace("openHandler: " + event + " for object " + childNames[index]);
        }

        private function progressHandler(event:ProgressEvent):void {
			var index:uint = childLoaders.indexOf(event.currentTarget);
			ThreeDApp.loader.updateProgress(childNames[index], event.bytesLoaded/event.bytesTotal);
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal + " of " +index+ ", " + childNames[index]);
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