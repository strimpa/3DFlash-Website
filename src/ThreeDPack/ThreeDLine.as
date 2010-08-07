package ThreeDPack
{
	class ThreeDLine extends DrawElement
	{
		var points:Array;
		
		public function ThreeDLine(point1:ThreeDPoint, point2:ThreeDPoint)
		{
			points = [point1, point2];
		}
		
		public function processStates():void
		{
//			trace(mCurrState);
			if(EXTENDING==getState())//this.movementIndex<this.pendingMovements.length)
			{
				this.moving=true;
				colour = mouseOverColour;
				if(this.movementIndex==this.pendingMovements.length)
				{
//					trace("this.movementIndex==this.pendingMovements.length");
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
				}
				else
					this.movementIndex--;
			}
		}
		public function moveStep():void
		{
			//if (COLLAPSING==getState() || EXTENDING==getState())
			//{
				//this.movementIndex++;
				//trace("mCurrState:"+mCurrState+", movePercentage:"+movementIndex+", pendingMovements.length:"+pendingMovements.length);
			//}
			//var percentage = (this.movementIndex * 3) / this.pendingMovements.length;
			//this.movePercentage = percentage<0.3?percentage:(percentage>2.7?(percentage-3)/-1:0.3);
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
		public function Process(parent:ThreeDObject):void
		{
			this.parentObj = parent;
			processStates();
			moveStep();
			if(moving)
			{
				parent.SetMovingPolyIndex(this.unsortedIndex);
			}
			colour = parentObj.colour;
		}

		public function draw():void
		{
			graphics.clear(); // clearing for drawing with shading
			graphics.beginFill(0xFF0000, 0);
			graphics.lineStyle(1, parentObj.borderColour, 1);
			// move to first Point
			var endPoint:ThreeDPoint = points[0];
			graphics.moveTo(endPoint.x, endPoint.y);
			
			for(var vertIndex:Number=1;vertIndex<=points.length;vertIndex++){
				var currPoint:ThreeDPoint = points[index];
				if(currPoint==undefined)
				{	
					trace("error at point "+pointIndices[index]);
					continue;
				}
				graphics.lineTo(currPoint.x, currPoint.y);
			}
			graphics.endFill();
		}
		
	}
}