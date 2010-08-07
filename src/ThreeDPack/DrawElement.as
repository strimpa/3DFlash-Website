package ThreeDPack
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class DrawElement extends Sprite
	{
		public static const 
			COLLAPSED:uint = 0,
			EXTENDING:uint = 1,
			EXTENDED:uint = 2,
			COLLAPSING:uint = 4,
			NONE:uint = 8,
			ANY:uint = 16;
		protected var parentObj:ThreeDObject;
		private var mCurrState:uint;
		public var pendingMovements:Array;	
		public var movementIndex:Number=0;
		public var moving:Boolean=false;
		public var isMovable:Boolean = true;
		private var callback:Function = null;
		private var callbackEvent:uint = NONE;
		protected var active:Boolean = false; 

		public var currColour:Number;
		public static var mouseOverColour:Number = 0x66666f;
		public static var movingColour:Number = 0x363333;
		public static var inactiveColour = 0x333333;
		public var borderColour:Number;
		public var myObj:ThreeDObject;
		public var jumpLength:Number = 10;
		public var polyJumpLength:Number = 6;
		public var myIndex:Number;
		public static var mouseIsDown:Boolean;
		public static var clickPoint:ThreeDPoint;
		public static var moveDelta:ThreeDPoint;
		public static var somethingMoving:Boolean;
		
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
			this.pendingMovements = new Array();
			setState(COLLAPSED);
			somethingMoving = false;
		}
		
		public function getParentObj():ThreeDObject
		{
			return parentObj;
		}

		public function setActive(act:Boolean=true)
		{
			this.active = act;
			if (!act)
			{
				if (parent)
					parent.removeChild(this);
			}
		}
		
		public function isActive()
		{
			return this.active;
		}
		
		public function mouseOverHandler(event:Event):void
		{
			//trace("mouse over");
			/**/
		}

		public function mouseOutHandler(event:Event):void
		{
			//trace("mouse out");
			/**/
		}

		public function mouseClickHandler(event:Event):void
		{
//			trace("mouse click");
			moveDelta = new ThreeDPoint();
			clickPoint = new ThreeDPoint(mouseX,mouseY,0); 
			mouseIsDown = true;
		}
		public function mouseUpHandler(event:Event):void
		{
//			trace("mouse up");
			mouseIsDown = false;
			moveDelta = new ThreeDPoint();
		}
		
		public function mouseMoveHandler(event:Event):void
		{
			if(mouseIsDown)
			{
//				trace("mouseIsDown:"+mouseIsDown);
				moveDelta.x = mouseX - clickPoint.x; 
				moveDelta.y = mouseY - clickPoint.y; 
				MouseDragHandler(event);
			}
		}
		
		public function setCallback(event:uint, cb:Function):void
		{
			this.callbackEvent = event;
			this.callback = cb;
		}
		
		private function useCallback(event:uint):void
		{
			if ( (event == this.callbackEvent || ANY == this.callbackEvent)
					&& this.callback)
			{
				callback();
				callbackEvent = NONE;
				callback = null;
			}
		}
		
		public function MouseDragHandler(event:Event):void
		{
		} 

		public function processStates():void
		{
//			trace(mCurrState);
			if(EXTENDING==getState())//this.movementIndex<this.pendingMovements.length)
			{
				this.moving=true;
				currColour = mouseOverColour;
				if(this.movementIndex==this.pendingMovements.length)
				{
//					trace("movementIndex:"+movementIndex+", pendingMovements.length:"+pendingMovements.length);
					setState(EXTENDED);
					OnExtended();
					this.moving=false;
				}
				else
				{
					if (this.movementIndex == 0)
						OnExtending();
					this.movementIndex++;
				}

				moveStep();
			}
			else if(COLLAPSING==getState())
			{
				this.moving=true;
				if(this.movementIndex<=0)
				{
					setState(COLLAPSED);
					OnCollapsed();
					this.movementIndex = 0;
					this.moving=false;
				}
				else
				{
					if (this.movementIndex == this.pendingMovements.length)
						OnCollapsing();
					this.movementIndex--;
				}

				moveStep();
			}
		}
		
		public function OnExtended():void
		{
			somethingMoving = false;
			useCallback(EXTENDED);
		}
		
		public function OnCollapsed():void
		{
			somethingMoving = false;
			useCallback(COLLAPSED);
		}

		public function OnCollapsing():void
		{
			somethingMoving = true;
			useCallback(COLLAPSING);
		}
		
		public function OnExtending():void
		{
			somethingMoving = true;
			useCallback(EXTENDING);
		}
		
		public static function IsSomethingMoving():Boolean
		{
			ThreeDApp.output("somethingMoving:"+somethingMoving)
			return somethingMoving;
		}

		public function Process(parent:ThreeDObject=undefined):void
		{
			this.parentObj = parent;
			processStates();
		}

		public function moveStep():void
		{
		}
		
		public function calcMovements():void
		{ /* to be overridden */ }
		
		public function jump():void //dirIndex:Number
		{
			if(mCurrState==COLLAPSED||mCurrState==COLLAPSING)
			{
				extend();
			}
			else
				collapse();
		}
		
		public function extend():void
		{
			if (getState() != EXTENDED)
			{
				calcMovements();
				setState(EXTENDING);
			}
		}
		public function collapse():void
		{
			if (getState() != COLLAPSED)
			{
				setState(COLLAPSING);
			}
		}

		public function setState(state:uint):void
		{
//			trace("set to state:"+state);
			mCurrState=state;
		}
		public function getState():uint
		{
			return mCurrState;
		}
		
		public function isMoving():Boolean
		{
			return mCurrState == COLLAPSING || mCurrState == EXTENDING;
		}
	}
}