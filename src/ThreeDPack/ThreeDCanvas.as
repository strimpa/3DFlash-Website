package ThreeDPack
{
	//import flash.display.MovieClip;
	import flash.display.*;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.system.Security;
	import flash.events.*;
	import flash.system.System;
	import flash.filters.GlowFilter;
	import flash.filters.BitmapFilter;
	
	public class ThreeDCanvas extends Sprite
	{
		public static const eye:ThreeDPoint = new ThreeDPoint(0,0,450);
		public static var projMatrix:ThreeDMatrix;
		public static var worldMatrix:ThreeDMatrix;
		public static var rotationMatrix:ThreeDMatrix;
		public static var viewMatrix:ThreeDMatrix;
		public static var viewportMatrix:ThreeDMatrix;
		public static var matrixStack:Array;
		public static var allObjects:Array;
		public static var drawList:Array;
		public static var drawListSprite:Sprite;
		public static var glowSprite:Sprite;
		public static var selectedSprite:Sprite;
		private static var exitSprite:Sprite;
		public static var currActiveCube:Cube;
		
		var colour:Number;
		
		static var rotFlag:Boolean = true;
		var currRot:Number=0;
		public static var dragRot:Number;
		public static var worldXRot:Number = 180;
		var inited:Boolean = false;
		var higherBox:ThreeDObject;
		
		var mMaskObject:Shape;
		
		static var drawNormals:Boolean = false; 
		var reloadDrawList:Boolean = false;
		var filtercolor:Number = 0xFFEEEE;
		var filteralpha:Number = 0.8;
		var blurX:Number = 20;
		var blurY:Number = 20;
		var strength:Number = 2;
		var quality:Number = 3;
		var inner:Boolean = false;
		var knockout:Boolean = false;		
		var filter:GlowFilter;

		public static var dirty:Boolean = true;

		public function ThreeDCanvas()
		{
//			width = 400;
//			height = 400;
//			trace("Security.sandboxType: "+Security.sandboxType+"\n");

			dragRot = 0;//new Point(0,0);
			
			worldMatrix = new ThreeDMatrix("worldMatrix");
			worldMatrix.traceMe("worldMatrix");
			
			viewMatrix = new ThreeDMatrix("viewMatrix");
			viewMatrix.rotate(worldXRot, 0, 0);
			viewMatrix.traceMe("viewMatrix");
			//viewMatrix.translate(this.width*10,this.height*10, 10);
			//var viewMatrix2:ThreeDMatrix = new ThreeDMatrix("viewMatrix2");
			viewMatrix.translate(eye.x, eye.y, eye.z);
			//viewMatrix.scale(0,0,-1);
			
			projMatrix = new ThreeDMatrix("projMatrix");
			projMatrix.SetIsProjStateMatrix();
			projMatrix.makeProjectionMatrix(0, 1000, 0.00344,0.00344, 1,1);
			projMatrix.traceMe("projMatrix");
	
			viewportMatrix = new ThreeDMatrix("viewportMatrix");
			viewportMatrix.translate(ThreeDApp.spectrumMiddle.x, ThreeDApp.spectrumMiddle.y, ThreeDApp.spectrumMiddle.z);//220,225, 0);
			//viewportMatrix.scale(2);
			
			matrixStack = new Array(0);
			matrixStack.push(worldMatrix);
			matrixStack.push(viewMatrix);
			matrixStack.push(projMatrix);
			matrixStack.push(viewportMatrix);
			
			allObjects = new Array();
			drawList = new Array();
			
			filter = new GlowFilter(filtercolor, 
                                    filteralpha, 
                                    blurX, 
                                    blurY, 
                                    strength, 
                                    quality, 
                                    inner, 
                                    knockout);

			drawListSprite = new Sprite();
			drawListSprite.cacheAsBitmap = true;
			//drawListSprite.mask = ThreeDApp.CreateMask(origin);
			addChild(drawListSprite);
			glowSprite = new Sprite();
			glowSprite.cacheAsBitmap = true;
//			glowSprite.filters = new Array(filter);
			addChild(glowSprite);
			selectedSprite = new Sprite();
			selectedSprite.cacheAsBitmap = true;
			addChild(selectedSprite);
			
//			drawListSprite.mask = ThreeDApp.CreateMask(ThreeDApp.spectrumMiddle);
			
			//exitSprite = new Sprite();
			//exitSprite.graphics.beginFill(0xFF0000);
			//exitSprite.graphics.drawRect(0, 0, 50, 50);
			//exitSprite.graphics.endFill();
			//exitSprite.addEventListener(MouseEvent.CLICK, exitHandler);
			//exitSprite.x = 700;
			//exitSprite.y = 100;
//			this.cacheAsBitmap = true;
			
		}
		
		public static function exitSpriteLoaded(data:Object):void
		{
//			exitSprite.addChild(data as Sprite);
//			exitSprite.getChildAt(0).blendMode = BlendMode.MULTIPLY;
		}
		public static function setActiveCube(cube:Cube):void
		{
			currActiveCube = cube;
		}
		
		public static function isCurrCubeMoving():Boolean
		{
			if (undefined != currActiveCube && currActiveCube.isMoving())
				return true;
			return false;
		}
		public static function isCurrCubeExtended():Boolean
		{
			if (undefined != currActiveCube && DrawElement.EXTENDED==currActiveCube.getState())
				return true;
			return false;
		}
		
		public static function exitHandler(event:Event)
		{
			ProgressTracker.setState(ProgressTracker.SCOPE_SELECTED);
			if (currActiveCube)
			{
				currActiveCube.jump();
			}
			currActiveCube = undefined;
		}
		
		static public function appendToObjects(item:ThreeDObject):void
		{
			var length:uint = allObjects.push(item);
		}
		
		public static function GetWorldViewMatrix():ThreeDMatrix
		{
			return viewMatrix.mul(worldMatrix);
		}
		public static function GetViewMatrix():ThreeDMatrix
		{
			return viewMatrix;
		}
		
		static public function appendToDrawList(item:Polygon):void
		{
			drawList.push(item);
		}
		
		public function toggleGlow():void
		{
			//trace(allObjects[0].filters);
			//if(allObjects[0].filters == "")
			//{
				//var glow:GlowFilter = new GlowFilter();
				//glow.color = 0xFFFFFF;
				//glow.quality = 1;
				//glow.alpha = 0.3;
				//glow.blurX = glow.blurY = 20;
				//allObjects[0].filters = new Array(glow);
			//}
			//else
				//allObjects[0].filters = new Array();
		}
		
		public function load():void
		{
			allObjects = new Array(0);
			drawList = new Array(0);
			reloadDrawList = true;
				
//			var groundPlane:ThreeDObject = new ThreeDObject();
//			groundPlane.name="groundPlane";
//			var len:Number=150;
//			groundPlane.points = new Array(	new ThreeDPoint(-len,10,-len),
//											new ThreeDPoint(len,10,-len),
//											new ThreeDPoint(-len,10,len),
//											new ThreeDPoint(len,10,len));
//			groundPlane.polygons = new Array(new Polygon(new Array(0,1,3,2)));
//			groundPlane.calcMoveVecs();
	
			var mast:ThreeDObject = new ThreeDObject();
			mast.points = new Array(new ThreeDPoint(-1,-500,0),
									new ThreeDPoint(1,-500,0),
									new ThreeDPoint(1,500,0),
									new ThreeDPoint(-1,500,0));
			mast.addPoly(new Polygon(new Array(0,1,3,2), 0, mast));
			//mast.currColour = 0xFFFFFF;
			//mast.borderColour = 0x3D3F3D;
			mast.currAlpha = 1;
			mast.isMovable = false;
			
			allObjects = new Array(
				//groundPlane
				mast
//				, new ThreeDSprite(new ThreeDPoint(0,100), "Circle 2",true)
//				, new ThreeDSprite(new ThreeDPoint(0,0,100), "Circle 3",true)
				);
				
//			new Obj2As("http://gunnardroege.de/scene01.obj");
			
			new CubeCollection(new ThreeDPoint(0,0,0));
			
//			for(var spriteAdd:Number=0;spriteAdd<20;spriteAdd++)
//			{
//				var rotMatrix:ThreeDMatrix = new ThreeDMatrix("rotMatrix");
//				rotMatrix.translate(0,0,-250+spriteAdd*25);
//				var sprite:ThreeDSprite = new ThreeDSprite(new ThreeDPoint(), "Circle 1",true);
//				sprite.myMatrixStack[2] = rotMatrix.clone();
//				//rotMatrix.Identity();//.rotate(0, -spriteAdd*20.0, 0);
////				sprite.myMatrixStack[1] = new ThreeDMatrix();
////				sprite.alpha = 1.0-(Math.abs(spriteAdd-10)/8);
//				allObjects.push(sprite);
//			}
			
			//this.addEventListener(Event.ENTER_FRAME, Process);
			//this.addEventListener(Event.ENTER_FRAME, draw);
			
		}
		
		/**
		 * called from draw() on first invokation
		 */
		public function Init():void
		{
			inited=true;
			load();
		}
	
		public static function pushMatrix():void
		{
			matrixStack.splice(0,0,new ThreeDMatrix());
		}
	
		public static function pushMatrices(toAppend:Array):void
		{
			matrixStack = toAppend.concat(matrixStack);
		}
	
		public static function popMatrix():void
		{
			matrixStack.shift();
		}
	
		public static function popMatrices(amount:Number):void
		{
			matrixStack.splice(0,amount);
		}
	
		public static function translate(x_p:Number,y_p:Number,z_p:Number):void
		{
			matrixStack[matrixStack.length].translate(x_p,y_p,z_p);
		}
		
		public function clicked():void
		{
		}
		
		public function sortDrawList():void
		{
			if(drawList.length>1)
			{
				for(var polyIndex:Number=0; polyIndex<drawList.length; polyIndex++)
				{
					drawList[polyIndex].calcDepth();
				}
				drawList = drawList.sortOn(["depth1", "depth2"], [Array.NUMERIC|Array.DESCENDING,Array.NUMERIC|Array.DESCENDING]); //depthCompareFunc
			}
		}
		
		public function Process(event:Event):void
		{
			worldMatrix.rotate( 0,dragRot-=currRot,0 );
			currRot /= 2;
			for(var objIndex:Number=0; objIndex<allObjects.length; objIndex++)
			{
				if(allObjects[objIndex].ignoreDraw())
					continue;
				// object intern transformations
				allObjects[objIndex].Process();
			}
		}
		
		public function mouseRotate(rot:Point)
		{
			if (rotFlag)
			{
				//dragRot=dragRot.add(rot);
				//trace("dragRot:"+dragRot);
				currRot += rot.y;
			}
		}
		
		public function isDirty():Boolean
		{
			return (Math.abs(currRot) > 0.001) || dirty;
		}
		public static function setDirty():void
		{
			dirty = true;
		}
		
		public function draw(event:Event):void
		{
			for (var c:uint = 0; c < drawListSprite.numChildren ; c++)
				if ((drawListSprite.getChildAt(c) as Polygon).getParentObj().ignoreDraw())
					drawListSprite.removeChildAt(c);
			//for (var c:uint = 0; c < glowSprite.numChildren ; c++)
				//if ((glowSprite.getChildAt(c) as Polygon).getParentObj().ignoreDraw())
					//glowSprite.removeChildAt(c);
			//for (var c:uint = 0; c < selectedSprite.numChildren ; c++)
				//if ((selectedSprite.getChildAt(c) as Polygon).getParentObj().ignoreDraw())
					//selectedSprite.removeChildAt(c);
//			glowSprite.graphics.clear();

			var sortIndices:Array = new Array();
			/**********************
			Sorting
			***********************/
			drawList = new Array();
			var objIndex:Number = 0;
//			trace("isDirty():"+isDirty());
			if(isDirty())
				for(; objIndex<allObjects.length; objIndex++)
				{
					if(allObjects[objIndex].ignoreDraw())
						continue;
					allObjects[objIndex].worldTransform(matrixStack, objIndex);
					allObjects[objIndex].draw();
				}//for
			sortDrawList();
			//if (currActiveCube != undefined)
				//glowSprite.addChild(exitSprite);
			//else if(glowSprite.contains(exitSprite))
				//glowSprite.removeChild(exitSprite);
			//painting
			
			//trace("liength "+drawList.length);
	
			/**********************
			drawing
			***********************/
			//var glowPercentage:Number=0;
			// set glowSprite to top
			var filter:GlowFilter = new GlowFilter(DrawElement.mouseOverColour,
                                    0, 
                                    blurX, 
                                    blurY, 
                                    strength, 
                                    quality, 
                                    inner, 
                                    knockout);
			//var filter:BlurFilter = new BlurFilter(
                                    //blurX, 
                                    //blurY, 
                                    //quality
									//);
            //glowSprite.filters = new Array(filter);
			for(var drawListIndex:Number=0; drawListIndex<drawList.length; drawListIndex++)
			{
				if (drawList[drawListIndex].getParentObj().ignoreDraw())
				{
					trace("remove:"+drawListIndex+", "+drawList[drawListIndex]);
					if (drawList[drawListIndex].parent)
						drawList[drawListIndex].parent.removeChild(drawList[drawListIndex]);
				}
				//if (drawList[drawListIndex].getGlowPercentage() > 0 || 
					//(drawList[drawListIndex].filters[0] && drawList[drawListIndex].filters[0].blurX>0))//smoothingGroup==8
				//{
//					trace("glowPercentage:" + drawList[drawListIndex].getGlowPercentage());
					//filter.blurX = filter.blurY = drawList[drawListIndex].getGlowPercentage()*20;
					//filter.alpha = drawList[drawListIndex].getGlowPercentage();
					//drawList[drawListIndex].filters = new Array(filter);
					//glowSprite.addChild(drawList[drawListIndex]);
				//}
				else
				{
					if (drawList[drawListIndex].getState() != DrawElement.COLLAPSED)
					{
						selectedSprite.addChild(drawList[drawListIndex]);
					}
					else
					{
						drawListSprite.addChild(drawList[drawListIndex]);
					}
				}
			} // for object
			
			dirty = false;
			//trace(System.totalMemory);
		} // draw()
		
		function GetOrigin():ThreeDPoint
		{
			return ThreeDApp.spectrumMiddle;
		}
	}
}