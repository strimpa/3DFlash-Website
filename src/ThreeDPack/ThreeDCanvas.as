package ThreeDPack
{
	//import flash.display.MovieClip;
	import flash.display.*;
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
		
		var colour:Number;
		
		static var rotFlag:Boolean = false;
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
			glowSprite.filters = new Array(filter);
			addChild(glowSprite);
			
			drawListSprite.mask = ThreeDApp.CreateMask(ThreeDApp.spectrumMiddle);
			
//			this.cacheAsBitmap = true;
			
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
			trace(allObjects[0].filters);
			if(allObjects[0].filters == "")
			{
				var glow:GlowFilter = new GlowFilter();
				glow.color = 0xFFFFFF;
				glow.quality = 1;
				glow.alpha = 0.3;
				glow.blurX = glow.blurY = 20;
				allObjects[0].filters = new Array(glow);
			}
			else
				allObjects[0].filters = new Array();
		}
		
		public function load():void
		{
			trace("load!");
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
			mast.colour = 0xFFFFFF;
			mast.borderColour = 0x3D3F3D;
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
			currRot/=2;
//			if(rotFlag)
//			{
//				currRot--;
//			}
			for(var objIndex:Number=0; objIndex<allObjects.length; objIndex++)
			{
				if(!allObjects[objIndex].isActive())
					continue;
				// object intern transformations
				allObjects[objIndex].Process();
			}
		}
		
		public function mouseRotate(rot:Point)
		{
				//dragRot=dragRot.add(rot);
				currRot += rot.y;
		}
		
		public function draw(event:Event):void
		{
			//if(reloadDrawList)
			for(var delIndex:Number=0;delIndex<drawListSprite.numChildren;delIndex++)
				drawListSprite.removeChildAt(delIndex);
			for(delIndex=0;delIndex<glowSprite.numChildren;delIndex++)
				glowSprite.removeChildAt(delIndex);
//			glowSprite.graphics.clear();

//			drawListSprite = new Sprite();
//			drawListSprite.mask = ThreeDApp.CreateMask();
//			addChild(drawListSprite);
//			glowSprite = new Sprite();
//			glowSprite.filters = new Array(filter);
//			addChild(glowSprite);
			
			var sortIndices:Array = new Array();
			/**********************
			Sorting
			***********************/
			drawList = new Array();
			var objIndex:Number = 0;
			for(; objIndex<allObjects.length; objIndex++)
			{
				if(!allObjects[objIndex].isActive())
					continue;
				//var newObject:ThreeDObject=
				allObjects[objIndex].worldTransform(matrixStack, objIndex);
//				var sortIndex:Number=0;
//				while(sortIndex<sortIndices.length && allObjects[sortIndices[sortIndex]].depth>newObject.depth)
//					sortIndex++;
//				sortIndices.splice(sortIndex,0,objIndex);
				allObjects[objIndex].draw();
			}//for
			sortDrawList();
			//painting
			
			//trace("liength "+drawList.length);
	
			/**********************
			drawing
			***********************/
			//var glowPercentage:Number=0;
			// set glowSprite to top
			var filter:GlowFilter = new GlowFilter(filtercolor, 
                                    0, 
                                    blurX, 
                                    blurY, 
                                    strength, 
                                    quality, 
                                    inner, 
                                    knockout);
            glowSprite.filters = new Array(filter);
//			var formerParent:DrawElement = undefined;
//			var currGlowChild:Sprite = new Sprite();
//			var currFilter:GlowFilter = (filter.clone() as GlowFilter);
//			glowSprite.addChild(currGlowChild);
			for(var drawListIndex:Number=0; drawListIndex<drawList.length; drawListIndex++)
			{
				if(drawList[drawListIndex].getGlowPercentage()>0)//smoothingGroup==8
				{
//					if(formerParent==undefined || formerParent!=drawList[drawListIndex].parentObj)
//					{
//						currGlowChild = new Sprite(); 
//						glowSprite.addChild(currGlowChild);
//						currFilter = (filter.clone() as GlowFilter);
//					}
//					currFilter.blurX = currFilter.blurY = drawList[drawListIndex].getGlowPercentage()*30;
//					currFilter.alpha = drawList[drawListIndex].getGlowPercentage();
////					glowSprite.filters = new Array(filter);
//					currGlowChild.filters = new Array(currFilter);
//					currGlowChild.addChild(drawList[drawListIndex])
//					formerParent = drawList[drawListIndex].parentObj;
					filter.blurX = filter.blurY = drawList[drawListIndex].getGlowPercentage()*20;
					filter.alpha = drawList[drawListIndex].getGlowPercentage()/2;
					glowSprite.filters = new Array(filter);
					glowSprite.addChild(drawList[drawListIndex]);
				}
				else
				{
//					if(drawListIndex+1<numChildren)
//						drawListSprite.removeChildAt(drawListIndex);
					drawListSprite.addChild(drawList[drawListIndex]);
				}
			} // for object
			
//			drawListSprite.addChild(glowSprite);
			
//			for(var allObjIndex:Number=0; allObjIndex<sortIndices.length; allObjIndex++)
//			{
//				var objIndex:Number = sortIndices[allObjIndex];
//				if(allObjIndex+1<numChildren)
//					removeChildAt(allObjIndex);
//				addChildAt(allObjects[objIndex], allObjIndex);
//				allObjects[objIndex].draw();
//			} // for object

			//trace(System.totalMemory);
		} // draw()
		
		function GetOrigin():ThreeDPoint
		{
			return ThreeDApp.spectrumMiddle;
		}
	}
}