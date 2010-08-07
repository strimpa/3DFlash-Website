package ThreeDPack
{
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.Sprite;

	/**
	 * @author Gunnar
	 */
	public class MenuElement extends ThreeDObject 
	{
		var category:uint;
		private var mouseIsOverMe:Boolean = true;
		private var titleInvoked:Boolean = false;
		private var myTitleSprite:Sprite = undefined;
		private var lastFrameMouseState:Boolean = false;
		public static const categoryLUT:Array = ["misc", "programming", "3DArt", "web"];
		public static const categoryStrings:Array = ["Miscellaneous", "Programming", "3D Art", "Web/Flash"];
		
		
		public function MenuElement() {
			super();
		}
		
		public static function getCategoryIndex(cat:String):uint
		{
			return categoryLUT.indexOf(cat);
		}
		
		public override function mouseClickHandler(event:Event):void
		{
			if(getState()==EXTENDED)
				ThreeDApp.resetCurves();
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || ThreeDCanvas.currActiveCube!=undefined)
				return;
			ProgressTracker.scopeType = ProgressTracker.CATEGORY_SCOPE;
			if(ProgressTracker.getState()==ProgressTracker.SCOPE_SELECTED)
				ProgressTracker.setState(ProgressTracker.START);
			else if(ProgressTracker.getState()==ProgressTracker.SCOPE_SELECT)
				ProgressTracker.setState(ProgressTracker.SCOPE_SELECTED);
			super.mouseClickHandler(event);
		}

		public override function mouseMoveHandler(event:Event):void
		{
//			trace("mouse move "+category);
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || getState()!=COLLAPSED || !isActive())
				return;

			mouseIsOverMe = true;
			super.mouseMoveHandler(event);
		}
		
		public override function mouseOverHandler(event:Event):void
		{
//			trace("mouse over "+category);
			super.mouseOverHandler(event);
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || getState()!=COLLAPSED || !isActive())
				return;

			mouseIsOverMe = true;
			if (!titleInvoked && category<categoryStrings.length)
			{
				titleInvoked = true;
				var title:String = categoryStrings[category];
				var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
				var mp = new ThreeDPoint(mouseX, mouseY, 0);
//				trace("show new title "+title+", "+category);
				myTitleSprite = TitleFieldManager.showTitleAtPoint(title, this, mp);
			}
			ProgressTracker.setState(ProgressTracker.SCOPE_SELECT);
		}
		public override function mouseOutHandler(event:Event):void
		{
//			trace("mouse out "+category);
			mouseIsOverMe = false;
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || getState()!=COLLAPSED || !isActive())
				return;

			ProgressTracker.setState(ProgressTracker.START);
			super.mouseOutHandler(event);
		}
		public override function OnCollapsed():void
		{
			if(ProgressTracker.getState()<ProgressTracker.SCOPE_SELECTED)
				ProgressTracker.resetContent();
			super.OnCollapsed();
		}
		public override function OnExtending():void
		{
			TitleFieldManager.fadeOutTitle(myTitleSprite);
			CubeCollection.setCubesActiveByCategory(true, categoryLUT[category]);
			Obj2As.setObjectsActiveByCategory(category, true);
			super.OnExtending();
		}
		
		public override function Process(p:ThreeDObject=undefined):void
		{
			if (ThreeDApp.IsOverBG())
				mouseIsOverMe = false;
			if (!mouseIsOverMe && lastFrameMouseState)
			{
//				trace("mouse is not over me any more "+category);
				TitleFieldManager.fadeOutTitle(myTitleSprite);
				myTitleSprite = undefined;
				titleInvoked = false;
			}
			lastFrameMouseState = mouseIsOverMe;
			super.Process(p);
		}
		
		public function resetTitleSprite():void
		{
			myTitleSprite = undefined;
		}
	}
}
