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
		
		public function load():void
		{
			mLoader.loadItem("html/FancyChecker/FancyChecker.html");
		}
		
		public function onData(data:Object):void
		{
//			trace((data as String));
			var xmlitem:XML = XML(data as String);
			var list:XMLList = xmlitem.body.div.children();
			trace("list.length()"+list.length());
			for each(var child in list)
				trace(child.toString());
//			this.htmlText = (data as String);
		}
		
	}
}
