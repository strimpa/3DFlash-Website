package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	
	public class ArrowButton extends Sprite
	{
		private const gap:uint = 3;
		private var b:Sprite =  new Sprite();
		private var circle:Sprite =  new Sprite();
		private var arrow:Sprite =  new Sprite();
		private var arrowMask:Sprite =  new Sprite();
		private const numFrames:uint = 10;
		private var arrowOffset:uint = 0;
		private var arrowWidth:uint = 12;
		private static var instances:Array = new Array();
		private var mouseOverInstance:Boolean = false;

		private function MoveArrow(event:TimerEvent=undefined)
		{
			if (arrowOffset >= arrowWidth)
			{
				if(!mouseOverInstance)
				{
					return;
				}
				else
				{
					arrowOffset = 0;
					arrow.x = gap+arrowWidth;
				}
			}
			else
			{
				trace("arrow.x:" + arrow.x + ", arrowOffset" + arrowOffset);
				arrow.x -= 1;
				arrowOffset ++;
			}
		}
		
		private function mouseOverHandler(me:MouseEvent)
		{
			mouseOverInstance = true;
		}
		private function mouseOutHandler(me:MouseEvent)
		{
			mouseOverInstance = false;
		}
		
		public function ArrowButton(p_width:uint=12)
		{
			arrowWidth = p_width;
			arrowOffset = arrowWidth;
			
			circle.graphics.beginFill(0xFFFFFF, 1);
			circle.graphics.drawCircle(0,0,arrowWidth);
			circle.graphics.endFill();
			
			arrowMask.graphics.beginFill(0xFFFFFF, 1);
			arrowMask.graphics.drawCircle(0,0,arrowWidth);
			arrowMask.graphics.endFill();
			
			arrow.graphics.lineStyle(2, 0x666666, 1, false, "normal", "none");
			arrow.graphics.moveTo(-arrowWidth+gap,	0);
			arrow.graphics.lineTo(arrowWidth, 		0);
			
			arrow.graphics.moveTo(0, 				-arrowWidth+gap);
			arrow.graphics.lineTo(-arrowWidth+gap,	0);
			arrow.graphics.lineTo(0, 				arrowWidth-gap);

			b.addChild(circle);
			b.addChild(arrow);
			b.addChild(arrowMask);
			
			arrow.mask = arrowMask;

//			super(b, b, b, b);
			this.addChild(b);
			this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
			instances.push(this);
			
			buttonMode = true;
		}
		
		public function Process()
		{
			MoveArrow();
		}
		
		public static function Process()
		{
			for each(var inst:ArrowButton in instances)
			{
				inst.Process();
			}
		}
	}
}