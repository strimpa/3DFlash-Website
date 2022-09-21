package ThreeDPack
{
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class CurvedLineManager extends Sprite
	{
		static var curveObjects:Array;
		
		static var numPointsOnSection:Number = 20;
		static var numSections:Number = 2;
		
		static var drawCrossesFlag:Boolean=true;
		static var drawGuideFlag:Boolean=false;
		static var drawCurveFlag:Boolean=true;
		static var shiftFlag:Boolean=true;
		static var drawCircleFlag:Boolean=true;
		static var fillingFlag:Boolean = false;
		static var mRadius:Number = 50;
		
		// new
		static var mouseSaves:Array;
		static var currMouseClicks:Number;
		static var colour:Number;
		
		public static var allPointsCurvedOld:Array;
		public static var firstExecution:Boolean = true;

		static var reset:Boolean = false;
		
		public function CurvedLineManager():void
		{
			allPointsCurvedOld = new Array();
			curveObjects = new Array();
			mouseSaves = new Array();
			currMouseClicks = 0;
			colour = 0x3F3333;
		}
		
		public static function doReset():void
		{
//			curveObjects[0].graphics.clear();
			allPointsCurvedOld = new Array();
			firstExecution = true;
			reset = true;
		}
		
		/***************************************************************************
		EVent handlers functions
		****************************************************************************/

		public static function registerPosition(stageX:Number, stageY:Number):void
		{
			var error = undefined;
			error.draw();
			
			mouseSaves[currMouseClicks]=new Point(stageX, stageY);
			
			currMouseClicks++;
		
			if(currMouseClicks==4)
			{
				//trace("zeichnen jetzt!"+_root.mouseSaves[1]);
			
				CurvedLineManager.setSections(2);
				curveObjects[0].create(mouseSaves[0], mouseSaves[1], mouseSaves[2], mouseSaves[3]);
				//var linie = new CurvedLine(_root.mouseSaves[0], _root.mouseSaves[1], _root.mouseSaves[2]);
				//_root.attachMovie('MC','neuMC',_root.getNextHighestDepth(),linie);
				
				currMouseClicks=0;
			}
		}
		
		public static function createCurve(begin:Point, control1:Point, control2:Point, end:Point, canvas:Sprite):CurvedLine
		{
			var newLine:CurvedLine = new CurvedLine();
			curveObjects.push(newLine);
			if (newLine.myCanvas)
			{
				newLine.myCanvas.graphics.clear();
			}
			var success:Boolean = newLine.create(begin, control1, control2, end, canvas);
			if (reset)
			{
//				newLine.animIndex = 0;
				reset = false;
			}
			
			return newLine;
		}
		
		/********************************
		getters and setters
		********************************/
		
		public static function setGuide(flag:Boolean):void{
			drawGuideFlag=flag;
		}
		public static function getGuide():Boolean{
			return drawGuideFlag;
		}
		public static function setFilling(flag:Boolean):void{
			fillingFlag=flag;
		}
		public static function getFilling():Boolean{
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
		public static function setSections(num:Number):void {
			doReset();
			numSections=num;
		}
		public function getSections():Number{
			return numSections;
		}
		public static function setRadius(newRadius:Number)
		{
			mRadius = newRadius;
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
			var counter:uint = 0;
			for each(var obj:Object in curveObjects)
			{
				(obj as CurvedLine).draw();
//				trace("render curve no:"+counter++);
			}
		} // draw function
	} //class CurvedLine
}