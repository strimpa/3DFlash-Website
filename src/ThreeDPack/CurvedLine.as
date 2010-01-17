package ThreeDPack
{
	import flash.geom.Point;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	public class CurvedLine
	{
		private var begin:Point;
		private var control1:Point;
		private var control2:Point;
		private var end:Point;
		private var allBegins:Array;
		private var allControls:Array;
		//private var allControls2:Array;
		private var allEnds:Array;
		private var allJoins:Array;
		private var tempEnds:Array;
		private var tempEndIndex:Number = 0;
		private var currSection:Number;
		private var currPoint:Number;
		private var middlePoints1:Point;
		private var middlePoints2:Point;
		private var middlePoints3:Point;
		private var fillingFlag:Boolean = true;
		private var mRadius:Number = 50;
		
		private var allPointsGuide:Array;
		private var allPointsCurvedNew:Array;
		private var allPointsCurvedOld:Array;
		private var allPointsCurvedCurr:Array;
		private var testPoints:Array;
		
		private var animating:Boolean=false;
		public var animIndex:Number=0;
		private const animDuration:Number = 5;
		
		public var myCanvas:Sprite;
		
		public function CurvedLine()
		{
			allBegins = new Array();
			allControls= new Array();
			allPointsGuide = new Array();
			allPointsCurvedNew = new Array();
			allPointsCurvedOld = new Array();
			allPointsCurvedCurr = new Array();
			testPoints = new Array();
		}
		
		public function deleteMe():void
		{
			var myIndex:uint = CurvedLineManager.curveObjects.indexOf(this);
			CurvedLineManager.curveObjects.splice(myIndex, 1);
		}
		
		/***************************************************************************
		math helper functions
		****************************************************************************/
		
		private function getPointOnBezierLine(begin:Point, control1:Point, control2:Point, end:Point, t:Number):Point
		{
			var firstSecPoint:Point;
			var secondSecPoint:Point;
			var thirdSecPoint:Point;
			var fourthSecPoint:Point;
					
			var currPercentage:Number = t/CurvedLineManager.numPointsOnSection;
			
			firstSecPoint = new Point(begin.x+((control1.x-begin.x)*currPercentage),
									  begin.y+((control1.y-begin.y)*currPercentage));
			secondSecPoint = new Point(control1.x+((control2.x-control1.x)*currPercentage),
									   control1.y+((control2.y-control1.y)*currPercentage));
			thirdSecPoint = new Point(control2.x+((end.x-control2.x)*currPercentage),
									  control2.y+((end.y-control2.y)*currPercentage));
	
			fourthSecPoint = new Point(firstSecPoint.x+((secondSecPoint.x-firstSecPoint.x)*currPercentage),
							 		   firstSecPoint.y+((secondSecPoint.y-firstSecPoint.y)*currPercentage));
			firstSecPoint =  new Point(secondSecPoint.x+((thirdSecPoint.x-secondSecPoint.x)*currPercentage),
							 		   secondSecPoint.y+((thirdSecPoint.y-secondSecPoint.y)*currPercentage));
			
			return new Point(fourthSecPoint.x+((firstSecPoint.x-fourthSecPoint.x)*currPercentage),
							 fourthSecPoint.y+((firstSecPoint.y-fourthSecPoint.y)*currPercentage));
		}
			
		//calculate the depth to go in calculation for number of sections (2 risen by ?)
		private function getNumOfLevels(sections:Number):Number{
			var back:Number=0;
			while(sections/2>1){
				sections/=2;
				back++;
			}
//			trace(back);
			return back;
		}
		
		private function fillUpControls(beginIndex:Number, fillcontrol1:Point, fillcontrol2:Point, endIndex:Number, wantedDepth:Number, currDepth:Number):void{
			var newControls:Array = subdivideBezier(allPointsGuide[beginIndex], fillcontrol1, fillcontrol2, allPointsGuide[endIndex]);
			if(currDepth<wantedDepth){
				var joinIndex:Number = Math.round(beginIndex+(endIndex-beginIndex)/2);
				var theJoin:Point = allPointsGuide[joinIndex];
				//trace("depth:"+currDepth+", fillbegin: "+allPointsGuide[beginIndex]+", fillcontrol1: "+fillcontrol1+", fillcontrol2: "+fillcontrol2+", fillend:"+allPointsGuide[endIndex]);
				fillUpControls(beginIndex, newControls[0], newControls[1], joinIndex, wantedDepth, currDepth+1);
				fillUpControls(joinIndex, newControls[2], newControls[3], endIndex, wantedDepth, currDepth+1);
			}else if(currDepth==wantedDepth){
				//trace("depth:"+currDepth+", fillbegin: "+allPointsGuide[beginIndex]+", fillcontrol1: "+fillcontrol1+", fillcontrol2: "+fillcontrol2+", fillend:"+allPointsGuide[endIndex]);
				tempEnds[tempEndIndex++] = endIndex;
				allControls = allControls.concat(newControls);
			}
		}
	
		private function subdivideBezier(bezierBegin:Point, bezierControl1:Point, bezierControl2:Point, bezierEnd:Point):Array{
				
			var returnControls:Array = new Array(4);
			// save middlepoints
			middlePoints1=new Point((bezierBegin.x+(bezierControl1.x-bezierBegin.x)/2),
									   (bezierBegin.y+(bezierControl1.y-bezierBegin.y)/2));
			middlePoints2=new Point((bezierControl1.x+(bezierControl2.x-bezierControl1.x)/2),
									   (bezierControl1.y+(bezierControl2.y-bezierControl1.y)/2));
			middlePoints3=new Point((bezierControl2.x+(bezierEnd.x-bezierControl2.x)/2),
									   (bezierControl2.y+(bezierEnd.y-bezierControl2.y)/2));
	
			// control points
			returnControls[0] = middlePoints1;
			returnControls[1] = new Point(middlePoints1.x+((middlePoints2.x-middlePoints1.x)/2),
										middlePoints1.y+((middlePoints2.y-middlePoints1.y)/2));
			returnControls[2] = new Point(middlePoints2.x+((middlePoints3.x-middlePoints2.x)/2),
										middlePoints2.y+((middlePoints3.y-middlePoints2.y)/2));
			returnControls[3] = middlePoints3;
			
			return returnControls;
		
		}
		
	    /***************************************************
		public invokation functions
		***************************************************/
		
		public function create(begin:Point, control1:Point, control2:Point, end:Point, canvas:Sprite):Boolean
		{
//			if(animIndex>animDuration/2)
//				return false;

			myCanvas = canvas;
			
			allPointsGuide = new Array(CurvedLineManager.numPointsOnSection);
			allPointsCurvedNew = new Array(CurvedLineManager.numPointsOnSection*CurvedLineManager.numSections);
			allJoins = new Array(CurvedLineManager.numSections-1);
			allControls = new Array();
			allBegins = new Array(CurvedLineManager.numSections);
			allEnds = new Array(CurvedLineManager.numSections);
			tempEnds = new Array(CurvedLineManager.numSections);
			testPoints = new Array();
			fillingFlag = CurvedLineManager.fillingFlag;
			mRadius = CurvedLineManager.mRadius;
	
			this.begin=begin;
			this.control1=control1;
			this.control2=control2;
			this.end=end;
			
			allControls = new Array();
			tempEndIndex = 0;
			
			if (CurvedLineManager.allPointsCurvedOld.length>0)
			{
				for each(var punkt:Point in CurvedLineManager.allPointsCurvedOld)
					allPointsCurvedOld.push(punkt);
			}
			
//			trace("numSections:"+numSections);
			if(CurvedLineManager.numSections>0 && CurvedLineManager.numSections%2==0){
				//guideLine
				for(var i:uint=0;i<CurvedLineManager.numPointsOnSection;i++){
					allPointsGuide[i]=getPointOnBezierLine(begin, control1, control2, end, i);
				}
				allPointsGuide[CurvedLineManager.numPointsOnSection]=end;
				
				//gerate controlPoints
				for(var j:uint=0;j<CurvedLineManager.numSections-1;j++){
					//trace("joins at: "+Math.floor((numPointsOnSection/numSections)*(j+1)));
					allJoins[j]=allPointsGuide[Math.floor((CurvedLineManager.numPointsOnSection/CurvedLineManager.numSections)*(j+1))];
				}
				
				
				//trace("numSections"+numSections);
				for(var mVar:uint=0;mVar<CurvedLineManager.numSections;mVar++){
					if(mVar==0){
						allBegins[mVar] = begin.clone();
						allEnds[mVar] = allJoins[mVar].clone();
					}else if(mVar<(CurvedLineManager.numSections-1)){
						allBegins[mVar] = allJoins[mVar-1].clone();
						allEnds[mVar] = allJoins[mVar].clone();
					}else {
						allBegins[mVar] = allJoins[mVar-1].clone();
						allEnds[mVar] = end.clone();
					}
				}
				
				if(CurvedLineManager.shiftFlag){
					for(var shift:uint=0;shift<CurvedLineManager.numSections;shift++){
						allBegins[shift].x+=Math.random()*30-15;
						allBegins[shift].y+=Math.random()*30-15;
						allEnds[shift].x+=Math.random()*30-15;
						allEnds[shift].y+=Math.random()*30-15;
					}
				}
	
				var theDepth:Number = getNumOfLevels(CurvedLineManager.numSections);
				fillUpControls(0, control1, control2, CurvedLineManager.numPointsOnSection, theDepth, 0);
				
	
				if(CurvedLineManager.drawCircleFlag){
					var countDown:Number=0;
					for(countDown=allEnds.length-1;countDown >= 0; countDown--){
						
						//trace("countDown:"+countDown+", "+this.allBegins[8]+", "+this.allBegins[countDown]);
						var punkt:Point = allEnds[countDown];
						var lastPoint:Point = allBegins[countDown];
						//trace("lastPoint:"+lastPoint);
						var newBegins:Array = new Array(); // all new Curve Points = 8points to sting, 8 points back, ...
						var newEnds:Array = new Array();
						var newControls1:Array = new Array();
						var newControls2:Array = new Array();
						
						var radius:Number = (mRadius/5)+Math.random()*mRadius;
						var angleRand:Number = -1+Math.random()*3;
						var angle:Number = (angleRand<=0)?-90:90;
						var vectorToRotate:Point = lastPoint.subtract(punkt);
						vectorToRotate.normalize(radius);
						var rotatedVec:Point = new Point(vectorToRotate.x*Math.cos(angle)+vectorToRotate.x*(-Math.sin(angle)), 
														 vectorToRotate.y*Math.sin(angle)+vectorToRotate.y*( Math.cos(angle)));
						
						newBegins[0] = punkt.clone();
						newEnds[0] = new Point(newBegins[0].x+vectorToRotate.x+rotatedVec.x, 
											   newBegins[0].y+vectorToRotate.y+rotatedVec.y);
						newControls1[0] = new Point(newBegins[0].x+vectorToRotate.x/2, newBegins[0].y+vectorToRotate.y/2);
						testPoints.push(newControls1[0]);
						newControls2[0] = new Point(newEnds[0].x-rotatedVec.x/2, newEnds[0].y-rotatedVec.y/2);
						testPoints.push(newControls2[0]);
		
	
						newBegins[1] = newEnds[0].clone();
						newEnds[1] = new Point(newBegins[1].x-vectorToRotate.x+rotatedVec.x, 
											   newBegins[1].y-vectorToRotate.y+rotatedVec.y);
						newControls1[1] = new Point(newBegins[1].x+(rotatedVec.x/2), newBegins[1].y+(rotatedVec.y/2));
						testPoints.push(newControls1[1]);
						newControls2[1] = new Point(newEnds[1].x+(vectorToRotate.x/2), newEnds[1].y+(vectorToRotate.y/2));
						testPoints.push(newControls2[1]);
		
						
						vectorToRotate.normalize(radius+2);
						newBegins[2] = newEnds[1];
						newEnds[2] = new Point(newBegins[2].x+vectorToRotate.x-rotatedVec.x, 
											   newBegins[2].y+vectorToRotate.y-rotatedVec.y);
						newControls1[2] = new Point(newBegins[2].x+vectorToRotate.x/2, newBegins[2].y+vectorToRotate.y/2);
						newControls2[2] = new Point(newEnds[2].x+rotatedVec.x/2, newEnds[2].y+rotatedVec.y/2);
		
						vectorToRotate.normalize(radius+4);
						newBegins[3] = newEnds[2];
						newEnds[3] = new Point(punkt.x+vectorToRotate.x+rotatedVec.x/2, 
											   punkt.y+vectorToRotate.y+rotatedVec.y/2);
						newControls1[3] = new Point(newBegins[3].x-rotatedVec.x/2, newBegins[3].y-rotatedVec.y/2);
						newControls2[3] = new Point(newEnds[3].x+vectorToRotate.x/4, newEnds[3].y+vectorToRotate.y/4);
	
						newBegins[4] = newEnds[3];
						newEnds[4] = lastPoint;
						var middleControl:Point = punkt;//new Point(newBegins[4].x-punkt.x, newBegins[4].y-punkt.y);
						newControls1[4] = allControls[countDown*2+1]; //new Point(newBegins[4].x+((middleControl.x-newBegins[4].x)/2), newBegins[4].y+((middleControl.y-newBegins[4].y)/2));
						newControls2[4] = allControls[countDown*2]; //new Point(newEnds[4].x+((middleControl.x-newEnds[4].x)/2), newEnds[4].y+((middleControl.y-newEnds[4].y)/2));
	
						
						//trace("newBegins:"+newBegins);
	/*
						allBegins.splice(countDown, 1);
						allControls.splice((countDown*2), 1);
						allEnds.splice(countDown, 1);
	*/					for(var newCurvesI:uint=0;newCurvesI<newBegins.length;newCurvesI++){
							allBegins.splice(countDown+newCurvesI, 0, newBegins[newCurvesI]);
							allControls.splice(((countDown*2)+(newCurvesI*2)), 0, newControls1[newCurvesI], newControls2[newCurvesI]);
							allEnds.splice(countDown+newCurvesI, 0, newEnds[newCurvesI]);
						}
							
					}
					
				}
		
				
				
			
				for(var v:uint=0;v<allBegins.length;v++){
					var offset:Number = (v*CurvedLineManager.numPointsOnSection);
					for(var i2:uint=0;i2<CurvedLineManager.numPointsOnSection;i2++){
						allPointsCurvedNew[offset+i2]=getPointOnBezierLine(allBegins[v], allControls[v*2], allControls[v*2+1], allEnds[v], i2);
					}
	//				trace("v:"+v);
				}
			}

			CurvedLineManager.allPointsCurvedOld = allPointsCurvedNew;
			if(!CurvedLineManager.firstExecution)
			{
				animIndex = animDuration;
				//trace("anim started.");//+animIndex+" allPointsCurvedOld 1:"+allPointsCurvedOld
				trace("allPointsCurvedNew.length:"+allPointsCurvedNew.length+", allPointsCurvedOld.length:"+allPointsCurvedOld.length);
			}
			else
			{
				CurvedLineManager.firstExecution = false;
			}
			return true;
		} // calculate
		
	
		private function drawCross(graphics:Graphics, punkt:Point):void{
			if(CurvedLineManager.drawCrossesFlag){
				graphics.moveTo(punkt.x-2, punkt.y-2);
				graphics.lineTo(punkt.x+2, punkt.y+2);
				graphics.moveTo(punkt.x-2, punkt.y+2);
				graphics.lineTo(punkt.x+2, punkt.y-2);
			}
		}
		
		private function drawCircle(graphics:Graphics, punkt:Point, radius:Number):void{
			graphics.moveTo(punkt.x-radius, punkt.y);
			graphics.curveTo(punkt.x-radius, punkt.y-radius, punkt.x, 		 punkt.y-radius);
			graphics.curveTo(punkt.x+radius, punkt.y-radius, punkt.x+radius, punkt.y);
			graphics.curveTo(punkt.x+radius, punkt.y+radius, punkt.x, 		 punkt.y+radius);
			graphics.curveTo(punkt.x-radius, punkt.y+radius, punkt.x-radius, punkt.y);
		}
		
		private function drawDecoCircle(graphics:Graphics, punkt:Point, radius:Number, nextPoint:Point):void{
			var angle:Number = -90;
			var vectorToRotate:Point = nextPoint.subtract(punkt);
			vectorToRotate.normalize(radius);
			var rotatedVec:Point = new Point(vectorToRotate.x*Math.cos(angle)+vectorToRotate.x*(-Math.sin(angle)), 
											 vectorToRotate.y*Math.sin(angle)+vectorToRotate.y*( Math.cos(angle)));
			var shorter:Point = vectorToRotate.clone(); shorter.normalize(3);
			var shorterRotated:Point = rotatedVec.clone(); shorterRotated.normalize(3);
			
			graphics.moveTo(punkt.x, punkt.y);
		//	this.lineTo(punkt.x+vectorToRotate.x, punkt.y+vectorToRotate.y);
		//	this.moveTo(punkt.x, punkt.y);
		//	this.lineTo(punkt.x+rotatedVec.x, punkt.y+rotatedVec.y);
			
			graphics.lineStyle(1, 0xFF0000, 100);
			graphics.curveTo(punkt.x+rotatedVec.x, 						punkt.y+rotatedVec.y, 						punkt.x+rotatedVec.x+vectorToRotate.x, 	punkt.y+rotatedVec.y+vectorToRotate.y);
			graphics.curveTo(punkt.x+rotatedVec.x+vectorToRotate.x*1.8, punkt.y+rotatedVec.y+vectorToRotate.y*1.8, 	punkt.x+vectorToRotate.x*1.8, 			punkt.y+vectorToRotate.y*1.8);
			graphics.curveTo(punkt.x-rotatedVec.x*0.7+vectorToRotate.x*1.5, punkt.y-rotatedVec.y*0.7+vectorToRotate.y*1.5, 	punkt.x-rotatedVec.x+vectorToRotate.x, 	punkt.y-rotatedVec.y+vectorToRotate.y);
			//turn
			graphics.lineStyle(1, 0x0000FF, 100);
			graphics.curveTo(punkt.x-shorterRotated.x+shorter.x*2,		punkt.y-shorterRotated.y+shorter.y*2,		punkt.x+shorter.x*2, 					punkt.y+shorter.y*2);
			graphics.curveTo(punkt.x+shorterRotated.x+shorter.x*2,		punkt.y+shorterRotated.y+shorter.y*2, 		punkt.x+shorterRotated.x+shorter.x*2,	punkt.y+shorterRotated.y+shorter.y*2);
			graphics.curveTo(punkt.x+shorterRotated.x,					punkt.y+shorterRotated.y, 					punkt.x-2,							 	punkt.y-2);
			//this.curveTo(punkt.x-radius, punkt.y+radius, punkt.x-radius, punkt.y);
			
		}
	
	
		public function Process():void
		{
			var graphics:Graphics = myCanvas.graphics;
			if(animIndex>0)
			{
				allPointsCurvedCurr = new Array(allPointsCurvedNew.length);
				var pointIndex:Number=0; 
//				trace("allPointsCurvedNew:"+allPointsCurvedNew);
//				trace("allPointsCurvedOld:"+allPointsCurvedOld);
				if(allPointsCurvedNew.length==0||allPointsCurvedOld.length==0)
				{
					trace("allPointsCurvedNew.length==0||allPointsCurvedOld.length==0");
					allPointsCurvedCurr = allPointsCurvedNew;
					return;
				}
				for each(var punkt:Point in allPointsCurvedNew)
				{
					allPointsCurvedCurr[pointIndex] = Point.interpolate(allPointsCurvedOld[pointIndex], punkt, animIndex/animDuration);
					pointIndex++;
				}
				graphics.clear();
//				trace("animIndex:"+animIndex);
				animIndex--;
			}
			else
			{
				allPointsCurvedCurr = allPointsCurvedNew;
			}
			
			if(myCanvas==undefined)
				return;
		}
		
		public function draw():void
		{
			if(myCanvas==undefined)
				return;
				
			var graphics:Graphics = myCanvas.graphics;
			if(allPointsCurvedCurr.length<1)// || animIndex==0)
			{
//				trace("allPointsCurvedCurr.length<1");
				return;
			}
				
			//var glow:Sprite = ThreeDCanvas.glowSprite;
			
			var circleDrawIndex:uint=0;
			var currIntervalBegin:uint=0;
	
	/*		for(var b=0;b<allControls.length;b++){
				this.lineStyle(1, 0xFF0000*((b%4)/4), 100, false, "none");
				//trace("allControls["+b+"]: "+allControls[b]);
				drawCross(allControls[b]);
			}
			this.lineStyle(1, 0x0000FF, 100);
				trace("allControls[b]: "+allControls[b*2]);
				drawCross(allControls[b*2]);
				trace("allControls[b+1]: "+allControls[b*2+1]);
				drawCross(allControls[b*2+1]);
			}
			this.lineStyle(1, 0xFF0000, 100);
			drawCross(begin);
			drawCross(control1);
			drawCross(control2);
			drawCross(end);*/
	
			//curved
			graphics.lineStyle(1, 0x666666, 100, false, "none");
			
			//Guide
			if(CurvedLineManager.drawGuideFlag){
				graphics.moveTo(allPointsGuide[0].x, allPointsGuide[0].y);
				for(var k2:uint=1;k2<allPointsGuide.length;k2++){
					graphics.lineTo(allPointsGuide[k2].x, allPointsGuide[k2].y);
				}
			}
	
			var colorSwop:Boolean=true;

	
			if(fillingFlag)graphics.beginFill(CurvedLineManager.colour, 50);
			graphics.moveTo(allPointsCurvedCurr[0].x, allPointsCurvedCurr[0].y);
			for(var k:uint=1;k<allPointsCurvedCurr.length;k++){
				graphics.lineTo(allPointsCurvedCurr[k].x, allPointsCurvedCurr[k].y);
				if(CurvedLineManager.drawCircleFlag && (k+1)%(CurvedLineManager.numPointsOnSection*6)==0){
					//circleDrawIndex--;
					if(circleDrawIndex==0){
	/*					if(colorSwop){
							this.lineStyle(1, 0x00FF00, 100);
							colorSwop=false;
						}
						else {
							this.lineStyle(1, 0x0000FF, 100);
							colorSwop=true;
						}
	*/					graphics.lineTo(allPointsCurvedCurr[k-(CurvedLineManager.numPointsOnSection*6-1)].x, allPointsCurvedCurr[k-(CurvedLineManager.numPointsOnSection*6-1)].y);

					// if more to come
						if(k+5<allPointsCurvedCurr.length)
						{
//							trace("more to come");
							k+=5;
							//drawCross(allPointsCurvedCurr[k]);
							graphics.moveTo(allPointsCurvedCurr[k].x, allPointsCurvedCurr[k].y);
						}
					}
				}
			}
			if (fillingFlag) graphics.endFill();
			
			if (animIndex <= 0 )
				deleteMe();

		} // draw function
	} //class CurvedLine
}