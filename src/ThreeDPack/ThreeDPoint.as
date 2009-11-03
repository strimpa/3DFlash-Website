package ThreeDPack
{
	public class ThreeDPoint
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		public var length:Number;
		
		public function ThreeDPoint(x_p:Number=0.0, y_p:Number=0.0, z_p:Number=0.0, w_p:Number=1.0)
		{
			this.x = x_p;
			this.y = y_p;
			this.z = z_p;
			this.w = w_p;
			
			calcLength();
		}
		
		public function clone():ThreeDPoint
		{
			return new ThreeDPoint(this.x, this.y, this.z);
		}
		
		private function calcLength():void
		{
			this.length = Math.sqrt((x*x)+(y*y)+(z*z));
		}
		
		public function normalize(newLength:Number=1):void
		{
			calcLength();
			this.x = (this.x/this.length)*newLength;
			this.y = (this.y/this.length)*newLength;
			this.z = (this.z/this.length)*newLength;
			calcLength();
			//trace("length:"+length);
		}
		
		public function minus(withVec:ThreeDPoint):ThreeDPoint
		{
			return new ThreeDPoint(	(this.x-withVec.x),
									(this.y-withVec.y),
									(this.z-withVec.z));
		}

		public function plus(withVec:ThreeDPoint):ThreeDPoint
		{
			return new ThreeDPoint(	(this.x+withVec.x),
									(this.y+withVec.y),
									(this.z+withVec.z));
		}
		
		public function divide(through:Number):ThreeDPoint
		{
			var back:ThreeDPoint = new ThreeDPoint();
			back.x = this.x/through;
			back.y = this.y/through;
			back.z = this.z/through;
			back.w = this.w/through;
			return back;
		}

		public function divideMe(through:Number):void
		{
			this.x/=through;
			this.y/=through;
			this.z/=through;
			this.w/=through;
		}
		
		public function scale(mal:Number):void
		{
			this.x*=mal;
			this.y*=mal;
			this.z*=mal;
		}
		
		public function cross(withVec:ThreeDPoint):ThreeDPoint
		{
			var back:ThreeDPoint = new ThreeDPoint(	
										(this.y*withVec.z)-(this.z*withVec.y),
										(this.z*withVec.x)-(this.x*withVec.z),
										(this.x*withVec.y)-(this.y*withVec.x));
			return back;
		}
		
		public function dot(withVec:ThreeDPoint):Number
		{
			var back:Number =	this.x*withVec.x+
							 	this.y*withVec.y+
								this.z*withVec.z;
			return back;
		}
		
		public function mul(withMatrix:ThreeDMatrix):ThreeDPoint
		{
			var values:ThreeDPoint = new ThreeDPoint();
			
//			trace("before: "+this);
//			withMatrix.traceMe(withMatrix.name);
			values.x = this.x*withMatrix.a+this.y*withMatrix.b+this.z*withMatrix.c+this.w*withMatrix.tx;
			values.y = this.x*withMatrix.d+this.y*withMatrix.e+this.z*withMatrix.f+this.w*withMatrix.ty;
			values.z = this.x*withMatrix.g+this.y*withMatrix.h+this.z*withMatrix.i+this.w*withMatrix.tz;
			values.w = this.x*withMatrix.j+this.y*withMatrix.k+this.z*withMatrix.l+this.w*withMatrix.m;
		
//			trace("after: "+values);
			return values;
		}

		public function rightMul(withMatrix:ThreeDMatrix):ThreeDPoint
		{
			var values:ThreeDPoint = new ThreeDPoint();
			
//			trace("before: "+this);
//			withMatrix.traceMe(withMatrix.name);
			values.x = this.x*withMatrix.a+this.y*withMatrix.d+this.z*withMatrix.g+this.w*withMatrix.j;
			values.y = this.x*withMatrix.b+this.y*withMatrix.e+this.z*withMatrix.h+this.w*withMatrix.k;
			values.z = this.x*withMatrix.c+this.y*withMatrix.f+this.z*withMatrix.i+this.w*withMatrix.l;
			values.w = this.x*withMatrix.tx+this.y*withMatrix.ty+this.z*withMatrix.tz+this.w*withMatrix.m;
		
//			trace("after: "+values);
			return values;
		}

		public function mulMe(withMatrix:ThreeDMatrix):void
		{
			var values:ThreeDPoint = new ThreeDPoint();
			
//			trace("before: "+this);
//			withMatrix.traceMe(withMatrix.name);
			values.x = this.x*withMatrix.a+this.y*withMatrix.b+this.z*withMatrix.c+this.w*withMatrix.tx;
			values.y = this.x*withMatrix.d+this.y*withMatrix.e+this.z*withMatrix.f+this.w*withMatrix.ty;
			values.z = this.x*withMatrix.g+this.y*withMatrix.h+this.z*withMatrix.i+this.w*withMatrix.tz;
			values.w = this.x*withMatrix.j+this.y*withMatrix.k+this.z*withMatrix.l+this.w*withMatrix.m;
		
//			trace("after: "+values);
			this.x = values.x;
			this.y = values.y;
			this.z = values.z;
			this.w = values.w;
//			delete(values);
		}
		
//		public function mulMe(withMatrix:ThreeDMatrix){
//			this = this.mul(withMatrix);
//		}
		
		public function toString():String
		{
			return "ThreeDPoint x:"+x+", y:"+y+", z:"+z+", w:"+w;
		}
		
	}
}// package ThreeDCanvas 3DEngine