package ThreeDPack
{
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class CurvedLineManager extends Sprite
	{
		
		var curveObjects:Array;
		
		static var numPointsOnSection:Number = 20;
		static var numSections:Number = 2;
		
		static var drawCrossesFlag:Boolean=true;
		static var drawGuideFlag:Boolean=false;
		static var drawCurveFlag:Boolean=true;
		static var shiftFlag:Boolean=true;
		static var drawCircleFlag:Boolean=true;
		static var fillingFlag:Boolean=true;
		
		// new
		static var mouseSaves:Array;
		static var currMouseClicks:Number;
		static var colour:Number; 
		
		public function CurvedLineManager()
		{
			curveObjects = new Array(1);
			curveObjects[0] = new CurvedLine();
			mouseSaves = new Array();
			currMouseClicks = 0;
			colour = 0x3F3333;
		}
		
		public function reset()
		{
			graphics.clear();
		}
		
		/***************************************************************************
		EVent handlers functions
		****************************************************************************/

		public function registerPosition(stageX:Number, stageY:Number):void
		{
			var error = undefined;
			error.draw();
			
			mouseSaves[currMouseClicks]=new Point(stageX, stageY);
			
			currMouseClicks++;
		
			if(currMouseClicks==4)
			{
				//trace("zeichnen jetzt!"+_root.mouseSaves[1]);
			
				this.setSections(2);
				curveObjects[0].create(mouseSaves[0], mouseSaves[1], mouseSaves[2], mouseSaves[3]);
				//var linie = new CurvedLine(_root.mouseSaves[0], _root.mouseSaves[1], _root.mouseSaves[2]);
				//_root.attachMovie('MC','neuMC',_root.getNextHighestDepth(),linie);
				
				currMouseClicks=0;
			}
		}
		
		public function createCurve(begin:Point, control1:Point, control2:Point, end:Point, canvas:Sprite):Boolean
		{
			return curveObjects[0].create(begin, control1, control2, end, canvas);
		}
		
		/********************************
		getters and setters
		********************************/
		
		public function setGuide(flag:Boolean):void{
			drawGuideFlag=flag;
		}
		public function getGuide():Boolean{
			return drawGuideFlag;
		}
		public function setFilling(flag:Boolean):void{
			fillingFlag=flag;
		}
		public function getFilling():Boolean{
			return fillingFlag;
		}
		
		public function setShift(flag:Boolean):void{
			shiftFlag=flag;
		}
		public function getShift():Boolean{
			return shiftFlag;
		}
		public function setCircles(flag:Boolean):void{
			drawCircleFlag=flag;
		}
		public function getCircles():Boolean{
			return drawCircleFlag;
		}
		public function setSections(num:Number):void{
			numSections=num;
		}
		public function getSections():Number{
			return numSections;
		}
		
		public function Process()
		{
			for each(var obj:Object in curveObjects)
			{
				(obj as CurvedLine).Process();
			}
		}
		
		public function draw()
		{
			for each(var obj:Object in curveObjects)
			{
				(obj as CurvedLine).draw();
			}
		} // draw function
	} //class CurvedLine
}