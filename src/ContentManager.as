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
		const text:uint = 0, swf:uint = 1;
		const target:uint = 0, type:uint = 1, storage:uint = 2, callback:uint = 3;
		var loadVars:TargetLoadVars;
		var loadSwf:TargetLoad;
		var queue:Array = [
			LoadObject("bg.jpg", swf, undefined, ThreeDApp.addToBackground),
			LoadObject("baloo.swf", swf, undefined, ThreeDApp.addToBackground),
			LoadObject("FontLoad.swf", swf, undefined, fontInit),
			LoadObject("content.xml", text, contentXML, ThreeDApp.InitCanvas),
			LoadObject("skull.obj", text, undefined, ThreeDPack.Obj2As.onData),
			LoadObject("keywords.swf", swf, undefined, ThreeDApp.keywords.onData)
			];
//		var queue:Array;
		var loadingIndex:int = -1;
		static var fonts:Array;
		
		function ContentManager()
		{
//			queue = new Array();
			loadVars = new TargetLoadVars(this);
			loadSwf = new TargetLoad(this);
			loadNextItem();
		}
		
		private function LoadObject(target_p:String, type_p:uint, storage_p:Object, callback_p:Function):Array
		{
			var back:Array = new Array(4);
			back[target] = target_p;
			back[type] = type_p;
			back[storage] = storage_p;
			back[callback] = callback_p;
			return back;
		}
		
		public function onData(data:Object):void
		{
			trace("onData");
			if (data != undefined) 
			{
				var item:Object = queue[loadingIndex];
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
			    	
			    loadNextItem();
			} else {
				trace("error! Unable to load external file. ");
			}
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
//			content.mContentUrl = xmlitem.url;
			return content;
		}
		
		private function loadNextItem():void
		{
			loadingIndex++;
			trace("loadNextItem");
			var item:Object = queue[loadingIndex];
			if(item == undefined)
				return;
			trace(item);
			if(item[type] == text)
				loadVars.loadItem(item[target]);
			else
				loadSwf.loadItem(item[target]);
		}
		
		public function Process()
		{
		}
	}
}
