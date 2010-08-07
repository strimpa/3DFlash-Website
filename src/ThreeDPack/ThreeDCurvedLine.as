package ThreeDPack
{
	//import flash.geom.Point;
	import flash.display.Sprite;

	public class ThreeDCurvedLine extends Sprite{
		var begin:ThreeDPoint;
		var control1:ThreeDPoint;
		var control2:ThreeDPoint;
		var end:ThreeDPoint;
		var numSections:Number=2;
		var numPointsOnSection:Number = 40;
		var allBegins:Array;
		var allControls:Array;
		//var allControls2:Array;
		var allEnds:Array;
		var allJoins:Array;
		var tempEnds:Array;
		var tempEndIndex:Number = 0;
		var currSection:Number;
		var currPoint:Number;
		var middlePoints1:ThreeDPoint;
		var middlePoints2:ThreeDPoint;
		var middlePoints3:ThreeDPoint;
		
		var allPointsGuide:Array;
		var allPointsCurved:Array;
		var testPoints:Array;
		
		var drawCrossesFlag:Boolean=true;
		var drawGuideFlag:Boolean=false;
		var drawCurveFlag:Boolean=true;
		var shiftFlag:Boolean=true;
		var drawCircleFlag:Boolean=true;
		var fillingFlag:Boolean=true;
		
		public function ThreeDCurvedLine(){
			/**/
		}
		
		/***************************************************************************
		math helper functions
		****************************************************************************/
		
		private function getPointOnBezierLine(begin:ThreeDPoint, control1:ThreeDPoint, control2:ThreeDPoint, end:ThreeDPoint, t:Number):ThreeDPoint
		{
			var firstSecPoint:ThreeDPoint;
			var secondSecPoint:ThreeDPoint;
			var thirdSecPoint:ThreeDPoint;
			var fourthSecPoint:ThreeDPoint;
					
			var currPercentage:Number = t/numPointsOnSection;
			
			firstSecPoint = new ThreeDPoint(begin.x+((control1.x-begin.x)*currPercentage),
									  begin.y+((control1.y-begin.y)*currPercentage));
			secondSecPoint = new ThreeDPoint(control1.x+((control2.x-control1.x)*currPercentage),
									   control1.y+((control2.y-control1.y)*currPercentage));
			thirdSecPoint = new ThreeDPoint(control2.x+((end.x-control2.x)*currPercentage),
									  control2.y+((end.y-control2.y)*currPercentage));
	
			fourthSecPoint = new ThreeDPoint(firstSecPoint.x+((secondSecPoint.x-firstSecPoint.x)*currPercentage),
							 		   firstSecPoint.y+((secondSecPoint.y-firstSecPoint.y)*currPercentage));
			firstSecPoint =  new ThreeDPoint(secondSecPoint.x+((thirdSecPoint.x-secondSecPoint.x)*currPercentage),
							 		   secondSecPoint.y+((thirdSecPoint.y-secondSecPoint.y)*currPercentage));
			
			return new ThreeDPoint(fourthSecPoint.x+((firstSecPoint.x-fourthSecPoint.x)*currPercentage),
							 fourthSecPoint.y+((firstSecPoint.y-fourthSecPoint.y)*currPercentage));
		}
			
		//calculate the depth to go in calculation for number of sections (2 risen by ?)
		private function getNumOfLevels(sections:Number):Number
		{
			var back:Number=0;
			while(sections/2>1){
				sections/=2;
				back++;
			}
			trace(back);
			return back;
		}
		
		private function fillUpControls(beginIndex:Number, fillcontrol1:ThreeDPoint, fillcontrol2:ThreeDPoint, endIndex:Number, wantedDepth:Number, currDepth:Number):void
		{
			var newControls:Array = subdivideBezier(allPointsGuide[beginIndex], fillcontrol1, fillcontrol2, allPointsGuide[endIndex]);
			if(currDepth<wantedDepth){
				var joinIndex:Number = Math.round(beginIndex+(endIndex-beginIndex)/2);
				var theJoin:ThreeDPoint = allPointsGuide[joinIndex];
				//trace("depth:"+currDepth+", fillbegin: "+allPointsGuide[beginIndex]+", fillcontrol1: "+fillcontrol1+", fillcontrol2: "+fillcontrol2+", fillend:"+allPointsGuide[endIndex]);
				fillUpControls(beginIndex, newControls[0], newControls[1], joinIndex, wantedDepth, currDepth+1);
				fillUpControls(joinIndex, newControls[2], newControls[3], endIndex, wantedDepth, currDepth+1);
			}else if(currDepth==wantedDepth){
				//trace("depth:"+currDepth+", fillbegin: "+allPointsGuide[beginIndex]+", fillcontrol1: "+fillcontrol1+", fillcontrol2: "+fillcontrol2+", fillend:"+allPointsGuide[endIndex]);
				tempEnds[tempEndIndex++] = endIndex;
				allControls = allControls.concat(newControls);
			}
		}
	
		private function subdivideBezier(bezierBegin:ThreeDPoint, bezierControl1:ThreeDPoint, bezierControl2:ThreeDPoint, bezierEnd:ThreeDPoint):Array
		{
				
			var returnControls:Array = new Array(4);
			// save middlepoints
			middlePoints1=new ThreeDPoint((bezierBegin.x+(bezierControl1.x-bezierBegin.x)/2),
									   (bezierBegin.y+(bezierControl1.y-bezierBegin.y)/2));
			middlePoints2=new ThreeDPoint((bezierControl1.x+(bezierControl2.x-bezierControl1.x)/2),
									   (bezierControl1.y+(bezierControl2.y-bezierControl1.y)/2));
			middlePoints3=new ThreeDPoint((bezierControl2.x+(bezierEnd.x-bezierControl2.x)/2),
									   (bezierControl2.y+(bezierEnd.y-bezierControl2.y)/2));
	
			// control points
			returnControls[0] = middlePoints1;
			returnControls[1] = new ThreeDPoint(middlePoints1.x+((middlePoints2.x-middlePoints1.x)/2),
										middlePoints1.y+((middlePoints2.y-middlePoints1.y)/2));
			returnControls[2] = new ThreeDPoint(middlePoints2.x+((middlePoints3.x-middlePoints2.x)/2),
										middlePoints2.y+((middlePoints3.y-middlePoints2.y)/2));
			returnControls[3] = middlePoints3;
			
			return returnControls;
		
		}
		
	//	private function 
	
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
		
	    /***************************************************
		public invokation functions
		***************************************************/
		
		public function calculate(begin:ThreeDPoint, control1:ThreeDPoint, control2:ThreeDPoint, end:ThreeDPoint):void
		{
			allPointsGuide = new Array(numPointsOnSection);
			allPointsCurved = new Array(numPointsOnSection*numSections);
			allJoins = new Array(numSections-1);
			allControls = new Array();
			allBegins = new Array(numSections);
			allEnds = new Array(numSections);
			tempEnds = new Array(numSections);
			testPoints = new Array();
	
			this.begin=begin;
			this.control1=control1;
			this.control2=control2;
			this.end=end;
			
			allControls = new Array();
			tempEndIndex=0;
			
			if(numSections>0 && numSections%2==0){
				//guideLine
				for(var i:Number=0;i<numPointsOnSection;i++){
					allPointsGuide[i]=getPointOnBezierLine(begin, control1, control2, end, i);
				}
				allPointsGuide[numPointsOnSection]=end;
				
				//gerate controlPoints
				for(var j:Number=0;j<numSections-1;j++){
					//trace("joins at: "+Math.floor((numPointsOnSection/numSections)*(j+1)));
					allJoins[j]=allPointsGuide[Math.floor((numPointsOnSection/numSections)*(j+1))];
				}
				
				
				//trace("numSections"+numSections);
				for(var mVar:Number=0;mVar<numSections;mVar++){
					if(mVar==0){
						allBegins[mVar] = begin.clone();
						allEnds[mVar] = allJoins[mVar].clone();
					}else if(mVar<(numSections-1)){
						allBegins[mVar] = allJoins[mVar-1].clone();
						allEnds[mVar] = allJoins[mVar].clone();
					}else {
						allBegins[mVar] = allJoins[mVar-1].clone();
						allEnds[mVar] = end.clone();
					}
				}
				
				if(shiftFlag){
					for(var shift:Number=0;shift<numSections;shift++){
						allBegins[shift].x+=Math.random()*30-15;
						allBegins[shift].y+=Math.random()*30-15;
						allEnds[shift].x+=Math.random()*30-15;
						allEnds[shift].y+=Math.random()*30-15;
					}
				}
	
				var theDepth:Number = getNumOfLevels(numSections);
				fillUpControls(0, control1, control2, numPointsOnSection, theDepth, 0);
				
	
				if(drawCircleFlag){
					var countDown:Number=0;
					for(countDown=allEnds.length-1;countDown >= 0; countDown--){
						
						//trace("countDown:"+countDown+", "+this.allBegins[8]+", "+this.allBegins[countDown]);
						var punkt:ThreeDPoint = allEnds[countDown];
						var lastPoint:ThreeDPoint = allBegins[countDown];
						//trace("lastPoint:"+lastPoint);
						var newBegins:Array = new Array(); // all new Curve Points = 8points to sting, 8 points back, ...
						var newEnds:Array = new Array();
						var newControls1:Array = new Array();
						var newControls2:Array = new Array();
						
						var radius:Number = 10+Math.random()*50;
						var angleRand:Number = -1+Math.random()*3;
						var angle:Number = (angleRand<=0)?-90:90;
						var vectorToRotate:ThreeDPoint = lastPoint.minus(punkt);
						vectorToRotate.normalize(radius);
						var rotatedVec:ThreeDPoint = new ThreeDPoint(vectorToRotate.x*Math.cos(angle)+vectorToRotate.x*(-Math.sin(angle)), 
														 vectorToRotate.y*Math.sin(angle)+vectorToRotate.y*( Math.cos(angle)));
						
						newBegins[0] = punkt.clone();
						newEnds[0] = new ThreeDPoint(newBegins[0].x+vectorToRotate.x+rotatedVec.x, 
											   newBegins[0].y+vectorToRotate.y+rotatedVec.y);
						newControls1[0] = new ThreeDPoint(newBegins[0].x+vectorToRotate.x/2, newBegins[0].y+vectorToRotate.y/2);
						testPoints.push(newControls1[0]);
						newControls2[0] = new ThreeDPoint(newEnds[0].x-rotatedVec.x/2, newEnds[0].y-rotatedVec.y/2);
						testPoints.push(newControls2[0]);
		
	
						newBegins[1] = newEnds[0].clone();
						newEnds[1] = new ThreeDPoint(newBegins[1].x-vectorToRotate.x+rotatedVec.x, 
											   newBegins[1].y-vectorToRotate.y+rotatedVec.y);
						newControls1[1] = new ThreeDPoint(newBegins[1].x+(rotatedVec.x/2), newBegins[1].y+(rotatedVec.y/2));
						testPoints.push(newControls1[1]);
						newControls2[1] = new ThreeDPoint(newEnds[1].x+(vectorToRotate.x/2), newEnds[1].y+(vectorToRotate.y/2));
						testPoints.push(newControls2[1]);
		
						
						vectorToRotate.normalize(radius+2);
						newBegins[2] = newEnds[1];
						newEnds[2] = new ThreeDPoint(newBegins[2].x+vectorToRotate.x-rotatedVec.x, 
											   newBegins[2].y+vectorToRotate.y-rotatedVec.y);
						newControls1[2] = new ThreeDPoint(newBegins[2].x+vectorToRotate.x/2, newBegins[2].y+vectorToRotate.y/2);
						newControls2[2] = new ThreeDPoint(newEnds[2].x+rotatedVec.x/2, newEnds[2].y+rotatedVec.y/2);
		
						vectorToRotate.normalize(radius+4);
						newBegins[3] = newEnds[2];
						newEnds[3] = new ThreeDPoint(punkt.x+vectorToRotate.x+rotatedVec.x/2, 
											   punkt.y+vectorToRotate.y+rotatedVec.y/2);
						newControls1[3] = new ThreeDPoint(newBegins[3].x-rotatedVec.x/2, newBegins[3].y-rotatedVec.y/2);
						newControls2[3] = new ThreeDPoint(newEnds[3].x+vectorToRotate.x/4, newEnds[3].y+vectorToRotate.y/4);
	
						newBegins[4] = newEnds[3];
						newEnds[4] = lastPoint;
						var middleControl:ThreeDPoint = punkt;//new ThreeDPoint(newBegins[4].x-punkt.x, newBegins[4].y-punkt.y);
						newControls1[4] = allControls[countDown*2+1]; //new ThreeDPoint(newBegins[4].x+((middleControl.x-newBegins[4].x)/2), newBegins[4].y+((middleControl.y-newBegins[4].y)/2));
						newControls2[4] = allControls[countDown*2]; //new ThreeDPoint(newEnds[4].x+((middleControl.x-newEnds[4].x)/2), newEnds[4].y+((middleControl.y-newEnds[4].y)/2));
	
						
						//trace("newBegins:"+newBegins);
	/*
						allBegins.splice(countDown, 1);
						allControls.splice((countDown*2), 1);
						allEnds.splice(countDown, 1);
	*/					for(var newCurvesI:Number=0;newCurvesI<newBegins.length;newCurvesI++){
							allBegins.splice(countDown+newCurvesI, 0, newBegins[newCurvesI]);
							allControls.splice(((countDown*2)+(newCurvesI*2)), 0, newControls1[newCurvesI], newControls2[newCurvesI]);
							allEnds.splice(countDown+newCurvesI, 0, newEnds[newCurvesI]);
						}
							
					}
					
				}
		
				
				
			
				for(var v:Number=0;v<allBegins.length;v++){
					var offset:Number = (v*numPointsOnSection);
					for(var iCurve:Number=0;iCurve<numPointsOnSection;iCurve++){
						allPointsCurved[offset+iCurve]=getPointOnBezierLine(allBegins[v], allControls[v*2], allControls[v*2+1], allEnds[v], iCurve);
					}
	//				trace("v:"+v);
				}
			}
		}
		
	
		private function drawCross(punkt:ThreeDPoint):void
		{
			if(drawCrossesFlag){
				this.graphics.moveTo(punkt.x-2, punkt.y-2);
				this.graphics.lineTo(punkt.x+2, punkt.y+2);
				this.graphics.moveTo(punkt.x-2, punkt.y+2);
				this.graphics.lineTo(punkt.x+2, punkt.y-2);
			}
		}
		
		private function drawCircle(punkt:ThreeDPoint, radius:Number):void
		{
			 this.graphics.moveTo(punkt.x-radius, punkt.y);
			this.graphics.curveTo(punkt.x-radius, punkt.y-radius, punkt.x, 		 punkt.y-radius);
			this.graphics.curveTo(punkt.x+radius, punkt.y-radius, punkt.x+radius, punkt.y);
			this.graphics.curveTo(punkt.x+radius, punkt.y+radius, punkt.x, 		 punkt.y+radius);
			this.graphics.curveTo(punkt.x-radius, punkt.y+radius, punkt.x-radius, punkt.y);
		}
		/*
		private function drawCircle(punkt:ThreeDPoint, radius:Number, nextPoint:ThreeDPoint){
			var angle:Number = -90;
			var vectorToRotate:ThreeDPoint = nextPoint.subtract(punkt);
			vectorToRotate.normalize(radius);
			var rotatedVec:ThreeDPoint = new ThreeDPoint(vectorToRotate.x*Math.cos(angle)+vectorToRotate.x*(-Math.sin(angle)), 
											 vectorToRotate.y*Math.sin(angle)+vectorToRotate.y*( Math.cos(angle)));
			var shorter:ThreeDPoint = vectorToRotate.clone(); shorter.normalize(3);
			var shorterRotated:ThreeDPoint = rotatedVec.clone(); shorterRotated.normalize(3);
			
			this.graphics.moveTo(punkt.x, punkt.y);
		//	this.graphics.lineTo(punkt.x+vectorToRotate.x, punkt.y+vectorToRotate.y);
		//	this.graphics.moveTo(punkt.x, punkt.y);
		//	this.graphics.lineTo(punkt.x+rotatedVec.x, punkt.y+rotatedVec.y);
			
			this.graphics.lineStyle(1, 0xFF0000, 100);
			this.graphics.curveTo(punkt.x+rotatedVec.x, 						punkt.y+rotatedVec.y, 						punkt.x+rotatedVec.x+vectorToRotate.x, 	punkt.y+rotatedVec.y+vectorToRotate.y);
			this.graphics.curveTo(punkt.x+rotatedVec.x+vectorToRotate.x*1.8, punkt.y+rotatedVec.y+vectorToRotate.y*1.8, 	punkt.x+vectorToRotate.x*1.8, 			punkt.y+vectorToRotate.y*1.8);
			this.graphics.curveTo(punkt.x-rotatedVec.x*0.7+vectorToRotate.x*1.5, punkt.y-rotatedVec.y*0.7+vectorToRotate.y*1.5, 	punkt.x-rotatedVec.x+vectorToRotate.x, 	punkt.y-rotatedVec.y+vectorToRotate.y);
			//turn
			this.graphics.lineStyle(1, 0x0000FF, 100);
			this.graphics.curveTo(punkt.x-shorterRotated.x+shorter.x*2,		punkt.y-shorterRotated.y+shorter.y*2,		punkt.x+shorter.x*2, 					punkt.y+shorter.y*2);
			this.graphics.curveTo(punkt.x+shorterRotated.x+shorter.x*2,		punkt.y+shorterRotated.y+shorter.y*2, 		punkt.x+shorterRotated.x+shorter.x*2,	punkt.y+shorterRotated.y+shorter.y*2);
			this.graphics.curveTo(punkt.x+shorterRotated.x,					punkt.y+shorterRotated.y, 					punkt.x-2,							 	punkt.y-2);
			//this.graphics.curveTo(punkt.x-radius, punkt.y+radius, punkt.x-radius, punkt.y);
			
		}
	*/
		
		public function draw():void
		{
			var circleDrawIndex:Number=0;
			//var currIntervalBegin:Number=0;
	
	/*		for(var b=0;b<allControls.length;b++){
				this.graphics.lineStyle(1, 0xFF0000*((b%4)/4), 100, false, "none");
				//trace("allControls["+b+"]: "+allControls[b]);
				drawCross(allControls[b]);
			}
			this.graphics.lineStyle(1, 0x0000FF, 100);
				trace("allControls[b]: "+allControls[b*2]);
				drawCross(allControls[b*2]);
				trace("allControls[b+1]: "+allControls[b*2+1]);
				drawCross(allControls[b*2+1]);
			}
			this.graphics.lineStyle(1, 0xFF0000, 100);
			drawCross(begin);
			drawCross(control1);
			drawCross(control2);
			drawCross(end);*/
	
			//Guide
			var k:Number=1;
			if(drawGuideFlag){
				this.graphics.moveTo(allPointsGuide[0].x, allPointsGuide[0].y);
				for(k=1;k<allPointsGuide.length;k++){
					this.graphics.lineTo(allPointsGuide[k].x, allPointsGuide[k].y);
				}
			}
	
			//curved
			this.graphics.lineStyle(1, 0x444444, 100, false, "none");
			
			var colorSwop:Boolean=true;
	
			if(fillingFlag)this.graphics.beginFill(0xDDDDDD, 50);
			this.graphics.moveTo(allPointsCurved[0].x, allPointsCurved[0].y);
			for(k=1;k<allPointsCurved.length;k++){
				this.graphics.lineTo(allPointsCurved[k].x, allPointsCurved[k].y);
				if(drawCircleFlag && (k+1)%(numPointsOnSection*6)==0){
					//circleDrawIndex--;
					if(circleDrawIndex==0){
	/*					trace("k:"+k);
						if(colorSwop){
							this.graphics.lineStyle(1, 0x00FF00, 100);
							colorSwop=false;
						}
						else {
							this.graphics.lineStyle(1, 0x0000FF, 100);
							colorSwop=true;
						}
	*/					this.graphics.lineTo(allPointsCurved[k-(numPointsOnSection*6-1)].x, allPointsCurved[k-(numPointsOnSection*6-1)].y);
						k+=5;
						//drawCross(allPointsCurved[k]);
						this.graphics.moveTo(allPointsCurved[k].x, allPointsCurved[k].y);
					}
				}
			}
			if(fillingFlag)this.graphics.endFill();
		} // draw function
	} //class CurvedLine
}// package ThreeDCanvas 3DEngine