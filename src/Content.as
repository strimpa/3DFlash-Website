package {
	import flash.display.Sprite;
	import flash.net.*;
	import flash.text.TextField;
	import ThreeDPack.Cube;
	import flash.text.StyleSheet;
	import ContentManager;
	import ScrollBar;

	/**
	 * @author Gunnar
	 */
	 
	public class Content
	{
		public var mTitle:String;
		public var mFolderName:String;
		public var mCategory:String;
		public var mKeywords:Array;
		public var mContentUrl:String;
		private var mMyCube:Cube;
		private var mTexts:Array;
		private var mHeaders:Array;
		private static var styleString:StyleSheet;
		private static var contentBG:Sprite;
        public function Content()
		{
			mTexts = new Array();
			mHeaders = new Array();
			styleString = new StyleSheet();
		}
		
		public function setCube(cube:Cube):void
		{
			mMyCube = cube;
		}
		
		public function load():void
		{
			ThreeDApp.getContent().LoadObject(globals.htmlRoot+mContentUrl, ContentManager.xml, undefined, this.onData);
		}
		
		public static function contentStyleLoaded(data:Object):void
		{
			styleString.parseCSS(data as String);
		}
		public static function contentBGLoaded(data:Object):void
		{
			contentBG = (data as Sprite);
		}
		public static function getStyle():StyleSheet
		{
			return styleString;
		}
		public static function getBG():Sprite
		{
			return contentBG;
		}
		
		public function onData(data:Object):void
		{
//			trace((data as String));
			var xmlitem:XML = XML(data as String);
			var list:XMLList = xmlitem.children()[1].children()[0].children(); //body.div.
			mMyCube.evaluatefacingFace();
//			trace("mMyCube.getCurrFacingPoly():"+mMyCube.getCurrFacingPoly());
			var counter:uint = mMyCube.getCurrFacingPoly();
			for each(var item:XML in list)
			{
				mTexts[counter] = item;
				mHeaders[counter] = item.attribute("name");
				mMyCube.setHeader(mHeaders[counter], counter);
//				mMyCube.setText(mTexts[counter], counter);
				counter++;
				if (counter > 3)
					counter = 0;
			}
			setText(mMyCube.getCurrFacingPoly());
		}
		
		public function hasText(index:uint):Boolean
		{
			return mTexts[index]!=undefined;
		}
		
		public function setText(index:uint):void
		{
			if(mTexts[index]!=undefined)
				mMyCube.setText(mTexts[index], index);
			if(mHeaders[index])
				mMyCube.setHeader(mHeaders[index], index);
				
			var newControlFLags:uint = 0;
			if (mTexts[index-1] != undefined)
				newControlFLags |= ContentControls.CONTENTJUMP_LAST;
			if (mTexts[index+1] != undefined)
				newControlFLags |= ContentControls.CONTENTJUMP_NEXT;
			ThreeDApp.contentControls.SetJumpFlags(newControlFLags);
		}
		
	}
}
