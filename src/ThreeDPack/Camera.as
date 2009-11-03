package ThreeDPack
{
	public class Camera extends ThreeDObject
	{
		public function Camera(){
		}
		
		public function translate(tx_p:Number, ty_p:Number, tz_p:Number, lookToX:Number, lookToY:Number, lookToZ:Number):void{
			var theViewMatrix:ThreeDMatrix = this.myMatrixStack[0];
			
			theViewMatrix.tx += tx_p;
			theViewMatrix.ty += ty_p;
			theViewMatrix.tz += tz_p;
			theViewMatrix.a = theViewMatrix.tx-lookToX;
			theViewMatrix.e = theViewMatrix.ty-lookToY;
			theViewMatrix.i = theViewMatrix.tz-lookToZ;
		}
		
	}
}// package ThreeDCanvas 3DEngine