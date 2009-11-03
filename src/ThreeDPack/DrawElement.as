package ThreeDPack
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class DrawElement extends Sprite
	{
		public var mouseOverColour:Number = 0x4f3333;
		public var movingColour:Number = 0x3F3333;
		public var inactiveColour = 0x333333;
		public var borderColour:Number;
		public var myObj:ThreeDObject;
		public var jumpLength:Number = 10;
		public var myIndex:Number;
		public static var mouseIsDown:Boolean;
		public static var clickPoint:ThreeDPoint;
		public static var moveDelta:ThreeDPoint;
		
		public function DrawElement(name:String=""):void
		{
			super();
			this.name = name;
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler, false, 2);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, 2);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler, false, 1);
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, 1);
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseClickHandler, false, 0);
			mouseIsDown = false;
			moveDelta = new ThreeDPoint();
		}

		public function mouseOverHandler(event:MouseEvent):void
		{
			//trace("mouse over");
			/**/
		}

		public function mouseOutHandler(event:MouseEvent):void
		{
			//trace("mouse out");
			/**/
		}

		public function mouseClickHandler(event:MouseEvent):void
		{
//			trace("mouse click");
			moveDelta = new ThreeDPoint();
			clickPoint = new ThreeDPoint(event.stageX,event.stageY,0); 
			mouseIsDown = true;
		}
		public function mouseUpHandler(event:MouseEvent):void
		{
//			trace("mouse up");
			mouseIsDown = false;
			moveDelta = new ThreeDPoint();
		}
		
		public function mouseMoveHandler(event:MouseEvent):void
		{
			if(mouseIsDown)
			{
//				trace("mouseIsDown:"+mouseIsDown);
				moveDelta.x = event.stageX - clickPoint.x; 
				moveDelta.y = event.stageY - clickPoint.y; 
				MouseDragHandler(event);
			}
		}
		
		public function MouseDragHandler(event:MouseEvent):void
		{
		} 
	}
}