package
{
	import flash.external.ExternalInterface;
    import flash.system.Security;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import ThreeDPack.ThreeDCanvas;

	class ExternalInterfaceManager
	{
		public function ExternalInterfaceManager()
		{
			if (ExternalInterface.available) {
                try {
                    ThreeDApp.output("Adding callback...\n");
                    ExternalInterface.addCallback("sendToActionScript", receivedFromJavaScript);
                    if (checkJavaScriptReady()) {
                        ThreeDApp.output("JavaScript is ready.\n");
                    } else {
                        ThreeDApp.output("JavaScript is not ready, creating timer.\n");
                        var readyTimer:Timer = new Timer(100, 0);
                        readyTimer.addEventListener(TimerEvent.TIMER, timerHandler);
                        readyTimer.start();
                    }
                } catch (error:SecurityError) {
                    ThreeDApp.output("A SecurityError occurred: " + error.message + "\n");
                } catch (error:Error) {
                    ThreeDApp.output("An Error occurred: " + error.message + "\n");
                }
            } else {
                ThreeDApp.output("External interface is not available for this container.");
            }
		}
		
        private function checkJavaScriptReady():Boolean {
			var isReady:Boolean = ExternalInterface.call("isReady");
            ThreeDApp.output("Checking JavaScript status... "+ExternalInterface.call("isReady")+", "+Math.random()+"\n");
            return isReady;
        }
        private function timerHandler(event:TimerEvent):void {
            var isReady:Boolean = checkJavaScriptReady();
            if (isReady) {
                ThreeDApp.output("JavaScript is ready.\n");
                Timer(event.target).stop();
            }
        }
        private function receivedFromJavaScript(value:String):void {
//            ThreeDApp.output("JavaScript says: " + value + "\n");
			if (ThreeDCanvas.isCurrCubeMoving())
				return;
			ProgressTracker.requestNewContent(value);
			ProgressTracker.resetContent(undefined, true);
        }
		public function call(functionID, ...rest):*
		{
			try {
				return ExternalInterface.call(functionID, rest);
			} catch (error:Error) {
				ThreeDApp.output("An Error occurred: " + error.message + "\n");
			}
		}
	}
}