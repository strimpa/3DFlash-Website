package 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.BlendMode;
	
	/**
	 * The sprite to show the loader progresses
	 * @author Gunnar
	 */
	public class LoaderDisplay extends Sprite
	{
		private var parentSprite:Sprite;
		private var loadingItems:Array;
		private var loadingProgresses:Array;
		private var loadingTextfields:Array;
		private var borderLeftCorner:Point = new Point(200, 200);
		private var borderDimensions:Point = new Point(400, 400);
		private var itemLeftCorner:Point = new Point(205, 205);
		private var itemDimensions:Point = new Point(390, 20);
		private var titleField:TextField = undefined;
		
		public function LoaderDisplay(parent:Sprite)
		{
			loadingItems = new Array();
			loadingProgresses = new Array();
			loadingTextfields = new Array();
			parentSprite = parent;
		}
		
		public function registerLoadingItem(name:String):void
		{
			loadingItems.push(name);
			var tf:TextField = new TextField();
			tf.selectable = false;
			tf.wordWrap = false;
			tf.multiline = false;
//			tf.blendMode = BlendMode.LAYER;
			tf.defaultTextFormat = globals.textformatSmallBright;
			tf.text = name;
			loadingTextfields.push(tf);
			loadingProgresses.push(0.0);
		}
		
		public function initTitle():void
		{
			titleField = new TextField();
			titleField.selectable = false;
			titleField.embedFonts = true;
			titleField.defaultTextFormat = globals.textformatCubeTitle;
			titleField.blendMode = BlendMode.LAYER;
			titleField.width = 600;
			addChild(titleField);
			titleField.x = 160;
			titleField.y = 160;
			titleField.text = "Loading, please have patience...";
			titleField.alpha = 1;
		}
		
		public function updateProgress(name:String, progress:Number):void
		{
			var index:uint = loadingItems.indexOf(name);
			//trace("updateProgress: "+progress);
			loadingProgresses[index] = progress;
		}

		public function unRegisterLoadingItem(name:String):void
		{
			var index:uint = loadingItems.indexOf(name);
			loadingItems.splice(index, 1);
			if (contains(loadingTextfields[index]))
				removeChild(loadingTextfields[index]);
			loadingTextfields.splice(index, 1);
			loadingProgresses.splice(index, 1);
		}

		public function Process():void
		{
			if (loadingItems.length > 0)
				alpha += 0.5;
			else
				alpha -= 0.1;
			alpha = alpha<0?0:(alpha>1?1:alpha);
			borderDimensions.y = loadingItems.length * 25;
			
			if (alpha == 0)
			{
				if(parentSprite.contains(this))
					parentSprite.removeChild(this);
			}
			else if (!parentSprite.contains(this))
				parentSprite.addChild(this);
				
			if (titleField != undefined && titleField.alpha < 1)
				titleField.alpha += 0.33;
		}
		
		public function draw():void
		{
			if (alpha <= 0)
				return;
			graphics.clear();
			graphics.beginFill(0x111111, 0.7);
			graphics.drawRect(0, 0, 800, 1000);
			graphics.endFill();
			
			graphics.lineStyle(0.5, 0xAAAAAA);
			graphics.drawRect(borderLeftCorner.x, borderLeftCorner.y, borderDimensions.x, borderDimensions.y);
			
			for (var itemIndex:uint = 0; itemIndex < loadingItems.length; itemIndex++ )
			{
				var currY:uint = itemLeftCorner.y + ((itemDimensions.y + 5) * itemIndex);
				if (loadingTextfields[itemIndex])
				{
					if (!contains(loadingTextfields[itemIndex]))
						addChild(loadingTextfields[itemIndex]);
					loadingTextfields[itemIndex].x = itemLeftCorner.x;
					loadingTextfields[itemIndex].y = currY;
				}
				graphics.moveTo(itemLeftCorner.x, currY + 20);
				graphics.lineTo(itemLeftCorner.x + (loadingProgresses[itemIndex]*itemDimensions.x), currY + 20);
			}
		}
	}
	
}