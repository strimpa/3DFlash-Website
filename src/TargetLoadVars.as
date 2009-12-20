package
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.*;
	import flash.events.*;
	import flash.text.TextField;

	public class TargetLoadVars extends URLLoader
	{
		var callObj:Object;
		var httpStatusType:String;
		var objectName:String;
		var checkTextField:TextField;
		var pictureIds:Array = ["pic1", "pic2", "pic3", "pic4", "pic5", "pic6", "pic7", "pic8", "pic9"];
		var tempString:String;
		
		public function TargetLoadVars(callObj_p:Object):void
		{
			super();
			objectName = "";
			this.callObj=callObj_p;
			configureListeners(this);
			checkTextField = new TextField();
		}
		
		public function loadItem(item:String)
		{
			objectName = item;
			load(new URLRequest("http://www.gunnardroege.de/"+item));//"http://www.gunnardroege.de/3DEngine/bin/"+item)); //http://localhost/website/3DEngine/bin
		}

        private function configureListeners(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
        }

        private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            trace("completeHandler: " + " for object " + objectName);// + loader.data);
			var theString:String = loader.data as String;
			trace("check for other loaders inside data.");
			checkTextField.htmlText = theString;
			objectName = "";
			var picLoader:TargetLoad = ContentManager.getLoader();
			var picsFound:Boolean = false;
			for each(var picId in pictureIds)
			{
				var ref:DisplayObject = checkTextField.getImageReference(picId);
				if(ref)
					trace("got pic: " + picId);
				if (ref && (ref is Loader))
				{
					picsFound = true;
					var theLoader:Loader = (ref as Loader);
					theLoader.name = picId;
					picLoader.configureListeners(theLoader.contentLoaderInfo, picId, true);
				}
			}
			
			if (picsFound)
			{
				trace("childLoaders.length:" + picLoader.childLoaders.length);
				tempString = new String(theString);
			}
			else
			{
				trace("no child loaders");
				callObj.onData(theString);
			}
        }

		public function childLoadComplete()
		{
			trace("childLoadComplete() ");
			callObj.onData(tempString);
			checkTextField.htmlText = "";
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