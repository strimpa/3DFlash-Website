package myUi 
{
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.geom.Point;
	import flash.events.*;
	import flash.events.MouseEvent;

	/**
	 * @author gunnar
	 * null 
	 **/
	 public class MySlider extends Sprite 
	 {
	 	// defines
	 	public const HORIZONTAL:Number=0,VERTICAL:Number=1;
	 	public const IDLE:Number=0, PRESSED:Number=1, MOVING:Number=2, RELEASED:Number=3; 
	 	
	 	public var orientation:Number;
	 	public var pos:Point;
	 	public var size:Number;
	 	public var state:Number;
	 	public var value:Number;
	 	public var min:Number;
	 	public var max:Number; 
	 	
	 	public var button:Sprite;
	 	public var cb:Function;
	 	
	 	
	 	public function MySlider(pos:Point, size:Number=100, min:Number=0, max:Number=100, initValue:Number=0, orientation:Number=VERTICAL)
	 	{
			this.pos = pos;
			this.orientation = orientation;
	 		this.min = min;
	 		this.max = max;
	 		this.state = IDLE;
	 		this.value = initValue;
	 		this.size = size;
	 		
	 		var scope:Sprite = new Sprite();
	 		scope.x = pos.x;
	 		scope.y = pos.y;
	 		scope.graphics.beginFill(0x999999);
	 		if(orientation==VERTICAL)
	 			scope.graphics.drawRect(0,-2.5,size,5);
	 		else
	 			scope.graphics.drawRect(0,0,5,size);
	 		scope.graphics.endFill();
	 		scope.addEventListener(MouseEvent.MOUSE_DOWN, scopeClickHandler);
	 			
	 		
	 		button = new Sprite();
	 		var buttonSprite:Sprite = new Sprite();
	 		button.x = pos.x+(size/(max-min))*initValue;
	 		button.y = pos.y;
	 		buttonSprite.graphics.beginFill(0x333333);
	 		buttonSprite.graphics.drawEllipse(-5,-5,10,10);
	 		buttonSprite.graphics.endFill();
//	 		button.hitTestObject(buttonSprite);
//	 		button.upState = buttonSprite;
//	 		button.downState = 
//	 		button.overState = null;// buttonSprite;
//	 		button.useHandCursor = true;
			button.addChild(buttonSprite);
	 		button.addEventListener(MouseEvent.MOUSE_DOWN, mouseClickHandler);
	 		button.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	 		button.addEventListener(MouseEvent.MOUSE_UP, mouseReleaseHandler);
	 		button.addEventListener(MouseEvent.MOUSE_OUT, mouseReleaseHandler);
	 		
	 		this.addChild(scope);
	 		this.addChild(button);
	 	}
	 	
	 	public function setState( state:Number):void
	 	{
	 		this.state = state; 
	 	}
	 	
	 	public function setCallback(cb:Function):void
	 	{
	 		this.cb = cb;
	 	}
	 	
	 	public function draw():void
	 	{
	 	}
	 	
	 	public function mouseClickHandler(event:Event):void
	 	{
	 		setState(PRESSED);
		}
	 	
	 	public function mouseReleaseHandler(event:Event):void
	 	{
	 		setState(IDLE);
	 	}
	 	
	 	private function calcValue():void
	 	{
			this.value = (this.button.x-pos.x)/this.size;
			this.value = (max-min) * this.value; 
	 	}
	 	
	 	public function getValue():Number
	 	{
	 		return value;
	 	}
	 	
	 	private function scopeClickHandler(event:MouseEvent):void
	 	{
	 		if(event.stageX>pos.x && event.stageX<pos.x+size);
	 			this.button.x = event.stageX;
	 		calcValue();
			if(this.cb)
				this.cb(this.value);
	 	}
	 	
	 	public function mouseMoveHandler(event:MouseEvent):void
	 	{
	 		if(state==PRESSED)
	 		{
		 		scopeClickHandler(event);
			}
		}
	 }
}