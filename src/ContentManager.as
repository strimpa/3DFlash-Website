package
{
	import flash.net.*;
	import flash.events.*;
//	import flash.utils.Dictionary;
	import flash.text.Font;
	import ThreeDPack.ThreeDCanvas;

	/**
	 * @author Gunnar
	 */
	public class ContentManager {
		
		static var contentXML:XML = new XML();
		const LOADING:uint = 0, IDLE:uint = 1;
		public static const xml:uint = 0, swf:uint = 1, sceneData:uint = 2, css:uint = 3;
		public static const target:uint = 0, type:uint = 1, storage:uint = 2, callback:uint = 3;
		public static const bg1:String = "bg.jpg", bg2:String = "Sky01.jpg";
		var state:uint = IDLE;
		static var loadVars:TargetLoadVars;
		static var loadSwf:TargetLoad;
		var queue:Array;
//		var queue:Array;
//		var loadingIndex:int = -1;
		static var fonts:Array;
		
		function ContentManager()
		{
			queue = new Array();
			loadVars = new TargetLoadVars(this);
			loadSwf = new TargetLoad(this);
			LoadObject("FontLoad.swf", swf, undefined, fontInit);
			LoadObject("bg.jpg", swf, undefined, ThreeDApp.setBackground);
			LoadObject("baloo.swf", swf, undefined, ThreeDApp.addToBackground);
			LoadObject("content.xml", xml, contentXML, ThreeDApp.InitCanvas);
			LoadObject("sphere.obj", sceneData, undefined, ThreeDPack.Obj2As.onData);
			LoadObject(globals.htmlRoot+"contentStyle_as.css", css, undefined, Content.contentStyleLoaded);
			LoadObject("barock.swf", swf, undefined, Content.contentBGLoaded);
			LoadObject("exit.swf", swf, undefined, ThreeDCanvas.exitSpriteLoaded);
			LoadObject("RotHint.swf", swf, undefined, ThreeDPack.Polygon.SetRotHintSprite);
			LoadObject("keywords.swf", swf, undefined, ThreeDApp.keywords.onData);
		}
		
		public static function getLoader():TargetLoad
		{
			return loadSwf;
		}
		
		public static function getTextLoader():TargetLoadVars
		{
			return loadVars;
		}
		
		public function LoadObject(target_p:String, type_p:uint, storage_p:Object, callback_p:Function):void
		{
			var back:Array = new Array(4);
			back[target] = target_p;
			back[type] = type_p;
			back[storage] = storage_p;
			back[callback] = callback_p;
			queue.push(back);
		}
		
		public function onData(data:Object):void
		{
			if (data != undefined) 
			{
				var item:Object = queue[0];
				if(item[storage]!=undefined)
				{
//					trace("item.storage!=undefined");
					if(item[type]==xml)
						contentXML = XML(data as String);
				}
				//else
				//{
					//trace("item.storage==undefined");
				//}
			    if(item[callback]!=undefined)
			    {
			    	trace("item.callback!=undefined:"+item[callback]);
			    	item[callback](data);
			    }
			    else
			    	trace("item.callback=undefined");
			} else {
				trace("error! Unable to load external file. ");
			}
			
			// delete current item off queue
			queue.splice(0, 1);
			if (queue.length <= 0)
				currentLoadingQueueFinished();

			state = IDLE;
			Process();
			//trace("that");
		}

		public function fontInit(data:Object):void
		{
				fonts = Font.enumerateFonts();
				var font:Font;
				trace("fonts.length:"+fonts.length);
				for(var x:uint=0; x<fonts.length;x++)
				{
				    font = fonts[x];
				    trace("name : "+font.fontName);
				    trace("style : "+font.fontStyle);
				    trace("type : "+font.fontType);
				
				}		
				ThreeDApp.InitGlobals();
				ThreeDApp.loader.initTitle();
		}
		

		public static function getContent(number:Number):Content
		{
			var content:Content = new Content();
			if (number >= contentXML.content.length())
				return null;
			var xmlitem:XML = contentXML.content[number];
			content.mTitle = xmlitem.title;
			content.mCategory = xmlitem.category;
			content.mFolderName = xmlitem.folder;
			var keywordString:String = xmlitem.keywords;
			content.mKeywords = keywordString.split(",");//
			content.mContentUrl = xmlitem.url;
			return content;
		}
		
		private function currentLoadingQueueFinished():void
		{
			ThreeDApp.loadCallback();
		}
		
		private function loadNextItem():void
		{
			var item:Object = queue[0];
			if (item == undefined)
			{
				return;
			}
			if(item[type] == xml || item[type] == sceneData || item[type] == css)
				loadVars.loadItem(item[target]);
			else
				loadSwf.loadItem(item[target]);
			
			state = LOADING;
		}
		
		public function Process()
		{
			if (queue.length > 0 && state==IDLE)
				loadNextItem();
		}
	}
}
