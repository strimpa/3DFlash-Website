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
			LoadObject("bg.jpg", swf, undefined, ThreeDApp.addToBackground);
			LoadObject("baloo.swf", swf, undefined, ThreeDApp.addToBackground);
			LoadObject("FontLoad.swf", swf, undefined, fontInit);
			LoadObject("content.xml", xml, contentXML, ThreeDApp.InitCanvas);
			LoadObject("skull.obj", sceneData, undefined, ThreeDPack.Obj2As.onData);
			LoadObject("html/contentStyle_as.css", css, undefined, Content.contentStyleLoaded);
			LoadObject("barock.swf", swf, undefined, Content.contentBGLoaded);
			LoadObject("exit.swf", swf, undefined, ThreeDCanvas.exitSpriteLoaded);
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
			trace("onData");
			if (data != undefined) 
			{
				var item:Object = queue[0];
				if(item[storage]!=undefined)
				{
					trace("item.storage!=undefined");
					if(item[type]==xml)
						contentXML = XML(data as String);
					//else	
						//loadSwf.loadItem(item.target);
				}
				else
				{
					trace("item.storage==undefined");
				}
			    trace("))))))))))))))))))))))))))))))))))))))) XML Data loaded.");
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
			queue.splice(0, 1);
			state = IDLE;
			//trace("that");
		}

		public function fontInit(data:Object):void
		{
				fonts = Font.enumerateFonts();
				var font:Font;
				for(var x:uint=0; x<fonts.length;x++)
				{
				    font = fonts[x];
				    trace("name : "+font.fontName);
				    trace("style : "+font.fontStyle);
				    trace("type : "+font.fontType);
				
				}		
				trace("loaded");
				ThreeDApp.InitGlobals();
		}
		

		public static function getContent(number:Number):Content
		{
			var content:Content = new Content();
			var xmlitem:XML = contentXML.content[number];
			content.mTitle = xmlitem.title;
			content.mCategory = xmlitem.category;
			content.mKeywords = [xmlitem.keywords];
			content.mContentUrl = xmlitem.url;
			return content;
		}
		
		private function loadNextItem():void
		{
			trace("loadNextItem");
			var item:Object = queue[0];
			if(item == undefined)
				return;
			trace(item);
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
