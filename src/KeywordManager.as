package
{
	/**
	 * @author Gunnar
	 */
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.DRMCustomProperties;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import ThreeDPack.CubeCollection;
	import ThreeDPack.Obj2As;
	import ThreeDPack.ThreeDPoint;

	public class KeywordManager extends Sprite{
		private var keywords:Array = ["film", "progamming", "3D", "design", "uni", "web"];
		static private var menuMovie:Sprite;
		private var localOrigin:Point;
		private var middle:ThreeDPoint = ThreeDApp.spectrumMiddle;
		private var spriteMiddle:ThreeDPoint = new ThreeDPoint(220, 110, 0);
		private var buttons:Array;
		static private var movements:Array;

		public function KeywordManager(parent:Sprite)
		{
//			menuMovies = new Array();
			movements = new Array();
			localOrigin = new Point();
//			for(var i=0;i<menuMovieNames.length;i++)
//			{
//				trace("loading: "+menuMovieNames[i]);
//				menuMovies[i] = new TargetLoad(this);
//				(menuMovies[i] as TargetLoad).loadItem(menuMovieNames[i]);
//			}
			
			parent.addChild(this);
			this.x = middle.x;
			this.y = middle.y;
			localOrigin.x = 17;
			localOrigin.y = 15;
		}
		
		public function onData(data:Object):void
		{
			var displayData:DisplayObject = (data as DisplayObject);
			this.addChild(displayData);
			menuMovie = ((data as Sprite).getChildAt(0) as Sprite);
			movements = new Array(menuMovie.numChildren);
//			displayData.x = -spriteMiddle.x;//-localOrigin.x;
//			displayData.y = -middle.y;//+localOrigin.y;
			buttons = new Array(menuMovie.numChildren);
			var firstRadius:uint = 200;
			var secondRadius:uint = 210;
			for (var i:uint = 0; i < menuMovie.numChildren; i++ )
			{
				trace("menuMovie.numChild:"+i);
				var rand:Number = Math.random();
				var buttonSprite:Sprite = new Sprite();
				buttonSprite.graphics.beginFill(0x888888, 0.5);
				buttonSprite.graphics.lineStyle(0.5, 0xFFFFFF, 0);
				buttonSprite.graphics.drawCircle(0, 0, firstRadius);
				buttonSprite.graphics.lineStyle(0.5, 0xFFFFFF, 1);
				buttonSprite.graphics.drawCircle(0, 0, secondRadius);
				buttonSprite.graphics.endFill();
				buttonSprite.alpha = 0.1;
				buttonSprite.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler,false, 1);
				buttonSprite.addEventListener(MouseEvent.MOUSE_MOVE, mouseOverHandler,false, 1);
				buttonSprite.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 0);
				buttonSprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseClickHandler, false, 2);
				buttonSprite.name = "number:" + i;
				buttons[i] = buttonSprite;
				addChild(buttons[i]);
				firstRadius += 10;
				secondRadius += 10;
			}
		}
		public function mouseOverHandler(e:MouseEvent):void
		{
			if (ProgressTracker.scopeType == ProgressTracker.CATEGORY_SCOPE)
				return;
			if(ProgressTracker.getState()==ProgressTracker.START)
				ProgressTracker.setState(ProgressTracker.SCOPE_SELECT);
			e.target.alpha = 0.2; 
		}
		public function mouseOutHandler(e:MouseEvent):void
		{ 
			if (ProgressTracker.scopeType == ProgressTracker.CATEGORY_SCOPE)
				return;
			if (ProgressTracker.getState()<=ProgressTracker.SCOPE_SELECT)
				ProgressTracker.setState(ProgressTracker.START);
			e.target.alpha = 0.1; 
		}
		public function mouseClickHandler(e:MouseEvent):void 
		{
			if (ProgressTracker.scopeType == ProgressTracker.CATEGORY_SCOPE)
				return;
			var key:String = keywords[buttons.indexOf(e.target)]
			CubeCollection.setCubesActiveByKeyword(true, key);
			ProgressTracker.setState(ProgressTracker.SCOPE_SELECTED);
			ProgressTracker.scopeType = ProgressTracker.KEYWORD_SCOPE;
			ProgressTracker.lastChosenKeyword = key;
			Obj2As.setObjectsActiveByCategory(-1, true);
		}
		
		public function Update(mousePos:Point, currentKeywords:Array):void
		{
			if (menuMovie == undefined)
			{
				return;
			}
			for (var pointNo:Number = 0; pointNo < menuMovie.numChildren; pointNo++)
			{
				for each (var key:String in currentKeywords)
				{
					var index:Number = keywords.indexOf(key);
					if (index!=0 && index == pointNo)
					{
						movements[pointNo] = -Math.atan2( -(mousePos.y - middle.y), mousePos.x - middle.x);
					}
				}
			}
		}
		
		static public function resetPositions():void
		{
			for(var pointNo:Number=0;pointNo<menuMovie.numChildren;pointNo++)
				movements[pointNo] = -90*(Math.PI/180);
		}

		public function draw()
		{
			if(menuMovie==undefined)
				return;
			for(var pointNo:Number=0;pointNo<menuMovie.numChildren;pointNo++)
			{ 
				var dobj:DisplayObject = menuMovie.getChildAt(pointNo);
				var dir:Number =0;
				var rotation:Number = movements[pointNo] * (180/Math.PI);
				var objRot:Number = dobj.rotation - (280/Math.PI);
				dir = (rotation - objRot);
				dir = dir<-180?360+dir:(dir>180?-(360-dir):dir);
//				trace("rotation: "+rotation+" objRot: "+objRot+" dir: "+dir);
				if(dir)
					dobj.rotation += dir/5;
			}
		}
	}
}
