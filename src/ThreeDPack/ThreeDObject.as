package ThreeDPack
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class ThreeDObject extends DrawElement
	{
		public var points:Array;
		public var renderPoints:Array;
		public var normalsCalculated:Boolean;
		public var normals:Array;
		public var renderNormals:Array;
		public var position:ThreeDPoint;
		public var polygons:Array;
		private var edgeRenderFlags:Array;
//		public var moveVecs:Array;
		public var depth:Number;
		public var origObjInd:uint;
		private static var currActiveObject:int = -1;
		public var edgeSmoothing:Array;
		public var currAlpha:Number;
		
		public var myMatrixStack:Array;
		public var splitPolysOnMovement:Boolean = true;

		public var glowPercentage = 0;
		public var glowFactor = 0;
		
		public var currMovingPolyIndeces:Array;
		public var currMovingPolyPoints:Array = undefined;
		public var movingPointsCalculated:Boolean=false;
		
		public var lastForceVector:ThreeDPoint = undefined;
		public var forceDecay:Number = 0;
		
		public var dirty:Boolean = true;

		public var paintIndex:Array;			// temoral index in array newObjects
		public var pics:Array;

		public function ThreeDObject()
		{
			name="3dobject";
			this.points = new Array();
			this.renderPoints = new Array();
			this.renderNormals = new Array();
			this.polygons = new Array(0);
			this.paintIndex = new Array();
			// rotation & translation
			// scaled local transformation | scheduled local transformation | static world transformation
			this.myMatrixStack = new Array(new ThreeDMatrix());
			this.depth=0;
			currColour = 0x333333;
			this.borderColour = 0x3D3F3D;
			this.position = new ThreeDPoint(0,0,0);
			this.active = true;
			currAlpha = 0;
		}

		public override function setActive(act:Boolean=true)
		{
			super.setActive(act);
			for each(var p:Polygon in polygons)
				p.setActive(act);
//			trace("act? "+act);
		}
		
		public function setPolyColour(mouseOver:Boolean):void
		{
			if(!isMovable)
				return;
			if(mouseOver)
				this.currColour = mouseOverColour;
			else
				this.currColour = inactiveColour;
			for(var jumpIndex=0;jumpIndex<this.polygons.length;jumpIndex++)
			{
				this.polygons[jumpIndex].currColour = this.currColour;
			}
		}
		
		public function addPoly(poly:Polygon):void
		{
			polygons.push(poly);
			//			poly.unsortedIndex = polygons.length-1;
		}
		
		public function SetMovingPolyIndex(index:Number):void
		{
			if(undefined==this.currMovingPolyIndeces)
				this.currMovingPolyIndeces = new Array();
			this.currMovingPolyIndeces.push(index);
//			trace("name"+this.name+", SetMovingPolyIndex:"+this.currMovingPolyIndeces);
		}
		
		public function ResetMovingPolyIndex(index:Number):void
		{
//			trace(" ResetMovingPolyIndex()");
			if(undefined==this.currMovingPolyIndeces)
				return;
			this.currMovingPolyIndeces.splice(this.currMovingPolyIndeces.indexOf(index), 1);
			if(currMovingPolyIndeces.length==0)
				this.currMovingPolyPoints = undefined;
		}

		function addPicAt(index:Number, file_p:String):void
		{
			if(this.pics==undefined)this.pics=new Array();
			this.pics[index]=file_p;
		}
		
		function worldTransform(matrixStack:Array, origObjNum:Number):ThreeDObject
		{ 
			//var back:ThreeDObject = this.copy(origObjNum);
			matrixStack = myMatrixStack.concat(matrixStack);
			this.origObjInd = origObjNum;
//			if(normals!=undefined)
//				for(var pointIndex:Number=0; pointIndex<normals.length; pointIndex++)
//					renderNormals[pointIndex] = normals[pointIndex].clone();
			objToProj(matrixStack);
			matrixStack.splice(0,myMatrixStack.length);
			return this;
		}
		
		public override function OnCollapsed():void
		{
			KeywordManager.resetPositions();
			super.OnCollapsed();
			currActiveObject = -1;
		}
		
		protected function objToProj(matrixStack:Array):void
		{
			var pointAlreadyCalculated:Array = new Array(points.length);
			for(var pointIndex:Number=0; pointIndex<points.length; pointIndex++)
			{
//				var firstIndex:Boolean = pointIndex==0;
//				if(	this instanceof ThreeDSprite && !firstIndex)
//					matrixStack = new Array(ThreeDCanvas.viewMatrix).concat(matrixStack);
//
				renderPoints[pointIndex] = goThroughPoints(matrixStack, points[pointIndex]);
//
//				if(	this instanceof ThreeDSprite && !firstIndex)
//					matrixStack.splice(0,1);
			}
			if(currMovingPolyIndeces!=undefined)
			{
				currMovingPolyPoints = new Array();
				var newVertIndex = 0;
				for(var movingPolyIndex:Number=0;movingPolyIndex<currMovingPolyIndeces.length;movingPolyIndex++)
				{
					var movingPoly:Polygon = polygons[currMovingPolyIndeces[movingPolyIndex]];
					if(movingPoly==undefined)
					{
						trace("Error currMovingPolyIndeces[movingPolyIndex]:"+currMovingPolyIndeces+", at index"+movingPolyIndex);
						continue;
					}
					var polyMatrixStack:Array = new Array();
					if (movingPoly.moveMatrix != undefined)
					{
						polyMatrixStack[0] = movingPoly.moveMatrix;
//						trace(polyMatrixStack[0].Translation());
					}
					else 
						trace("No object transformation matrix!");
					polyMatrixStack = polyMatrixStack.concat(matrixStack);
					for(var pointIndex:Number=0;pointIndex<movingPoly.pointIndices.length;pointIndex++)
					{
						var currOriginalIndex:Number = movingPoly.pointIndices[pointIndex]; 
						var newIndex:uint = movingPoly.pointMoveIndices[pointIndex] = splitPolysOnMovement?newVertIndex++:currOriginalIndex;
						if(splitPolysOnMovement || pointAlreadyCalculated[currOriginalIndex]!="yes")
						{
							currMovingPolyPoints[newIndex] = goThroughPoints(polyMatrixStack, points[currOriginalIndex]);
//							trace("currIndex:"+currOriginalIndex+", "+currMovingPolyPoints[currOriginalIndex]);
							pointAlreadyCalculated[currOriginalIndex]="yes";
						}
						//else
							//trace("pointAlreadyCalculated:"+currOriginalIndex);
					}
	//				trace("currMovingPolyPoints[0]:"+currMovingPolyPoints[0]);
				}
				//trace("currMovingPolyPoints");
				//for each(var point in currMovingPolyPoints)
					//trace(point);
				movingPointsCalculated = true;
			}
//			sort();
			calcDepth();
		}
		
		protected function goThroughPoints(matrixStack:Array, point:ThreeDPoint, lastIndex:Boolean=false):ThreeDPoint
		{
			var back:ThreeDPoint = point.clone();
			for(var matrixIndex:Number=0; 
				matrixIndex<matrixStack.length;
				matrixIndex++)
			{
				var mat:ThreeDMatrix = matrixStack[matrixIndex];
//				if(	this instanceof ThreeDSprite 
//					&& matrixIndex==matrixStack.length-1)
//				{
//					spriteScaleCalc();
//				}
				if(mat.IsProjStateMatrix())
				{
					mat.applyProjection(back);
				}
				else
				{
					back.mulMe(mat);
				}
//				trace("goThroughPoints "+matrixIndex+":"+point);
			}
			return back;
		}
		
		public function spriteScaleCalc():void{/*To be overridden*/}
		
		/**
		 * calculate the flags for whether to render specific edges
		 * all faces are checked for coinciding verts with each other face
		 */
		public function calcEdgeSmoothFlags():void
		{
			trace("calcEdgeSmoothFlags() Beginn");
			edgeSmoothing = new Array();
			var outerPolyIndex:Number;
			var innerPolyIndex:Number;
			for(outerPolyIndex=0;outerPolyIndex<polygons.length;outerPolyIndex++)
				for(innerPolyIndex=0;innerPolyIndex<polygons.length;innerPolyIndex++)
				{
					if(innerPolyIndex!=outerPolyIndex)
					{
						//trace("innerPolyIndex, outerPolyIndex"+innerPolyIndex+", "+outerPolyIndex);
//						trace("polygons[outerPolyIndex].pointIndices:"+polygons[outerPolyIndex].pointIndices);
//						trace("polygons[innerPolyIndex].pointIndices:"+polygons[innerPolyIndex].pointIndices);
						for(var outerPointIndex:Number=0;outerPointIndex<polygons[outerPolyIndex].pointIndices.length;outerPointIndex++)
						{
							var firstOuterPoint:Number = polygons[outerPolyIndex].pointIndices[outerPointIndex];
							var secondOuterPoint:Number = (outerPointIndex+1<polygons[outerPolyIndex].pointIndices.length)?
																polygons[outerPolyIndex].pointIndices[outerPointIndex+1]:
																polygons[outerPolyIndex].pointIndices[0];
							for(var innerPointIndex:Number=0;innerPointIndex<polygons[innerPolyIndex].pointIndices.length;innerPointIndex++)
							{
								var firstInnerPoint:Number = (innerPointIndex==0)?
																polygons[innerPolyIndex].pointIndices[polygons[innerPolyIndex].pointIndices.length-1]:
																polygons[innerPolyIndex].pointIndices[innerPointIndex-1];
								var secondInnerPoint:Number = polygons[innerPolyIndex].pointIndices[innerPointIndex];
								var thirdInnerPoint:Number = (innerPointIndex+1<polygons[innerPolyIndex].pointIndices.length)?
																polygons[innerPolyIndex].pointIndices[innerPointIndex+1]:
																polygons[innerPolyIndex].pointIndices[0];
//								trace("firstOuterPoint, secondOuterPoint :"+firstOuterPoint+", "+secondOuterPoint);
//								trace("firstInnerPoint, secondInnerPoint, thirdInnerPoint :"+firstInnerPoint+", "+secondInnerPoint+", "+thirdInnerPoint);
								if(	firstOuterPoint==secondInnerPoint &&
									(secondOuterPoint==firstInnerPoint || secondOuterPoint==thirdInnerPoint) &&
									polygons[outerPolyIndex].smoothingGroup&polygons[innerPolyIndex].smoothingGroup)
								{
									this.edgeSmoothing[firstOuterPoint+"|"+secondOuterPoint] = "smooth";
//									trace("found: firstOuterPoint, secondOuterPoint"+firstOuterPoint+", "+secondOuterPoint);
									
								}
							}
						}
						// fil in other element parts
						if(polygons[outerPolyIndex].smoothingGroup&polygons[innerPolyIndex].smoothingGroup)
						{
							polygons[outerPolyIndex].otherElementParts[polygons[outerPolyIndex].otherElementParts.length] = polygons[innerPolyIndex];
						}
					}
				}
			trace("calcEdgeSmoothFlags() End");
		} 
		
		public function renderEdge(firstPoint:Number, secondPoint:Number):Boolean
		{
			if(this.edgeSmoothing==undefined)
				return true;
			if(		this.edgeSmoothing[firstPoint+"|"+secondPoint]=="smooth"
				|| 	this.edgeSmoothing[secondPoint+"|"+firstPoint]=="smooth")
				return false;
			return true;
		} 
		
		public function calcDepth():void
		{
			this.depth = 0;
			for(var depthInd:Number=0;depthInd<renderPoints.length;depthInd++)
			{
				this.depth+=renderPoints[depthInd].z;
			}
			this.depth /= renderPoints.length;
		}

		public function calcMoveVecs():void
		{
			for(var moveIndPoly:Number=0;moveIndPoly<polygons.length;moveIndPoly++)
			{
				if(!normalsCalculated)
				{
					var side1:ThreeDPoint = points[polygons[moveIndPoly].pointIndices[1]].minus(points[polygons[moveIndPoly].pointIndices[0]]);
					var side2:ThreeDPoint = points[polygons[moveIndPoly].pointIndices[2]].minus(points[polygons[moveIndPoly].pointIndices[0]]);
					if(normals==undefined)
						this.normals = new Array();
					polygons[moveIndPoly].faceNormal=side2.cross(side1);
					polygons[moveIndPoly].faceNormal.normalize(20);
				}
				else
					polygons[moveIndPoly].calcFaceNormal();
			}
			normalsCalculated = true;
			//trace("moveVecs"+this.moveVecs.length);
		}

		public override function mouseOverHandler(event:MouseEvent):void
		{
			if(!isMovable)
				return;
			ThreeDApp.SetOverObject();
			if(getState()==COLLAPSED)
			{
				currColour = mouseOverColour;
			}
			super.mouseOverHandler(event);
		}
	
		public override function mouseOutHandler(event:MouseEvent):void
		{
			if(!isMovable)
				return;
			if(getState()==COLLAPSED)
			{
				currColour = inactiveColour;
			}
			super.mouseOutHandler(event);
		}
		
		public override function mouseClickHandler(event:MouseEvent):void
		{
			if(!isMovable)
				return;
			trace(currActiveObject);
			if (currActiveObject==origObjInd || -1==currActiveObject)
			{
				jump();
				currActiveObject = origObjInd;
			}
		}

		public override function MouseDragHandler(event:MouseEvent):void
		{
		}
		
		public function isDirty():Boolean
		{
			if (!active)
				return false;
			return (currAlpha<1 && currAlpha>0) || moving || glowPercentage > 0 || dirty;
		}
		
		public function setDirty():void
		{
			dirty = true;
		}
		
		public override function Process(parent:ThreeDObject=undefined):void
		{
			this.currMovingPolyIndeces=undefined;
			for(var moveIndPoly:Number=0;moveIndPoly<polygons.length;moveIndPoly++)
			{
				polygons[moveIndPoly].Process(this);
			}
			if(this.currMovingPolyIndeces==undefined)
				this.movingPointsCalculated=false;
				
			super.Process();
				
			if(!isMovable)
				return;
			
			if (getState() == COLLAPSED)
			{
				if(currColour==mouseOverColour)
					glowFactor = 1;
				else
					glowFactor = -1;
				if(glowFactor>0 && glowPercentage<1)
					this.glowPercentage += 0.2;
				else if(glowFactor<0 && glowPercentage>0)
					this.glowPercentage -= 0.25;
			}
			else
				glowPercentage = 0;
				
			currAlpha = isActive()? currAlpha+0.1 : currAlpha-0.1;
			currAlpha = currAlpha<0?0:(currAlpha>1)?1:currAlpha;
			
			if (isDirty())
				ThreeDCanvas.setDirty();
			dirty = false;
		}
		
		public function ignoreDraw():Boolean
		{
			return (currAlpha == 0) && (!isActive());
		}
		
		public override function moveStep():void
		{
			if(getState()==COLLAPSING || getState()==EXTENDING)
				if(this.movementIndex<this.pendingMovements.length)
					this.myMatrixStack[0]=this.pendingMovements[this.movementIndex];
//				else
//					trace("this.movementIndex>=this.pendingMovements.length");
			// Force
		}
		
		public function ApplyForce(vector:ThreeDPoint)
		{
			if(!isMovable)
				return;
			lastForceVector = vector;
			forceDecay = 1;
		}
		
		public override function calcMovements():void
		{
			// reseting values
//			this.movementIndex=0;
			this.pendingMovements=new Array();
			
			var formerMat:ThreeDMatrix = this.myMatrixStack[0];
			this.pendingMovements[0] = formerMat;
			for(var jumpIndex:Number=1;jumpIndex<jumpLength;jumpIndex++)
			{
				this.pendingMovements[jumpIndex]=new ThreeDMatrix();
				var multiplier:Number=1/(jumpIndex+1);
				var rotMat:ThreeDMatrix=new ThreeDMatrix();
				rotMat.rotate(multiplier*20,0,0);
				this.pendingMovements[jumpIndex] = formerMat = formerMat.mul(rotMat);
				//this.pendingMovements[jumpIndex].scale(multiplier,multiplier,multiplier);
			}
//				for(var jumpPolyIndex:Number=0;jumpPolyIndex<this.polygons.length;jumpPolyIndex++)
//				{
//					polygons[jumpPolyIndex].jump();
//				}
		}
		
		public function printDepths():void
		{
			for(var polyIndex:Number=0; polyIndex<polygons.length; polyIndex++)
			{
				var currFace:Polygon = polygons[polyIndex];
				trace("currFace.depth:"+currFace.depth1);
			}
		}
		
		public function printNormal(index:Number):void
		{
			var angle1:ThreeDPoint = polygons[index].faceNormal;//polygons[index].unsortedIndex
			var angle2:ThreeDPoint = renderPoints[polygons[index].pointIndices[0]].minus(ThreeDCanvas.eye);
			angle1.normalize();
			angle2.normalize();
			
			var angleToCam:Number = angle1.dot(angle2);
//			trace("angle1:"+angle1+", angle2:"+angle2+", dot:"+angleToCam);  
		}
		
		public function drawLightning():void
		{
			var one:ThreeDPoint, two:ThreeDPoint;
			//trace("renderPoints:"+renderPoints[renderPoints.length-1]);
			//return;
			while(one==undefined)
			{
				var index:Number = Math.floor(Math.random()*(renderPoints.length-1));
				one = renderPoints[index];
//				trace("index:"+index+", one:"+one);
			}
			while(two==undefined)
			{
				var index:Number = Math.floor(Math.random()*(renderPoints.length-1));
				two = renderPoints[index];
//				trace("index:"+index+", two:"+two);
			}

//			var numIntersecs:Number = 5+Math.random()*10;
//			var began:Boolean = false;
//			for(var intersecI=0;intersecI<=numIntersecs;intersecI++)
//			{
//				var thisPos:ThreeDPoint = (two.minus(one));
//				thisPos.scale(intersecI/numIntersecs);
//				thisPos = thisPos.plus(one);
//				if(intersecI!=0 && intersecI!=numIntersecs)
//				{
//					var amount:Number;
//					if(intersecI<numIntersecs/2)
//						amount = intersecI/(numIntersecs/2);
//					else
//						amount = (numIntersecs-intersecI)/(numIntersecs/2);
//					amount *= 20;
//					thisPos = thisPos.plus(new ThreeDPoint(Math.random()*amount,Math.random()*amount));
//				}
//				if(began)
//					ThreeDCanvas.glowSprite.graphics.lineTo(thisPos.x, thisPos.y);
//				else
//				{
//					ThreeDCanvas.glowSprite.graphics.lineStyle(1,0xFFFFFF, 0.5);
//					ThreeDCanvas.glowSprite.graphics.moveTo(thisPos.x, thisPos.y);
//				}
//				began = true;
//			} 

		}
		
		public function draw():void
		{
			//trace("*************");
			//this.graphics.clear(); // clearing for drawing without shading
//			var startIndex:Number = 0;
			//trace(this.name+"numChildren:"+this.numChildren);
			
			var polysMoving:Boolean = polygons.length>0
					&& polygons[0].getState() != COLLAPSED 
					&& undefined != this.currMovingPolyIndeces
					&& this.movingPointsCalculated
					&& currMovingPolyPoints!=undefined
					&& currMovingPolyPoints.length > 0
					;
					
			for(var polyIndex:Number=0; polyIndex<polygons.length; polyIndex++)
			{
		/**********************
		new face or select existing
		
		face is created with the number of original object and number of original face
		face must be reconsidered with the same numbers as drawing in movieClip would change
		
		***********************/
//				var currFace:DrawElement;
//				//trace("numChildren "+numChildren+",polyIndex"+polyIndex);
//				if(numChildren<(polyIndex+1) || !getChildAt(polyIndex))
//				{
//					currFace = new DrawElement();
//					//currFace.name = currName;
//					this.addChildAt(currFace, polyIndex);
//					//trace("new face created at #:"+getChildIndex(currFace));
//				}
				var currFace:Polygon = polygons[polyIndex];

// drawList approach
				ThreeDCanvas.appendToDrawList(currFace);
// end drawList approach

				if(polysMoving)
				{
					currFace.draw(currMovingPolyPoints, renderNormals, true);
				}
				else
				{
					currFace.draw(renderPoints, renderNormals, false);
				}
				
//				if(polyIndex+1<numChildren)
//				{
//					removeChildAt(polyIndex);
//				}
//				addChildAt(currFace, polyIndex);
			}
//			if(isMoving)
//			{
//				drawLightning();
//			}
		}
		
		public function explode():void
		{
	//		this.copy(
		}
		
	}
}// package ThreeDCanvas 3DEngine