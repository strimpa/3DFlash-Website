package 
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import ThreeDPack.CubeCollection;
	import ThreeDPack.DrawElement;
	import ThreeDPack.MenuElement;
	import ThreeDPack.Obj2As;
	import ThreeDPack.ThreeDCanvas;
	
	/**
	 * ProgressTracker: A class tracking the progress from start till content selection and allowing navigation back and forth
	 * @author ...
	 */
	public class ProgressTracker extends Sprite
	{
		public static const START:uint = 0, SCOPE_SELECT:uint = 1, SCOPE_SELECTED:uint = 2, CONTENT_SELECT:uint = 3, CONTENT_SELECTED:uint = 4;
		public static const CATEGORY_SCOPE:uint = 0, KEYWORD_SCOPE:uint = 1;
		private var stateStrings:Array = ["start", "scope select", "scope selected", "content select", "content open"];
		private var stateFields:Array;
		private var button:SimpleButton;
		private var statePosition:Point = new Point(598, 84);
		private var stateOffset:Number = 22.5;
		private static var state:uint = CONTENT_SELECTED;
		private static var newState:uint = START;
		public static var scopeType:int = -1;
		private var activeCircle:Sprite;
		public static var lastChosenKeyword:String;
		
		function ProgressTracker()
		{
			activeCircle = new Sprite();
			activeCircle.graphics.lineStyle(1, 0xffffff, 1);
			activeCircle.graphics.drawCircle(8, 8, 8);
			addChild(activeCircle);
			activeCircle.x = statePosition.x;
			activeCircle.y = statePosition.y;
			
			stateFields = new Array(stateStrings.length);
			var b:Sprite =  new Sprite();
			b.graphics.beginFill(0xFFFFFF, 1);
//			b.graphics.lineStyle(
			b.graphics.drawCircle(
				statePosition.x + 8,
				statePosition.y + 8,
				8);
			b.graphics.endFill();
			button = new SimpleButton(b,b,b,b);
			button.addEventListener(MouseEvent.MOUSE_DOWN, backButtonPressHandler);
			button.alpha = 0;
			addChild(button);

			for (var fieldIndex:uint; fieldIndex < stateStrings.length;fieldIndex++ ) 
			{
				
				stateFields[fieldIndex] = new TextField();
				var field:TextField = stateFields[fieldIndex];
				field.selectable = false;
				field.wordWrap = false;
				field.multiline = false;
				field.defaultTextFormat = globals.textformatSmallBright;
				field.text = stateStrings[fieldIndex];
				addChild(field);
				field.x = statePosition.x + (stateOffset * (fieldIndex+1));
				field.y = statePosition.y + 20;
				field.width = 0;
				field.height = 20;
				field.rotation = 0.3;
			}
		}
		
		public function backButtonPressHandler(e:MouseEvent):void
		{
			switch(state)
			{
				case 1:
					break;
				case 2:
					CubeCollection.setCubeActive(true, -1);
					Obj2As.setObjectsActiveByCategory(-1, false); // all
					for each(var obj:MenuElement in Obj2As.objects) 
					{
						if (obj.getState() != DrawElement.COLLAPSED)
							obj.setState(DrawElement.COLLAPSING);
					}
					setState(START);
					break;
				case 3:
				case 4:
					ThreeDCanvas.exitHandler(e);
				break;
			}
		}
		
		public static function setState(theState:uint):void
		{
			newState = theState;
			if (theState == START)
			{
				scopeType = -1;
				lastChosenKeyword = undefined;
			}
		}
		public static function getState():uint
		{
			return state;
		}
			
		public function Process():void
		{
			if (newState != state)
			{
				state = newState;
				activeCircle.x = statePosition.x + (stateOffset * (state+1));
			}
			var allFieldsCollapsed:Boolean = true;
			for (var fieldIndex:uint; fieldIndex < stateFields.length; fieldIndex++ ) 
			{
				if (fieldIndex != state)
				{
					if (stateFields[fieldIndex].width >= 10)
					{
						stateFields[fieldIndex].width -= 10;
						allFieldsCollapsed = false;
//						trace("one field not collapsed "+stateFields[fieldIndex].width +", "+ fieldIndex +", "+ state);
					}
					else
						stateFields[fieldIndex].width = 0;
				}
			}
			if (allFieldsCollapsed && stateFields[state].width < 60)
				stateFields[state].width+=10;

			if ((state > 1) && button.alpha < 1)
				button.alpha += 0.1;
			else if ((state == 0) && button.alpha > 0)
				button.alpha -= 0.1;
		}
	}
	
}