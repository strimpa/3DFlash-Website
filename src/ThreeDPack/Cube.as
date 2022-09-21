package ThreeDPack
{
	import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.*;
	import flash.events.MouseEvent;
	import flash.events.Event;

	public class Cube extends ThreeDObject
	{
		private var size:Number;
		private var myContent:Content;
		private var mPos:ThreeDPoint;
		private var titleInvoked:Boolean = false;
		private var style:StyleSheet = new StyleSheet();
		private var styleObj:Object = new Object();
		private var myTitleSprite:Sprite = undefined;
		private var mouseIsOverMe:Boolean = true;
		private var collectionIndex:uint = 0;
		
		private var moveToCamIter:int = 0;
		private var moveToCamera:uint = 0;
		private const CAM_MOVE_LENGTH = 10;
		private var currMovePos:ThreeDPoint;
		private var currCubeRot:Number = 0;
		private var mouseRotMode:Boolean = false;
		private var lastDragPos:Point;
		private var autoTargetRot:Number = NaN;
		private var rotationCallBack:Function = undefined; 
		
		private var currFacingPoly:uint;
		
		public function Cube(size_p:Number, pos:ThreeDPoint, collectionIndex:uint, content=undefined)
		{
			name="cube";
			this.myContent = content;
			this.collectionIndex = collectionIndex;
			myContent.setCube(this);
			this.size = size_p;
			this.mPos = pos.clone(); 
			
			var halfSize:Number = size/2;
			
			this.points = new Array(	new ThreeDPoint( -(halfSize), (halfSize), -(halfSize) ),
										new ThreeDPoint(  (halfSize), (halfSize), -(halfSize) ),
										new ThreeDPoint( -(halfSize), (halfSize),  (halfSize) ),
										new ThreeDPoint(  (halfSize), (halfSize),  (halfSize) ),
										new ThreeDPoint( -(halfSize),-(halfSize), -(halfSize) ),
										new ThreeDPoint(  (halfSize),-(halfSize), -(halfSize) ),
										new ThreeDPoint( -(halfSize),-(halfSize),  (halfSize) ),
										new ThreeDPoint(  (halfSize),-(halfSize),  (halfSize) )
										);
			
//			this.polygons = new Array(	new Polygon(new Array(0,1,3), 0, this),
//										new Polygon(new Array(0,3,2), 1, this),
//										new Polygon(new Array(0,1,5), 2, this),
//										new Polygon(new Array(0,5,4), 3, this),
//										new Polygon(new Array(4,5,7), 4, this),
//										new Polygon(new Array(4,7,6), 5, this),
//										new Polygon(new Array(2,3,7), 6, this),
//										new Polygon(new Array(2,7,6), 7, this),
//										new Polygon(new Array(1,3,7), 8, this),
//										new Polygon(new Array(1,7,5), 9, this),
//										new Polygon(new Array(0,2,6), 10, this),
//										new Polygon(new Array(0,6,4), 11, this)
//													);
			this.polygons = new Array(	new Polygon(new Array(4,5,1,0), 0, this),
										new Polygon(new Array(5,7,3,1), 1, this),
										new Polygon(new Array(2,3,7,6), 2, this),
										new Polygon(new Array(0,2,6,4), 3, this),
										new Polygon(new Array(0,1,3,2), 4, this),
										new Polygon(new Array(6,7,5,4), 5, this)
													);

			// scaled local transformation | scheduled local transformation | static world transformation
			this.myMatrixStack = new Array(new ThreeDMatrix(), new ThreeDMatrix(), new ThreeDMatrix());

			calcDepth();
			calcMoveVecs();
			setActive(false);

//			styleObj.fontSize = "bold";
//			styleObj.color = "#3D3F3D";
//			style.setStyle(".darkRed", styleObj);
//			fontLoad = new TargetLoad(this);
//			fontLoad.loadItem("FontLoad.swf");
			currMovePos = pos;
			lastDragPos = new Point();
			jumpLength = CAM_MOVE_LENGTH;
		}

		public function resetTitleSprite():void
		{
			myTitleSprite = undefined;
		}

		public function getCurrFacingPoly():uint
		{
			return currFacingPoly;
		}
		
		public function getContent():Content
		{
			return myContent;
		}
		
		public function extendPolygons(state:uint=ANY, cb:Function=undefined):void
		{
			for each(var poly:Polygon in polygons)
				poly.extend();
			if(cb!=undefined)
				polygons[0].setCallback(state, cb);
				
			evaluatefacingFace();
			myContent.setText(currFacingPoly);
		}
		public function collapsePolygons(state:uint=ANY, cb:Function=undefined):void
		{
			for each(var poly:Polygon in polygons)
				poly.collapse();
			if(cb!=undefined)
				polygons[0].setCallback(state, cb);
		}

		protected function exploded():Boolean
		{
			return polygons[0].getState() != COLLAPSED;
		}

		public function setText(text:String, index:uint):void
		{
			//var polyIndex = index;
			//if (polyIndex >= polygons.length)
				//polyIndex %= polygons.length;
			polygons[index].setText(text, myContent.mFolderName);
		}
		public function setHeader(text:String, index:uint):void
		{
			var polyIndex = index;
			if (polyIndex >= polygons.length)
				polyIndex %= polygons.length;
			polygons[polyIndex].setHeader(text);
		}
		public function resetPolyHeaders():void
		{
			for each(var poly:Polygon in polygons)
				poly.resetHeader();
		}
		
		public function startRotationMode()
		{
			mouseRotMode = true;
		}
		
		public override function mouseDownHandler(event:Event):void
		{
			if (!isNaN(autoTargetRot) || ProgressTracker.getState()<ProgressTracker.SCOPE_SELECTED)
				return;
			if (getState() == EXTENDED)
			{
				collapsePolygons(COLLAPSED, startRotationMode);
			}
		}
		
		public override function mouseUpHandler(event:Event):void 
		{
			if (!isNaN(autoTargetRot) || ProgressTracker.getState()<ProgressTracker.SCOPE_SELECTED)
				return;
			if(myContent.hasText(currFacingPoly) && !ProgressTracker.NewContentIsRequested() && getState()==EXTENDED)	
			{
//				trace("************EXTEND AGAIN!");
				mouseRotMode = false;
				extendPolygons();
				myContent.setText(currFacingPoly);
			}

			trace("my current state: "+getState());
			if(!isActive() || getState()!=COLLAPSED || (ThreeDCanvas.currActiveCube!=undefined && this==ThreeDCanvas.currActiveCube))
				return;

			SelectAndExtend();
			super.mouseUpHandler(event);
		}
		
		public function SelectAndExtend(scriptCall:Boolean=false):void
		{
			//if (isMoving())
			//{
				//ThreeDApp.output("Cancellling SelectAndExtend, already moving.");
				//return;
			//}
			if (ThreeDCanvas.currActiveCube != undefined && ThreeDCanvas.currActiveCube.getState()!=COLLAPSED)
				ThreeDCanvas.currActiveCube.jump();
				
			ThreeDCanvas.setActiveCube(this);
			// DOn't call javascript if this comes from there anyway
			if(!scriptCall)
				ThreeDApp.contentSelected(myContent.mFolderName, myContent.mContentUrl);
			TitleFieldManager.fadeOutTitle(myTitleSprite);
			if(getState()!=EXTENDED)
				jump();
			ProgressTracker.setState(ProgressTracker.CONTENT_SELECTED);
		}
		
		public override function mouseOverHandler(event:Event):void
		{
			if (!isNaN(autoTargetRot) || ProgressTracker.getState()<ProgressTracker.SCOPE_SELECTED)
				return;
			mouseIsOverMe = true;
//			super.mouseOverHandler(event);

			if (!isActive() || getState() != COLLAPSED || (ThreeDCanvas.currActiveCube != undefined && this != ThreeDCanvas.currActiveCube))
			{
				return;
			}

			ProgressTracker.setState(ProgressTracker.CONTENT_SELECT);

			if(!titleInvoked)
				invokeTitleShow();
				
			var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
			invWVMatrix.rotate( 180, 0, 0);
			var distance = new ThreeDPoint(mouseX, mouseY,0).minus(position);
			var swizzleDistance = new ThreeDPoint(distance.y, distance.x, 0);
			var localAxisVec:ThreeDPoint = swizzleDistance.mul(invWVMatrix);//(Math.random(),Math.random(),Math.random());
			localAxisVec.normalize();
			this.myMatrixStack[1].MakeAxisRotationMatrix(localAxisVec, 0.5);
			//var transVec = new ThreeDPoint(0,0,20).mul(invWVMatrix);
			//this.myMatrixStack[1].translateByVec(transVec);
			super.mouseOverHandler(event);
			
			ThreeDApp.SetMouseOverCube(myContent.mTitle);
			ThreeDApp.keywords.Update(new Point(mouseX, mouseY), myContent.mKeywords);
			
		}
		
		public override function mouseMoveHandler(event:Event):void
		{
			if (!isNaN(autoTargetRot) || ProgressTracker.getState()<ProgressTracker.SCOPE_SELECTED)
				return;
			mouseIsOverMe = true;
			if (mouseRotMode)
			{
				var dragDelta:Point = new Point(mouseY, mouseX).subtract(lastDragPos);
				currCubeRot -= dragDelta.y;
//				trace("currCubeRot:"+currCubeRot);
			}
			lastDragPos = new Point(mouseY, mouseX);

			if(!isActive() || getState()!=COLLAPSED || (ThreeDCanvas.currActiveCube!=undefined && this!=ThreeDCanvas.currActiveCube))
				return;

			ProgressTracker.setState(ProgressTracker.CONTENT_SELECT);

			if(!titleInvoked)
				invokeTitleShow();

			super.mouseMoveHandler(event);
		}
		
		public override function mouseOutHandler(event:Event):void
		{
			if (!isNaN(autoTargetRot))
				return;
			if(!isActive() || getState()!=COLLAPSED || (ThreeDCanvas.currActiveCube!=undefined && this!=ThreeDCanvas.currActiveCube))
				return;
			if (getState() == COLLAPSED)
			{
				ProgressTracker.setState(ProgressTracker.SCOPE_SELECTED);
			}
			mouseIsOverMe = false;
			super.mouseOutHandler(event);
		}
		
		public override function calcMovements():void
		{
			/* dummy array for per-frame calculation of movements */
			pendingMovements = new Array(10);
		}
		
		public override function moveStep():void
		{
			var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
			var cameraFocusPoint:ThreeDPoint = new ThreeDPoint(0,0,-410).mul(invWVMatrix);//-400
			var movePerc:Number = this.movementIndex /CAM_MOVE_LENGTH;
			var dist:ThreeDPoint = cameraFocusPoint.minus(mPos);
			dist.scale(movePerc);
			currMovePos = mPos.plus(dist);
			if (this.movementIndex >= 0)
			{
				var targetRot:Number = 0;// ThreeDCanvas.dragRot - (ThreeDCanvas.dragRot % 90);
				currCubeRot = (targetRot - ThreeDCanvas.dragRot) * movePerc;
				//evaluatefacingFace();
			}
			else
				myMatrixStack[2].Identity();
		}
		
		public function AutoRotateRight()
		{
			autoTargetRot = currCubeRot + 90;
			rotationCallBack = extendPolygons;
		}
		public function AutoRotateLeft()
		{
			autoTargetRot = currCubeRot - 90;
			rotationCallBack = extendPolygons;
		}
		
		private function ProcessRotations()
		{
			if (!isNaN(autoTargetRot) && autoTargetRot != currCubeRot)
			{
				currCubeRot += (autoTargetRot - currCubeRot)/2;
				if (Math.abs(currCubeRot - autoTargetRot) < 2)
					currCubeRot = autoTargetRot;
				if (currCubeRot == autoTargetRot)
				{
					if(undefined!=rotationCallBack)
						rotationCallBack();
					rotationCallBack = undefined;
					autoTargetRot = undefined;
				}
				evaluatefacingFace();
			}
			else if (getState()==EXTENDED && !mouseRotMode)
			{
				var globalRot:Number = currCubeRot + ThreeDCanvas.dragRot;
				var diff:Number = Math.abs(globalRot % 90)<45 ? -(globalRot%90) : (globalRot%90);
				var targetRot:Number = (globalRot + diff) - ThreeDCanvas.dragRot;
				currCubeRot = currCubeRot + (targetRot - currCubeRot)/2;
			}
		}
		
		public override function Process(parent:ThreeDObject=undefined):void
		{
			super.Process();

//			trace("mouseIsOverMe : "+mouseIsOverMe);
			if(!mouseIsOverMe)
			{
				titleInvoked = false;
				TitleFieldManager.fadeOutTitle(myTitleSprite);
				if (mouseRotMode)
				{
					mouseRotMode = false;
				}
				if (getState() == EXTENDED)
				{
					extendPolygons();
				}
				mouseIsOverMe = true;
			}
			this.myMatrixStack[1].ScaleValues(0.8);
			
			if (active && !this.myMatrixStack[1].IsIdentity())
			{
				//trace(this.collectionIndex);
				//this.myMatrixStack[1].traceMe();
				ThreeDCanvas.setDirty();
			}
			ProcessRotations();
			
			myMatrixStack[2] = new ThreeDMatrix();
			myMatrixStack[2].rotate(180, currCubeRot, 0);	
			myMatrixStack[2].translateByVec(currMovePos);

			if(mouseRotMode)
			{
				evaluatefacingFace();
			}
		}
		
		public override function isDirty():Boolean
		{
			if (mouseRotMode)
				return true;
			return super.isDirty();
		}
		
		public function evaluatefacingFace()
		{
			currFacingPoly = 0;
			var lastZ:Number = 999;
			for (var polyIndex:uint; polyIndex < polygons.length; polyIndex++)
			{
				var poly:Polygon = polygons[polyIndex];
				var normal:ThreeDPoint = poly.faceNormal;
				var modelMatrix:ThreeDMatrix = myMatrixStack[2].mul(ThreeDCanvas.GetWorldViewMatrix());
				var invWVMatrix:ThreeDMatrix = modelMatrix.Inverse();
				normal = normal.mul(invWVMatrix);
				if (normal.z < lastZ)
				{
					currFacingPoly = polyIndex;
					
					lastZ = normal.z;
				}
				polygons[polyIndex].colour = currColour;
			}
			polygons[currFacingPoly].colour = 0xFF0000;
		}
		
		public override function OnExtending():void
		{
			ThreeDCanvas.rotFlag = false;
			CubeCollection.setCubesActiveByIndex(true, collectionIndex);
			ThreeDCanvas.setActiveCube(this);
//			setMask(undefined);
			CurvedLineManager.doReset();
			CurvedLineManager.setGuide(true);
			ProgressTracker.setState(ProgressTracker.CONTENT_SELECTED);
		}

		public override function OnExtended():void
		{
			extendPolygons();
			this.myContent.load();
//			polygons[0].setCallback(EXTENDED, this.showContent);
			super.OnExtended();
			ProgressTracker.setState(ProgressTracker.CONTENT_SELECTED);
		}
		
		public override function OnCollapsing():void
		{
			ThreeDCanvas.rotFlag = true;
			CurvedLineManager.setSections(2);
			CurvedLineManager.setGuide(false);
			CurvedLineManager.doReset();
			resetPolyHeaders();
			if (ExternalInterface.available)
			{
				//try{
					//ExternalInterface.call("hideContentWindow");
				//}catch (e:Error){
					//ThreeDApp.output(e.getStackTrace());
				//}
			}
			super.OnCollapsing();
		}
		
		public override function OnCollapsed():void
		{
			if (ThreeDCanvas.isCurrCubeMoving() || ThreeDCanvas.isCurrCubeExtended() || ProgressTracker.getState() == ProgressTracker.CONTENT_SELECTED)
				return;
			ThreeDApp.output("Cube::OnCollapsed()"+myContent.mTitle);
			ProgressTracker.resetContent(this);
			super.OnCollapsed();
		}

		public function showContent():void
		{
			if (ExternalInterface.available)
			{
				//try{
					//ExternalInterface.call("showContentWindow");
				//}catch (e:Error){
					//ThreeDApp.output(e.getStackTrace());
				//}
			}
		}
		
		override public function jump():void 
		{
			if (polygons[0].getState() == COLLAPSED)
			{
				trace("super.jump()");
				super.jump();
			}
			else
			{
				trace("collapse polys and collapse");
				collapsePolygons(COLLAPSED, this.jump);
			}
		}

		function invokeTitleShow():void
		{
			if(titleInvoked)
				return;
			titleInvoked = true;
			var title:String = myContent.mTitle;
			myTitleSprite = TitleFieldManager.showTitleAtPoint(title, this, position);
		}
	}
}