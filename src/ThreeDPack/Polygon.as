package ThreeDPack
{
	import adobe.utils.ProductManager;
	import flash.events.MouseEvent;
	import flash.display.*;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class Polygon extends DrawElement
	{
		public var unsortedIndex:Number;
		public var pointIndices:Array;
		public var adjacencyIndices:Array;
		public var normalIndices:Array;
		public var smoothingGroup:Number; 
		public var depth1:Number=0;
		public var depth2:Number=0;
		public var opacity:Number=100;
		public var colour:Number;
		
		// content related
		private var titleField:TextField;
		private var textSprite:Sprite;
		private var textField:TextField;
		private var mCurves:Array;
		
		public var myCurrentLoaders:Array;
		private var bubbleClickEvent:Boolean;
		
	// new point calculation
	//	var points:Array;
	
	// movement related things
		public var faceNormal:ThreeDPoint;
		public var moveMatrix:ThreeDMatrix;
		public var pointMoveIndices:Array;
		public var otherElementParts:Array;
		
		private var hintTimer:Timer;
		private const rotHintHeight = 50;
		private var rotHintPos:Number;
		private var rotHintState:uint;
		private static var rotHintSprite:Sprite;
		
		public function Polygon(points_p:Array, unsortedIndex:uint, parent:ThreeDObject=undefined, normals:Array=undefined, copyPropsFrom:Polygon=undefined):void{
			this.pointIndices = points_p;
			this.pointMoveIndices = new Array(points_p.length);
			this.parentObj = parent;
			this.unsortedIndex = unsortedIndex;
			if(normals!=undefined)
			{
				this.normalIndices = new Array(normals.length);
				for(var normalCopy in normals)
					normalIndices[normalCopy] = normals[normalCopy];
			}
			if(parent!=undefined)
				this.colour = Math.random() * 255 | 
				((Math.random() * 255) << 8) |
				((Math.random() * 255) << 16);
				// parent.currColour;
	//		this.calcDepth();
			if(copyPropsFrom!=undefined)
			{
				pointIndices = copyPropsFrom.pointIndices;
				opacity = copyPropsFrom.opacity;
				colour = copyPropsFrom.colour;
			}
			alpha = 0.8;
			moveMatrix = new ThreeDMatrix();
			otherElementParts = new Array();
			textSprite = new Sprite();
			this.addChild(textSprite);
			mCurves = new Array();
//			this.blendMode = BlendMode.SCREEN; TOOOOOOOOOOOO Costy

			bubbleClickEvent = true;
			rotHintPos = 1.0;
			rotHintState = DrawElement.COLLAPSED;
			rotHintSprite = undefined;
		}
		
		public static function SetRotHintSprite(s:Object):void
		{
			rotHintSprite = (s as Sprite);
		}
		
		public function calcFaceNormal():void
		{
			if(!parentObj || parentObj.normals==undefined || parentObj.normals.length<=0 || normalIndices==undefined)
				return;
				
			faceNormal = new ThreeDPoint(0,0,0);
			for(var normalIndex:Number=0;normalIndex<normalIndices.length;normalIndex++)
			{
				if (undefined == parentObj.normals[normalIndices[normalIndex]])
				{
					continue;
				}
				faceNormal = faceNormal.plus(parentObj.normals[normalIndices[normalIndex]]);
			}
			faceNormal.divideMe(normalIndices.length);
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
		
		public override function mouseOverHandler(event:Event):void
		{
			if(notMoveable())
				return;
			if(parentObj)
			{
				parentObj.mouseOverHandler(event);
//				parentObj.setPolyColour(true);
			}
			super.mouseOverHandler(event);
		}
	
		public override function mouseOutHandler(event:Event):void
		{
			if(notMoveable())
				return;
			if(parentObj)
			{
				parentObj.mouseOutHandler(event);
				parentObj.setPolyColour(false);
			}
			super.mouseOutHandler(event);
		}
		
		public override function mouseClickHandler(event:Event):void
		{
			trace("mouseClickHandler:"+notMoveable() +", "+ bubbleClickEvent);
			if(notMoveable())
				return;
			if(parentObj && bubbleClickEvent)
				parentObj.mouseClickHandler(event);
				
			bubbleClickEvent = true;
		}

		public override function mouseUpHandler(event:Event):void
		{
			if(notMoveable())
				return;
			if(parentObj)
				parentObj.mouseUpHandler(event);
		}

		public override function mouseMoveHandler(event:Event):void
		{
			if(notMoveable())
				return;
			super.mouseMoveHandler(event);
			if(parentObj)
				parentObj.mouseMoveHandler(event);
			mouseOverHandler(event);
		} 

		public override function MouseDragHandler(event:Event):void
		{
			parentObj.MouseDragHandler(event);
		} 
		
		public function notMoveable():Boolean
		{
//			if(this.smoothingGroup>1)
				return false;
			return true;
		}

		public override function moveStep():void
		{
//			trace(getState());
			if (COLLAPSING==getState() || EXTENDING==getState())
			{
				if(this.movementIndex<this.pendingMovements.length)
					this.moveMatrix = this.pendingMovements[this.movementIndex];
//				trace("mCurrState:"+mCurrState+", movePercentage:"+movementIndex+", pendingMovements.length:"+pendingMovements.length);
				if (textField)
				{
					textSprite.alpha = movementIndex / polyJumpLength;
				}
			}
		}
		
		public function getGlowPercentage():Number
		{
			return parentObj.glowPercentage;
		}

		public override function Process(parent:ThreeDObject=undefined):void
		{
			super.Process(parent);
			if(getState()!=COLLAPSED)
			{
				parent.SetMovingPolyIndex(this.unsortedIndex);
			}
			if (currColour!=parentObj.currColour || isDirty())
				parentObj.setDirty();
				
			if (undefined != parent)
				parentObj = parent;
				
			if (undefined != rotHintSprite)
			{
				if (rotHintState != DrawElement.COLLAPSED)
				{
					trace("rotHintPos:"+rotHintPos);
					if (rotHintState == DrawElement.EXTENDING)
					{
						if(rotHintPos > 0)
							rotHintPos -= 0.1;
						else {
							rotHintState = DrawElement.EXTENDED;
						}
					}
					else if (rotHintState == DrawElement.COLLAPSING)
					{
						if(rotHintPos < 1.0)
							rotHintPos += 0.1;
						else
						{
							rotHintState = DrawElement.COLLAPSED;
						}
					}
					rotHintSprite.x = 131;
					rotHintSprite.y = 625 + (rotHintPos * 50);
					rotHintSprite.alpha = 1.0 - rotHintPos;
				}
				else
				{
					if(this.contains(rotHintSprite))
						this.removeChild(rotHintSprite);
				}
			}

			currColour = parentObj.currColour;
		}
		
		public function isDirty():Boolean
		{
			var back:Boolean = moving || (titleField && titleField.alpha < 1);
			return back;
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// Event handling
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public override function OnCollapsed():void
		{
			if(parentObj!=undefined)
			{
				parentObj.ResetMovingPolyIndex(this.unsortedIndex);
				currColour = DrawElement.inactiveColour;
			}
			if(textField && textSprite.contains(textField))
			{
				textSprite.removeChild(textField);
			}
			removeChild(textSprite);
			textField = undefined;
			textSprite.graphics.clear();
//			trace("poly " + unsortedIndex + " collapsed");
			super.OnCollapsed();
		}

		public override function OnCollapsing():void
		{
			super.OnCollapsing();
			ThreeDApp.UnbindScrollbar();
			var button:DisplayObject = rotHintSprite.getChildByName("closeButton");
			if (button)
			{
				button.removeEventListener(MouseEvent.MOUSE_DOWN, closeRotHint);
			}
			if(hintTimer)
				hintTimer.stop();
			if(this.contains(rotHintSprite))
				this.removeChild(rotHintSprite);
			rotHintState = DrawElement.COLLAPSED;
		}
		
		public override function OnExtending():void
		{
			addChild(textSprite);
			textSprite.alpha = 1;
			rotHintState = DrawElement.COLLAPSED;
			super.OnExtending();
		}
		
		public override function OnExtended():void
		{
			if (textField)
			{
				ThreeDApp.BindScrollbar(textField);
			}
			bubbleClickEvent = true;
		}
		
		public function LinkHandler(event:TextEvent):void
		{
			bubbleClickEvent = false;
			if (event.text.match("pic:"))
			{
				event.text = event.text.replace("pic:", "");
				var title:String = (parentObj as Cube).getContent().mFolderName;
				var doc:String = (parentObj as Cube).getContent().mContentUrl;
				ThreeDApp.picClicked(event.text, title, doc);
			}
			else
			{
				ProgressTracker.requestNewContent(event.text);
				parentObj.jump();
				ThreeDCanvas.exitHandler(event);
			}
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		// Hint handling
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function startHintTimer():void
		{
			if (undefined!=rotHintSprite && globals.needsCubeRotHint && rotHintState == DrawElement.COLLAPSED)
			{
				hintTimer = new Timer(3000, 1);
				hintTimer.addEventListener(TimerEvent.TIMER, timerListener);
				hintTimer.start();
				trace("timer started");
			}
		}
		
		public function closeRotHint(e:MouseEvent):void
		{
			trace("collapsing rothint");
			rotHintState = DrawElement.COLLAPSING;
			var button:DisplayObject = rotHintSprite.getChildByName("closeButton");
			if (button)
			{
				button.removeEventListener(MouseEvent.MOUSE_DOWN, closeRotHint);
			}
			globals.needsCubeRotHint = false;
			e.stopImmediatePropagation();
		}
		
		private function timerListener (e:TimerEvent):void
		{
			trace("extending rothint");
			rotHintState = DrawElement.EXTENDING;
			rotHintPos = 1.0;
			this.addChild(rotHintSprite);
			rotHintSprite.alpha = 0.0;
			//var maskSprite:Sprite = new Sprite();
			//maskSprite.graphics.drawRect(this.x, this.y, this.width, this.height);
			//this.addChild(maskSprite);
			//rotHintSprite.mask = maskSprite;
			var button:DisplayObject = rotHintSprite.getChildByName("closeButton");
			if (button)
			{
				button.addEventListener(MouseEvent.MOUSE_DOWN, closeRotHint);
			}
//			hintTimer.stop(); not needed due to "1" parameter
		}
		
		public function setText(text:String, folderName:String)
		{
			if(!textField)
			{
//				trace(text);
				try
				{
					textField = new TextField();
					textField.addEventListener(TextEvent.LINK, LinkHandler);
					textField.selectable = false;
					textField.wordWrap = true;
					textField.multiline = true;
					textField.blendMode = BlendMode.LAYER;
					textSprite.addChild(textField);
					textField.styleSheet = Content.getStyle();
					var eventRootString = globals.htmlRoot + folderName
					var picEventRootString = "href=\"event:pic:" + globals.htmlRoot + folderName
					
					// Inserting remote image path and lightbox rel tag
					trace(text);
					var myPattern:RegExp = /src=\"/g;
					text = text.replace(myPattern, "src=\"" + eventRootString + "/");
					// Get all links
					for each(var ext:String in globals.contentExtensions)
					{
						myPattern = new RegExp("href=\"(.*)\."+ext, "g");
						text = text.replace(myPattern, "target=\"blank\" href=\""+eventRootString + "/$1."+ext);
						myPattern = new RegExp("href=\"(.*)\."+ext.toUpperCase(), "g");
						text = text.replace(myPattern, "target=\"blank\" href=\""+eventRootString + "/$1."+ext);
					}
					for each(var ext:String in globals.pictureExtensions)
					{
						myPattern = new RegExp("href=\"(.*)\."+ext, "g");
						text = text.replace(myPattern, picEventRootString + "/$1."+ext);
						myPattern = new RegExp("href=\"(.*)\."+ext.toUpperCase(), "g");
						text = text.replace(myPattern, picEventRootString + "/$1."+ext);
					}
					trace(text);
					
					textField.htmlText = text;
					var picLoader:TargetLoad = ContentManager.getLoader();
					var picsFound:Boolean = false;
					var pictureIds:Array = ["pic1", "pic2", "pic3", "pic4", "pic5", "pic6", "pic7", "pic8", "pic9"];
					myCurrentLoaders = new Array();
					for each(var picId in pictureIds)
					{
						var ref:DisplayObject = textField.getImageReference(picId);
						//if(ref)
							//trace("got pic: " + picId);
						if (ref && (ref is Loader))
						{
							picsFound = true;
							var theLoader:Loader = (ref as Loader);
							theLoader.name = picId;
							myCurrentLoaders.push(theLoader);
							picLoader.configureListeners(theLoader.contentLoaderInfo, picId, true, this);
						}
					}
				}
				catch (error:Error)
				{
					trace(error.getStackTrace());
				}

				CurvedLineManager.setFilling(false);
				CurvedLineManager.setRadius(100);
				CurvedLineManager.createCurve(
					new Point(50, -50),
					new Point(-150, -50),
					new Point(-150, 100),
					new Point(400, 0), 
					textSprite);
				CurvedLineManager.setFilling(true);
				CurvedLineManager.setRadius(50);
			}
		}
		
		public function OnLoaded():void
		{
		}
		
		public function setHeader(header:String):void
		{
			if(titleField && contains(titleField))
				removeChild(titleField);
			titleField = new TextField();
			titleField.selectable = false;
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.embedFonts = true;
			titleField.defaultTextFormat = globals.textformatCubeTitle;
			titleField.blendMode = BlendMode.LAYER;
			this.addChild(titleField);
			titleField.text = header;
			titleField.alpha = 0;
		}
		public function resetHeader():void
		{
			if(titleField && contains(titleField))
				removeChild(titleField);
			titleField = undefined;
			textSprite.graphics.clear();
		}

		public override function calcMovements():void
		{
			var dir:ThreeDPoint = this.faceNormal;
			dir.normalize(10);

//			this.movementIndex=0;
			this.pendingMovements=new Array();

			var formerMat:ThreeDMatrix = new ThreeDMatrix();// moveMatrix;
			this.pendingMovements[0] = formerMat;
			for(var jumpIndex:Number=1;jumpIndex<polyJumpLength;jumpIndex++)
			{
				this.pendingMovements[jumpIndex]=new ThreeDMatrix();
				var multiplier:Number=jumpIndex/polyJumpLength;
				var currVec:ThreeDPoint = new ThreeDPoint(dir.x*multiplier, dir.y*multiplier, dir.z*multiplier);
//				trace("multiplier:"+multiplier+", currVec"+currVec);
				this.pendingMovements[jumpIndex].translate(currVec.x, currVec.y, currVec.z);
			}
			//trace("pendingMovements");
			//for each(var mat in pendingMovements)
				//trace(mat.Translation());
		}

		public function draw(points:Array, normals:Array=undefined, isMoving:Boolean=false):void
		{
			graphics.clear(); // clearing for drawing with shading
//			trace("Polygon::draw()");
			graphics.beginFill(currColour, parentObj.currAlpha);
			// move to first Point
			var indices:Array = isMoving?pointMoveIndices:pointIndices;
			var endPoint:ThreeDPoint = points[indices[0]];
			if(endPoint==undefined)
			{	
				trace("error at point "+indices[0]);
				return;
			}
//			trace("pointIndices:"+pointIndices);
			graphics.moveTo(endPoint.x, endPoint.y);
			
			var minPoint:Point = new Point(800,800);
			var maxPoint:Point = new Point(0,0);
			for(var vertIndex:Number=1;vertIndex<=indices.length;vertIndex++){
				var index:Number =  vertIndex<indices.length?vertIndex:0;
				// on purpose vertIndex and index as index gets set yo 0 
				var renderTheEdge:Boolean = parentObj.renderEdge(indices[vertIndex-1], indices[index]);
				var currPoint:ThreeDPoint = points[indices[index]];
				if(currPoint==undefined)
				{	
					trace("error at point "+indices[index]);
					continue;
				}
				//trace("vertIndex:"+vertIndex+", currPoint:"+currPoint.x+", "+currPoint.y);
				if(renderTheEdge)
					graphics.lineStyle(0.5, parentObj.borderColour, parentObj.currAlpha);
				else
					graphics.lineStyle(0.5, parentObj.borderColour, 0);
				graphics.lineTo(currPoint.x, currPoint.y);
				
				minPoint.x = currPoint.x < minPoint.x ? currPoint.x : minPoint.x;
				minPoint.y = currPoint.y < minPoint.y ? currPoint.y : minPoint.y;
				maxPoint.x = currPoint.x > maxPoint.x ? currPoint.x : maxPoint.x;
				maxPoint.y = currPoint.y > maxPoint.y ? currPoint.y : maxPoint.y;
			}
//			graphics.lineTo(endPoint.x, endPoint.y);
			graphics.endFill();
			
			textSprite.x = minPoint.x;
			textSprite.y = minPoint.y;
			if (titleField)
			{
				titleField.x = minPoint.x;
				titleField.y = minPoint.y - 30;
				if (titleField.alpha < 1)
					titleField.alpha += 0.1;
			}
			if (textField)
			{
				textField.width = maxPoint.x - minPoint.x;
				textField.height = maxPoint.y - minPoint.y;
			}
			
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
	}
	
}// package ThreeDCanvas 3DEngine