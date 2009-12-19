package
{
	/**
	 * @author Gunnar
	 */
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import ThreeDPack.ThreeDPoint;

	public class KeywordManager extends Sprite{
		private var keywords:Array = ["progamming", "web", "3D", "uni", "design"];
		static private var menuMovie:Sprite;
		private var localOrigin:Point;
		private var middle:ThreeDPoint = ThreeDApp.spectrumMiddle;
		private var spriteMiddle:ThreeDPoint = new ThreeDPoint(220, 110, 0);
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
			trace("loaded a menupoint");
		}
		
		public function rotateMenuPoint(dobj:DisplayObject, pointNo:Number, rotInRad:Number):void
		{
		}
		
		public function Update(mousePos:Point, currentKeywords:Array):void
		{
			if(menuMovie==undefined)
				return;
			for(var pointNo:Number=0;pointNo<menuMovie.numChildren;pointNo++)
				for each (var index:Number in currentKeywords)
					if(index==pointNo)
//				rotateMenuPoint(menuMovies[pointNo], pointNo, Math.atan2(mousePos.y-middle.y, mousePos.x-middle.x));
						movements[pointNo] = -Math.atan2(-(mousePos.y-middle.y), mousePos.x-middle.x);
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
