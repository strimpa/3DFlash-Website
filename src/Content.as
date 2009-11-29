package {
	import flash.net.*;
	import flash.text.TextField;

	/**
	 * @author Gunnar
	 */
	 
	public class Content extends TextField
	{
		public var mTitle:String;
		public var mCategory:String;
		public var mKeywords:Array;
		public var mContentUrl:URLRequest;
		private var mLoader:TargetLoadVars;
		public function Content()
		{
			mLoader = new TargetLoadVars(this);
		}
		
		private function Load():void
		{
			mLoader.loadItem("html\FancyChecker\FancyChecker.html");
		}
		
		private function onData(data:Object):void
		{
			this.htmlText = (data as String);
		}
		
	}
}
