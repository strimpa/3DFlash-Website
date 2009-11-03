﻿package ThreeDPack
{
	import flash.events.MouseEvent;
	import flash.display.*;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Matrix;

	public class Polygon extends DrawElement
	{
		var COLLAPSED:uint = 0,
			EXTENDING:uint = 1,
			EXTENDED:uint = 2,
			COLLAPSING:uint = 3;
		private var mCurrState:uint;

		var parentObj:ThreeDObject;
		var unsortedIndex:Number;
		var pointIndices:Array;
		var adjacencyIndices:Array;
		var normalIndices:Array;
		var smoothingGroup:Number; 
		public var depth1:Number=0;
		public var depth2:Number=0;
		var opacity:Number=100;
		public var colour:Number;
		
	// new point calculation
	//	var points:Array;
	
	// movement related things
		public var faceNormal:ThreeDPoint;
		public var moveMatrix:ThreeDMatrix; 
		public var pendingMovements:Array;	
		public var movementIndex:Number=0;
		public var moving:Boolean=false;
		public var otherElementParts:Array;
		public var movePercentage:Number;
		
		public function Polygon(points_p:Array, unsortedIndex:uint, parent:ThreeDObject=undefined, normals:Array=undefined, copyPropsFrom:Polygon=undefined):void{
			this.pointIndices = points_p;
			this.parentObj = parent;
			this.unsortedIndex = unsortedIndex;
			if(normals!=undefined)
			{
				this.normalIndices = new Array(normals.length);
				for(var normalCopy in normals)
					normalIndices[normalCopy] = normals[normalCopy];
			}
			if(parent!=undefined)
				this.colour = parent.colour;
	//		this.calcDepth();
			if(copyPropsFrom!=undefined)
			{
				pointIndices = copyPropsFrom.pointIndices;
				opacity = copyPropsFrom.opacity;
				colour = copyPropsFrom.colour;
			}
			alpha = 0.8;
			pendingMovements = new Array(0);
			moveMatrix = new ThreeDMatrix();
			otherElementParts = new Array();
			mCurrState = COLLAPSED;
		}
		
		public function calcFaceNormal():void
		{
			if(!parentObj || parentObj.normals==undefined || parentObj.normals.length<=0 || normalIndices==undefined)
				return;
				
//			trace(parentObj.name+", "+parentObj.normals.length);
				
			faceNormal = new ThreeDPoint(0,0,0);
			for(var normalIndex:Number=0;normalIndex<normalIndices.length;normalIndex++)
			{
//				trace("normalIndex:"+normalIndex+", normalIndex:"+normalIndices[normalIndex]);
//				trace("parentObj.normals[normalIndices[normalIndex]]:"+parentObj.normals[normalIndices[normalIndex]]);
				faceNormal = faceNormal.plus(parentObj.normals[normalIndices[normalIndex]]);
			}
			faceNormal.divideMe(normalIndices.length);
//			trace("faceNormal: "+faceNormal);
		}
		
		public function calcDepth():void{
			if(undefined==this.parentObj)
				return;

			// closest point depth
//			for(var depthInd:Number=0; depthInd<pointIndices.length;depthInd++){
//				// begin init OR point closer than current depth
//				if(depthInd==0 || this.parentObj.renderPoints[this.pointIndices[depthInd]].z<this.depth1)
//					this.depth1=this.parentObj.renderPoints[this.pointIndices[depthInd]].z;
//			}

			// farest point depth
			for(var depthInd:Number=0; depthInd<pointIndices.length;depthInd++){
				// begin init OR point closer than current depth
				if(depthInd==0 || this.parentObj.renderPoints[this.pointIndices[depthInd]].z>this.depth1)
					this.depth1=this.parentObj.renderPoints[this.pointIndices[depthInd]].z;
			}
			// average depth
//			for(var depthInd:Number=0; depthInd<pointIndices.length;depthInd++){
//				var faceDepth:Number = this.parentObj.renderPoints[this.pointIndices[depthInd]].z; 
//				//trace("--"+faceDepth);
//				depth2+=faceDepth;
//			}
//			this.depth2/=pointIndices.length;

			// weighted middle
			var max:Number, min:Number;
			for(var depthInd2:Number=0; depthInd2<pointIndices.length;depthInd2++){
				// begin init OR point closer than current depth
				var currDepth:Number = this.parentObj.renderPoints[this.pointIndices[depthInd2]].z;
				if(depthInd2==0 || currDepth<min)
					min = currDepth;
				if(depthInd2==0 || currDepth>max)
					max = currDepth;
			}
			depth2 = min + (max-min)/2;
			
			depth1 *= 100;
			depth2 *= 100;

			this.opacity = -(this.depth1-50)/4;
			//trace("this.depth:"+this.depth);
		}
		
		public override function mouseOverHandler(event:MouseEvent):void
		{
			if(notMoveable())
				return;
			if(parentObj)
				parentObj.mouseOverHandler(event);
//			{
				parentObj.setPolyColour(true);
//			}
//			super.mouseOverHandler(event);
		}
	
		public override function mouseOutHandler(event:MouseEvent):void
		{
			if(notMoveable())
				return;
			if(parentObj && !moving)
				parentObj.mouseOutHandler(event);
//			{
				parentObj.setPolyColour(false);
//			}
//			super.mouseOutHandler(event);
		}
		
		public override function mouseClickHandler(event:MouseEvent):void
		{
			if(notMoveable())
				return;
			if(parentObj)// && !moving
				parentObj.mouseClickHandler(event);
//			jump();
//			for(var jumpIndex=0;jumpIndex<this.otherElementParts.length;jumpIndex++)
//				this.otherElementParts[jumpIndex].jump();
//			super.mouseClickHandler(event);
		}

		public override function mouseMoveHandler(event:MouseEvent):void
		{
			if(notMoveable())
				return;
			super.mouseMoveHandler(event);
			mouseOverHandler(event);
		} 

		public override function MouseDragHandler(event:MouseEvent):void
		{
			parentObj.MouseDragHandler(event);
		} 
		
		public function notMoveable():Boolean
		{
//			if(this.smoothingGroup>1)
				return false;
			return true;
		}

		public function processStates():void
		{
			if(EXTENDING==getState())//this.movementIndex<this.pendingMovements.length)
			{
				this.moving=true;
				colour = mouseOverColour;
				if(jumpLength==this.movementIndex)
				{
					setState(EXTENDED);
				}
				else
					this.movementIndex++;
			}
			else if(COLLAPSING==getState())
			{
				if(this.movementIndex<=0)
				{
					setState(COLLAPSED);
					this.movementIndex = 0;
					this.moving=false;

					if(parentObj!=undefined)
					{
						parentObj.ResetMovingPolyIndex(this.unsortedIndex);
						colour = parentObj.inactiveColour;
					}
					ThreeDCanvas.rotFlag = true;
				}
				else
					this.movementIndex--;
			}
		}
		public function moveStep():void
		{
			if(mCurrState==COLLAPSING || mCurrState==EXTENDING)
				this.moveMatrix=this.moveMatrix.mul(this.pendingMovements[this.movementIndex++]);
			var percentage = (this.movementIndex*3)/this.pendingMovements.length;
			this.movePercentage = percentage<0.3?percentage:(percentage>2.7?(percentage-3)/-1:0.3);
		}
		
		public function setState(state:uint)
		{
			ThreeDApp.output("set to state:"+state);
			mCurrState=state;
		}
		public function getState()
		{
			return mCurrState;
		}
		
		public function getGlowPercentage():Number
		{
			return parentObj.glowPercentage;
		}

		public function Process(parent:ThreeDObject):void
		{
			this.parentObj = parent;
			processStates();
//			moveStep();
//			if(moving)
//			{
//				parent.SetMovingPolyIndex(this.unsortedIndex);
//			}
			colour = parentObj.colour;
		}

		public function jump():void
		{
			if(!this.moving) 
			{
				// reseting values
				this.movementIndex=0;
				this.pendingMovements=new Array();
				var dir:ThreeDPoint = this.faceNormal;
				//				trace("moveVecs"+this.moveVecs+", requested index: "+dirIndex);
				//trace("value: "+faceNormal);
//				trace("this.unsortedIndex:"+this.unsortedIndex+", this.pointIndices:"+this.pointIndices);
				mCurrState = EXTENDING;
				dir.normalize(10);
				for(var jumpIndex:Number=0;jumpIndex<jumpLength;jumpIndex++){
					this.pendingMovements[jumpIndex]=new ThreeDMatrix();
					var multiplier:Number=(jumpIndex<jumpLength/2?(1/(jumpIndex+1)):-1/(jumpLength-jumpIndex));
					//trace("multiplier:"+multiplier);
					var currVec:ThreeDPoint = new ThreeDPoint(dir.x*multiplier, dir.y*multiplier, dir.z*multiplier);
					this.pendingMovements[jumpIndex].translate(currVec.x, currVec.y, currVec.z);
				}
//				trace("jump!"+this.pendingMovements);
			}
			if(mCurrState==EXTENDED)
			{
				mCurrState=COLLAPSING;
			}
		}

		public function draw(points:Array, normals:Array=undefined):void
		{
			graphics.clear(); // clearing for drawing with shading
			//currFace.blendMode = currFace.myObj.origObj.blendModes[currFace.myObj.originIndex[currFace.myIndex]];
			graphics.beginFill(colour, 1/*myObj.polygons[polyIndex].opacity*/);
//			var colouredBitmap:BitmapData = ThreeDApp.image.bitmapData.clone();//new BitmapData(600,400,true,0xFFFFFFFF);// = ThreeDApp.overlayBitmap;
//			var matrix:Matrix = new Matrix(); 
//			matrix.scale(1, 4);
//			if(moving)
//			{
//				var mask:uint = 0x000000FF;
//				var red:Number = ((colour>>16)&mask);
//				var green:Number = ((colour>>8)&mask);
//				var blue:Number = ((colour)&mask);
//				colouredBitmap.colorTransform(colouredBitmap.rect, new ColorTransform(0,0,0,1,red,green,blue));
//			}
//			graphics.beginBitmapFill(colouredBitmap,matrix);
//			var dep:Number = depth1;
//						trace("dep:"+dep);
//					if(dep)graphics.lineStyle((dep<=0?0.5:(dep+200)/100), 0x0000FF, /*(dep<=0?1:7/dep)*10*/100);
//					else 
			graphics.lineStyle(1, parentObj.borderColour, 1);
			// move to first Point
			var endPoint:ThreeDPoint = points[pointIndices[0]];
			if(endPoint==undefined)
			{	
				trace("error at point "+pointIndices[0]);
				return;
			}
//			trace("pointIndices:"+pointIndices);
			graphics.moveTo(endPoint.x, endPoint.y);
			
			for(var vertIndex:Number=1;vertIndex<=pointIndices.length;vertIndex++){
				var index:Number =  vertIndex<pointIndices.length?vertIndex:0;
				// on purpose vertIndex and index as index gets set yo 0 
				var renderTheEdge:Boolean = parentObj.renderEdge(pointIndices[vertIndex-1], pointIndices[index]);
				var currPoint:ThreeDPoint = points[pointIndices[index]];
				if(currPoint==undefined)
				{	
					trace("error at point "+pointIndices[index]);
					continue;
				}
				//trace("vertIndex:"+vertIndex+", currPoint:"+currPoint.x+", "+currPoint.y);
				if(renderTheEdge)// || moving
					graphics.lineStyle(2, parentObj.borderColour, 1);
				else
					graphics.lineStyle(1, parentObj.borderColour, 0);
				graphics.lineTo(currPoint.x, currPoint.y);
			}
//			graphics.lineTo(endPoint.x, endPoint.y);
			graphics.endFill();
			
			if(ThreeDCanvas.drawNormals)
			{
				for(var normalIndex:Number=0;normalIndex<pointIndices.length;normalIndex++){
					var currPoint:ThreeDPoint = points[pointIndices[normalIndex]];
					var currNormal:ThreeDPoint = normals[normalIndices[normalIndex]].clone();
					currNormal.scale(5);
					graphics.moveTo(currPoint.x, currPoint.y);
					graphics.lineTo(currPoint.x+currNormal.x, currPoint.y+currNormal.y);
				}
			}
		}
		
		public function tracePoints():void{
			trace("Polygon:"+pointIndices+"\n");
		}
	
		public function GetState():uint
		{
			return mCurrState;
		}
	}
	
}// package ThreeDCanvas 3DEngine