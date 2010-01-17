package ThreeDPack
{
	import flash.events.MouseEvent;
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
		public static const categoryLUT:Array = ["programming", "3DArt", "web", "analogue"];
		public static const categoryStrings:Array = ["Programming", "3D Art", "Web/Flash", "Analogue"];
		
		
		public function MenuElement() {
			super();
		}
		public override function mouseClickHandler(event:MouseEvent):void
		{
			if(getState()==EXTENDED)
				ThreeDApp.resetCurves();
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || ThreeDCanvas.currActiveCube!=undefined)
				return;
			ProgressTracker.scopeType = ProgressTracker.CATEGORY_SCOPE;
			super.mouseClickHandler(event);
		}

		public override function mouseMoveHandler(event:MouseEvent):void
		{
//			trace("mouse move "+category);
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || getState()!=COLLAPSED || !isActive())
				return;

			mouseIsOverMe = true;
			super.mouseMoveHandler(event);
		}
		
		public override function mouseOverHandler(event:MouseEvent):void
		{
//			trace("mouse over "+category);
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || getState()!=COLLAPSED || !isActive())
				return;

			mouseIsOverMe = true;
			if (!titleInvoked && category<categoryStrings.length)
			{
				titleInvoked = true;
				var title:String = categoryStrings[category];
				var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
				var mp = new ThreeDPoint(event.stageX, event.stageY, 0);
//				trace("show new title "+title+", "+category);
				myTitleSprite = TitleFieldManager.showTitleAtPoint(title, this, mp);
			}
			ProgressTracker.setState(ProgressTracker.SCOPE_SELECT);
			super.mouseOverHandler(event);
		}
		public override function mouseOutHandler(event:MouseEvent):void
		{
//			trace("mouse out "+category);
			mouseIsOverMe = false;
			if (ProgressTracker.scopeType == ProgressTracker.KEYWORD_SCOPE || getState()!=COLLAPSED || !isActive())
				return;

			ProgressTracker.setState(ProgressTracker.START);
			super.mouseOutHandler(event);
		}
		public override function OnCollapsing():void
		{
			CubeCollection.setCubesActiveByCategory(true, "none");
			ProgressTracker.setState(ProgressTracker.START);
			Obj2As.setObjectsActiveByCategory(-1, false); // all
			super.OnCollapsing();
		}
		public override function OnExtending():void
		{
			TitleFieldManager.fadeOutTitle(myTitleSprite);
			CubeCollection.setCubesActiveByCategory(true, categoryLUT[category]);
			ProgressTracker.setState(ProgressTracker.SCOPE_SELECTED);
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
//			trace("resetTitleSprite category:"+category);
			myTitleSprite = undefined;
		}
	}
}
