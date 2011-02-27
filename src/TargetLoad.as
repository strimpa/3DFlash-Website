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
	import ThreeDPack.Polygon;

	public class TargetLoad extends Loader
	{
		var callObj:Object;
		var httpStatusType:String;
		var objectName:String;
		var childLoadingStructs:Array;
		
		public function TargetLoad(callObj_p:Object):void
		{
			super();
			this.callObj=callObj_p;
			childLoadingStructs = new Array();
			configureListeners(this.contentLoaderInfo, "TargetLoad");
			this.name = "TargetLoad";
		}
		
		public function loadItem(item:String):void
		{
			objectName = item;
			try
			{
				load(new URLRequest(item));
				trace("loadItem():"+objectName);
				//trace("childLoadingStructs.length:"+childLoadingStructs.length);
				registerQueueTuple(contentLoaderInfo, item);
			}
			catch(e:Error)
			{
				trace(e.getStackTrace());
			}
		}

        public function configureListeners(dispatcher:LoaderInfo, loaderString:String, isChildQueue:Boolean = false, owner:Polygon = undefined):void {
			if (isChildQueue)
			{
				dispatcher.addEventListener(Event.COMPLETE, completeChildHandler);
				registerQueueTuple(dispatcher, loaderString, owner);
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
       }
	   
	    public function registerQueueTuple(eventTarget:LoaderInfo, name:String, owner:Polygon=undefined ):void
		{
			childLoadingStructs.push(new LoadingStruct(eventTarget, name, owner));
			ThreeDApp.loader.registerLoadingItem(name);
		}
		
		public function findLoadingItem(eventTarget:LoaderInfo, del:Boolean=false):LoadingStruct
		{
			var index:uint = 0;
			for each(var fls:LoadingStruct in childLoadingStructs)
			{
				if(fls.myInfo = eventTarget)
				{
					if (del)
						childLoadingStructs.splice(index, 1);
					return fls;
				}
				index++;
			}
			return undefined;
		}
	    public function unRegisterQueueTuple(eventTarget:LoaderInfo):void
		{
			var fls:LoadingStruct = findLoadingItem(eventTarget, true)
			ThreeDApp.loader.unRegisterLoadingItem(fls.myName);
			fls.deleteOwnerRef();
		}

        private function completeHandler(event:Event):void {
            var content:Object = event.target.content;
//            trace("completeHandler: " + content + objectName);
			unload();
			unRegisterQueueTuple(event.target as LoaderInfo);
			callObj.onData(content);
			objectName = "";
        }

		private function completeChildHandler(event:Event):void
		{
			unRegisterQueueTuple(event.target as LoaderInfo);
//			trace("childLoadingStructs.length:"+childLoadingStructs.length);
		}

        private function openHandler(event:Event):void {
 			var fls:LoadingStruct = findLoadingItem(event.currentTarget as LoaderInfo);
//			trace("openHandler: " + event + " for object " + fls.myName);
        }

        private function progressHandler(event:ProgressEvent):void {
			var fls:LoadingStruct = findLoadingItem(event.currentTarget as LoaderInfo);
			ThreeDApp.loader.updateProgress(fls.myName, event.bytesLoaded/event.bytesTotal);
//            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal + " of " +fls.myName);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
//            trace("securityErrorHandler: " + event + " for " + objectName);
//            objectName = "";
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
 //           trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
//            trace("ioErrorHandler: " + event + " for object " + objectName);
            var content:Object = null;// event.target.content;
			unload();
			unRegisterQueueTuple(event.target as LoaderInfo);
			callObj.onData(content);
			objectName = "";
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