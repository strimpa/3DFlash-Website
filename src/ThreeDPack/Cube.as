package ThreeDPack
{
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.*;

	public class Cube extends ThreeDObject
	{
		var size:Number;
		var myContent:Content;
		var mPos:ThreeDPoint;
		var titleInvoked:Boolean = false;
		var style:StyleSheet = new StyleSheet();
		var styleObj:Object = new Object();
		var myTitleSprite:Sprite = undefined;
		var mouseIsOverMe:Boolean = true;
		
		var moveToCamIter:int = 0;
		var moveToCamera:uint = 0;
		const CAM_MOVE_LENGTH = 30;
		
		public function Cube(size_p:Number, pos:ThreeDPoint, content=undefined)
		{
			name="cube";
				this.myContent = content;
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
			this.polygons = new Array(	new Polygon(new Array(0,1,3,2), 0, this),
										new Polygon(new Array(0,1,5,4), 1, this),
										new Polygon(new Array(4,5,7,6), 2, this),
										new Polygon(new Array(2,3,7,6), 3, this),
										new Polygon(new Array(1,3,7,5), 4, this),
										new Polygon(new Array(0,2,6,4), 5, this)
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
			myMatrixStack[2].translateByVec(pos);
			
			jumpLength = CAM_MOVE_LENGTH;
		}

		protected override function objToProj(matrixStack:Array):void
		{
			super.objToProj(matrixStack);
			this.position = goThroughPoints(matrixStack, new ThreeDPoint(0,0,0));
		}
		
		public override function mouseClickHandler(event:MouseEvent):void
		{
			var currState = getState();
			super.mouseClickHandler(event);

			trace("click");
			for each(var poly:Polygon in polygons)
				poly.jump();

			if(!isActive() || currState!=COLLAPSED)
				return;

			//var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
			//var distance = new ThreeDPoint(event.stageX, event.stageY,0).minus(position);
			//var swizzleDistance = new ThreeDPoint(distance.y, -distance.x, 0);
			//var localAxisVec:ThreeDPoint = swizzleDistance.mul(invWVMatrix);//(Math.random(),Math.random(),Math.random());
			//localAxisVec.normalize();
			//this.myMatrixStack[1].MakeAxisRotationMatrix(localAxisVec, 0.5);
			//var transVec:ThreeDPoint = new ThreeDPoint(0,0,5).mul(invWVMatrix);
			//transVec.scale(20);
			//this.myMatrixStack[1].translateByVec(transVec);
			ThreeDApp.output("Content clicked:"+myContent.mTitle);
			
			TitleFieldManager.fadeOutTitle(myTitleSprite);
		}
		
		public override function mouseOverHandler(event:MouseEvent):void
		{
			super.mouseOverHandler(event);

			if(!isActive() || getState()!=COLLAPSED)
				return;
				
			mouseIsOverMe = true;
//			trace("mouseIsOverMe = true");
			if(!titleInvoked)
				invokeTitleShow();
				
			var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
			var distance = new ThreeDPoint(event.stageX, event.stageY,0).minus(position);
			var swizzleDistance = new ThreeDPoint(distance.y, -distance.x, 0);
			var localAxisVec:ThreeDPoint = swizzleDistance.mul(invWVMatrix);//(Math.random(),Math.random(),Math.random());
			localAxisVec.normalize();
			this.myMatrixStack[1].MakeAxisRotationMatrix(localAxisVec, 0.5);
			var transVec = new ThreeDPoint(0,0,5).mul(invWVMatrix);
			this.myMatrixStack[1].translateByVec(transVec);
			super.mouseOverHandler(event);

			ThreeDApp.SetMouseOverCube(myContent.mTitle);
			ThreeDApp.keywords.Update(new Point(event.stageX, event.stageY), myContent.mKeywords);
			
		}
		
		public override function mouseMoveHandler(event:MouseEvent):void
		{
			mouseIsOverMe = true;
//			trace("mouseIsOverMe = true");
			if(!titleInvoked)
				invokeTitleShow();
			super.mouseMoveHandler(event);
		}
		
		public override function mouseOutHandler(event:MouseEvent):void
		{
			mouseIsOverMe = false;
//			trace("mouseIsOverMe = false");
			super.mouseOutHandler(event);
		}
		
		public override function calcMovements():void
		{
			/* per-frame calculation of movements*/
		}
		
		public override function moveStep():void
		{
			var invWVMatrix:ThreeDMatrix = ThreeDCanvas.GetWorldViewMatrix().Inverse();
			var cameraFocusPoint:ThreeDPoint = new ThreeDPoint(0,0,-400).mul(invWVMatrix);//-400
			var movePerc:Number = this.movementIndex /CAM_MOVE_LENGTH;
			var dist:ThreeDPoint = cameraFocusPoint.minus(mPos);
			dist.scale(movePerc);
			var newPos:ThreeDPoint = mPos.plus(dist);
			if (movePerc > 0)
			{
				var initViewMatrix:ThreeDMatrix = new ThreeDMatrix();
				var targetRot:Number = ThreeDCanvas.dragRot - (ThreeDCanvas.dragRot % 90);
				var currMoveRot:Number = (targetRot - ThreeDCanvas.dragRot) * movePerc;
				initViewMatrix.rotate(180, currMoveRot, 0);
				myMatrixStack[2] = initViewMatrix;
			}
			else
				myMatrixStack[2].Identity();
			myMatrixStack[2].SetTranslationVec(newPos);
			
			this.myMatrixStack[1].ScaleValues(0.9);
			super.moveStep();
		}

		public override function Process():void
		{
//			trace("mouseIsOverMe : "+mouseIsOverMe);
			if(!mouseIsOverMe)
			{
				titleInvoked = false;
//				trace("fadeout:"+myTitleSprite);
				TitleFieldManager.fadeOutTitle(myTitleSprite);
				mouseIsOverMe = true;
			}
			
			super.Process();
		} 

		function invokeTitleShow():void
		{
			if(titleInvoked)
				return;
			titleInvoked = true;
			var title:String = myContent.mTitle;
			var one:ThreeDPoint,two:ThreeDPoint;
			one = this.position;
			two = this.position.plus(new ThreeDPoint(100+Math.random()*100,100+Math.random()*100));
			var one2d:Point = new Point(one.x,one.y);
			var two2d:Point =  new Point(two.x,two.y);
			var dist = two2d.subtract(one2d);

			myTitleSprite = TitleFieldManager.showTitleAtPoint(title, two2d);
			if(!ThreeDApp.curvedLines.createCurve(
				//begin_p, control1_p, control2_p, end_p
					one2d,
					one2d.add(new Point(Math.random()*dist.x,Math.random()*dist.y)),
					one2d.add(new Point(Math.random()*dist.x,Math.random()*dist.y)),
					two2d,
					myTitleSprite
				))
			{
				trace("Couldn't draw curve!!");
			}
		}
	}
}