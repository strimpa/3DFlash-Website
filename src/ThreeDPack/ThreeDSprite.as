package ThreeDPack
{
	import flash.display.Sprite;

	/**
	 * @author Gunnar
	 */
	public class ThreeDSprite extends ThreeDObject {
		
		var contentSprite:Sprite;
		var scaleDepths:Array;
		var isFirstIndex:Boolean;
		var myRotation:Number = 0;
		
		public function ThreeDSprite(pos:ThreeDPoint, name:String="ThreeDSprite", isCircle:Boolean=false, size:Number=1) {
			super();
			this.name = name;
			var tempPoint:ThreeDPoint = new ThreeDPoint(size,size,0).plus(pos);
			this.points = [
				pos,
				tempPoint
				];
			if(isCircle)
				CreateCircle();
		}
		
		public override function Process():void
		{
			myMatrixStack[1].Identity();
			myMatrixStack[1].rotate(0,0,myRotation+=10);
		} 
		
		public override function draw():void
		{
			if(renderPoints!=undefined)
			{
				if(renderPoints[0]!=undefined)
				{
					this.x = renderPoints[0].x;
					this.y = renderPoints[0].y;
					if(contentSprite!=undefined)
					{
						this.x -= contentSprite.width/2;
						this.y -= contentSprite.height/2;
					}
					this.scaleX = scaleY = 120/(120-(ThreeDCanvas.eye.z-renderPoints[0].z)/2);
				}
//				if(renderPoints[1]!=undefined && renderPoints[0]!=undefined)
//				{
//					var dist:ThreeDPoint = renderPoints[1].minus(renderPoints[0]);
//					trace("scale: "+(dist as ThreeDPoint).length);
//					this.scaleX = scaleY = (dist as ThreeDPoint).length;
//				}
			}
			if(this.numChildren==0 && contentSprite!=undefined)
			{
				addChildAt(contentSprite, 0);
			}
//			if(renderPoints[1]!=undefined && renderPoints[0]!=undefined)
//			{
//				graphics.clear();
//				var pos:ThreeDPoint = renderPoints[0];
//				var dist:ThreeDPoint = renderPoints[1].minus(renderPoints[0]);
//				dist.normalize(3);
//				trace("dist:"+dist+" scale: "+(dist as ThreeDPoint).length);
//				//this.scaleX = scaleY = (dist as ThreeDPoint).length;
//				graphics.beginFill(0x000000);
//				graphics.moveTo(pos.x+dist.x, pos.y+dist.x);
//				graphics.lineTo(pos.x+dist.x, pos.y-dist.x);
//				graphics.lineTo(pos.x-dist.x, pos.y-dist.x);
//				graphics.lineTo(pos.x-dist.x, pos.y+dist.x);
//				graphics.lineTo(pos.x+dist.x, pos.y+dist.x);
//				graphics.endFill();
//			}
		}
		
		public function CreateCircle():void
		{
			contentSprite = new Sprite();
			contentSprite.graphics.lineStyle(1, 0x999999,0.5);
			contentSprite.graphics.beginFill(0x00000000,0);
			contentSprite.graphics.drawEllipse(0,0, 5,5);
			contentSprite.graphics.endFill();
		}
	}
}
