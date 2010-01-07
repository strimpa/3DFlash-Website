package ThreeDPack
{
	/**
	 *  Representing a 4x4 Matrix
	 *  
	 *  | a b c tx  |
	 *  | d e f ty  |
	 *  | g h i tz  |
	 *  | j k l <1> |
	 */
	public class ThreeDMatrix
	{
		var a:Number;
		var b:Number;
		var c:Number;
		var d:Number;
		var e:Number;
		var f:Number;
		var g:Number;
		var h:Number;
		var i:Number;
		var j:Number;
		var k:Number;
		var l:Number;
		var tx:Number;
		var ty:Number;
		var tz:Number;
		var m:Number;
		
		var name:String;
		var isProjState:Boolean = false;
		
		public function ThreeDMatrix(name:String="default name")
		{
			Identity();
			this.name = name; 
		}
		
		public function clone():ThreeDMatrix
		{
			var back:ThreeDMatrix = new ThreeDMatrix(name+"_cloned");
			back.setValues(a, b, c, d, e, f, g, h, i, j, k, l, tx, ty, tz);
			return back;
		}
		
		public function SetIsProjStateMatrix():void
		{
			this.isProjState = true;
		}

		public function IsProjStateMatrix():Boolean
		{
			return isProjState;
		}

		public function Identity():void
		{
			// Identity Matrix
			this.a = 1;
			this.b = 0;
			this.c = 0;
			this.d = 0;
			this.e = 1;
			this.f = 0;
			this.g = 0;
			this.h = 0;
			this.i = 1;
			this.j = 0;
			this.k = 0;
			this.l = 0;
			this.tx = 0;
			this.ty = 0;
			this.tz = 0;
			this.m = 1;
		}
		
		public function IsIdentity():Boolean
		{
			// Identity Matrix
			return this.a == 1 &&
			this.b == 0 &&
			this.c == 0 &&
			this.d == 0 &&
			this.e == 1 &&
			this.f == 0 &&
			this.g == 0 &&
			this.h == 0 &&
			this.i == 1 &&
			this.j == 0 &&
			this.k == 0 &&
			this.l == 0 &&
			this.tx == 0 &&
			this.ty == 0 &&
			this.tz == 0 &&
			this.m == 1;
		}
		
		public function ScaleValues(by:Number, ignorePos:Boolean=false)
		{
			// Identity Matrix
			this.a = 1+(this.a-1)*by;
			this.b *= by;
			this.c *= by;
			this.d *= by;
			this.e = 1+(this.e-1)*by;
			this.f *= by;
			this.g *= by;
			this.h *= by;
			this.i = 1+(this.i-1)*by;
			this.j *= by;
			this.k *= by;
			this.l *= by;
			if(!ignorePos)
			{
				this.tx *= by;
				this.ty *= by;
				this.tz *= by;
			}
			this.m = 1+(this.m-1)*by;

			if(0.01>Math.abs(this.a-1)) this.a = 1;
			if(0.01>Math.abs(this.b)) this.b = 0;
			if(0.01>Math.abs(this.c)) this.c = 0;
			if(0.01>Math.abs(this.d)) this.d = 0;
			if(0.01>Math.abs(this.e-1)) this.e = 1;
			if(0.01>Math.abs(this.f)) this.f = 0;
			if(0.01>Math.abs(this.g)) this.g = 0;
			if(0.01>Math.abs(this.h)) this.h = 0;
			if(0.01>Math.abs(this.i-1)) this.i = 1;
			if(0.01>Math.abs(this.j)) this.j = 0;
			if(0.01>Math.abs(this.k)) this.k = 0;
			if(0.01>Math.abs(this.l)) this.l = 0;
			if(!ignorePos)
			{
				if(0.01>Math.abs(this.tx)) this.tx = 0;
				if(0.01>Math.abs(this.ty)) this.ty = 0;
				if(0.01>Math.abs(this.tz)) this.tz = 0;
			}
			if(0.01>Math.abs(this.m-1))this.m = 1;
		}
		
		static function tweenValues(from:ThreeDMatrix, to:ThreeDMatrix, by:Number):ThreeDMatrix
		{
			var back:ThreeDMatrix = new ThreeDMatrix();
			back.a = from.a+(to.a-from.a)*by;
			back.b = from.b+(to.b-from.b)*by;
			back.c = from.c+(to.c-from.c)*by;
			back.d = from.d+(to.d-from.d)*by;
			back.e = from.e+(to.e-from.e)*by;
			back.f = from.f+(to.f-from.f)*by;
			back.g = from.g+(to.g-from.g)*by;
			back.h = from.h+(to.h-from.h)*by;
			back.i = from.i+(to.i-from.i)*by;
			back.j = from.j+(to.j-from.j)*by;
			back.k = from.k+(to.k-from.k)*by;
			back.l = from.l+(to.l-from.l)*by;
			back.tx = from.tx+(to.tx-from.tx)*by;
			back.ty = from.ty+(to.ty-from.ty)*by;
			back.tz = from.tz+(to.tz-from.tz)*by;
			back.m = from.m+(to.m-from.m)*by;
			return back;
		}

		public function GetTranslation():ThreeDPoint
		{
			return new ThreeDPoint(tx,ty,tz);
		} 
		
		public function SetTranslation(x:Number, y:Number, z:Number):void
		{
			this.tx = x;
			this.ty = y;
			this.tz = z;
		}

		public function SetTranslationVec(trans:ThreeDPoint):void
		{
			this.tx = trans.x;
			this.ty = trans.y;
			this.tz = trans.z;
		}
	
		public function setValues(	a_p:Number,
									b_p:Number,
									c_p:Number,
									d_p:Number,
									e_p:Number,
									f_p:Number,
									g_p:Number,
									h_p:Number,
									i_p:Number,
									j_p:Number,
									k_p:Number,
									l_p:Number,
									tx_p:Number,
									ty_p:Number,
									tz_p:Number):void
	{
			this.a = a_p;
			this.b = b_p;
			this.c = c_p;
			this.d = d_p;
			this.e = e_p;
			this.f = f_p;
			this.g = g_p;
			this.h = h_p;
			this.i = i_p;
			this.j = j_p;
			this.k = k_p;
			this.l = l_p;
			this.tx = tx_p;
			this.ty = ty_p;
			this.tz = tz_p;
		}

		public function Multiply(by:Number):void
		{
			this.a *= by;
			this.b *= by;
			this.c *= by;
			this.d *= by;
			this.e *= by;
			this.f *= by;
			this.g *= by;
			this.h *= by;
			this.i *= by;
			this.j *= by;
			this.k *= by;
			this.l *= by;
			this.tx *= by;
			this.ty *= by;
			this.tz *= by;
		}

		public function Divide(by:Number):void
		{
			this.a /= by;
			this.b /= by;
			this.c /= by;
			this.d /= by;
			this.e /= by;
			this.f /= by;
			this.g /= by;
			this.h /= by;
			this.i /= by;
			this.j /= by;
			this.k /= by;
			this.l /= by;
			this.tx /= by;
			this.ty /= by;
			this.tz /= by;
		}
		
		public function translate(by_x:Number, by_y:Number, by_z:Number):ThreeDMatrix{
			this.tx += by_x;
			this.ty += by_y;
			this.tz += by_z;
			return this;
		}

		public function translateByVec(by:ThreeDPoint):ThreeDMatrix{
			this.tx += by.x;
			this.ty += by.y;
			this.tz += by.z;
			return this;
		}
	
		public function inverseTranslate(by_x:Number, by_y:Number, by_z:Number):ThreeDMatrix{
			this.j -= by_x;
			this.k -= by_y;
			this.l -= by_z;
			return this;
		}
		
		public function Translation():ThreeDPoint
		{
			return new ThreeDPoint(
				this.tx,
				this.ty,
				this.tz
			);
		}
		
		public function scale(malx:Number,maly:Number,malz:Number):void{
			this.a*=malx;
			this.e*=maly;
			this.i*=malz;
		}
		
		public function rotate(alpha:Number, beta:Number, gamma:Number):void
		{
			alpha = (alpha/180)*Math.PI;
			beta = (beta/180)*Math.PI;
			gamma = (gamma/180)*Math.PI;
			this.a = Math.cos(beta)*Math.cos(gamma);
			this.b = Math.sin(alpha)*Math.sin(beta)*Math.cos(gamma)+Math.cos(alpha)*Math.sin(gamma);
			this.c = -Math.cos(alpha)*Math.sin(beta)*Math.cos(gamma)+Math.sin(alpha)*Math.sin(gamma);
			this.d = -Math.cos(beta)*Math.sin(gamma);
			this.e = -Math.sin(alpha)*Math.sin(beta)*Math.sin(gamma)+Math.cos(alpha)*Math.cos(gamma);
			this.f = Math.cos(alpha)*Math.sin(beta)*Math.sin(gamma)+Math.sin(alpha)*Math.cos(gamma);
			this.g = Math.sin(beta);
			this.h = -Math.sin(alpha)*Math.cos(beta);
			this.i = Math.cos(alpha)*Math.cos(beta);
		}

		public function addRotationX(alpha:Number):void
		{
			alpha = (alpha/180)*Math.PI;
//			this.e += -Math.sin(alpha)+Math.cos(alpha);
//			this.f += Math.cos(alpha)+Math.sin(alpha);
//			this.h += -Math.sin(alpha);
//			this.i += Math.cos(alpha);
		}
		
		public function addRotationY(beta:Number):void
		{
//			beta = (beta/180)*Math.PI;
//			this.a = Math.cos(beta)*Math.cos(gamma);
//			this.b = Math.sin(alpha)*Math.sin(beta)*Math.cos(gamma)+Math.cos(alpha)*Math.sin(gamma);
//			this.c = -Math.cos(alpha)*Math.sin(beta)*Math.cos(gamma)+Math.sin(alpha)*Math.sin(gamma);
//			this.d = -Math.cos(beta)*Math.sin(gamma);
//			this.e = -Math.sin(alpha)*Math.sin(beta)*Math.sin(gamma)+Math.cos(alpha)*Math.cos(gamma);
//			this.f = Math.cos(alpha)*Math.sin(beta)*Math.sin(gamma)+Math.sin(alpha)*Math.cos(gamma);
//			this.g = Math.sin(beta);
//			this.h = -Math.sin(alpha)*Math.cos(beta);
//			this.i = Math.cos(alpha)*Math.cos(beta);
		}

		public function addRotationZ(gamma:Number):void
		{
			gamma = (gamma/180)*Math.PI;
			this.a *= Math.cos(gamma);
			this.b *= -Math.sin(gamma);
			this.d *= Math.sin(gamma);
			this.e *= Math.cos(gamma);
			this.traceMe("addRotationZ");
		}

		public function makeProjMatrixOld(near:Number):void{
			//var radAngle = (viewAngle/180)*Math.PI;
			this.l = 1.0/near;
			this.traceMe();
		}
		
		public function makeProjectionMatrix(
				near_plane:Number, 	// Distance to near clipping 
                   					// plane
                far_plane:Number, 	// Distance to far clipping 
                                    // plane
                fov_horiz:Number, 	// Horizontal field of view 
                                    // angle, in radians
                fov_vert:Number,  	// Vertical field of view 
                                    // angle, in radians
                width:Number,
                height:Number
                                    )
		:void
		{
		    var    h:Number, w:Number, Q:Number;
		
		    w = 1/Math.tan(fov_horiz*0.5);  // 1/tan(x) == cot(x)
		    h = 1/Math.tan(fov_vert*0.5);   // 1/tan(x) == cot(x)
//			w = (2*near_plane)/width;
//			h = (2*near_plane)/height;
		    Q = far_plane/(far_plane - near_plane);
		
		    this.a = w;
		    this.e = h;
		    this.i = Q;
		    this.tz = -(Q*near_plane);
//		    this.tx = 1/w;
//		    this.ty = 1/w;
		    this.l = 1;
		    this.m = 0;
		    
//			this.traceMe();
		}   // End of ProjectionMatrix
		
		public function applyProjection(currPointState:ThreeDPoint):ThreeDPoint{
			currPointState.mulMe(this);
			//trace("in between: "+currPointState);
			//currPointState.divide(currPointState.w);
			
			// preserving z for depth calculation
			currPointState.x/=currPointState.w;
			currPointState.y/=currPointState.w;
			currPointState.w=1;//currPointState.w;
			return currPointState;
		}
	
		function MakeAxisRotationMatrix(axis:ThreeDPoint, angle:Number)
		{
			var x = axis.x;
			var y = axis.y;
			var z = axis.z;
			var x2 = x*x;
			var y2 = y*y;
			var z2 = z*z;
			var sinOmega = Math.sin(angle);
			var cosOmega = Math.cos(angle);

			this.a = x2+(y2+z2)*cosOmega;
			this.b = x*y*(1-cosOmega)-z*sinOmega;
			this.c = x*z*(1-cosOmega)+y*sinOmega;
			
			this.d = x*y*(1-cosOmega)+z*sinOmega;
			this.e = y2+(x2+z2)*cosOmega;
			this.f = y*z*(1-cosOmega)-x*sinOmega;
			
			this.g = x*z*(1-cosOmega)-y*sinOmega;
			this.h = y*z*(1-cosOmega)+x*sinOmega;
			this.i = z2+(x2+y2)*cosOmega;
			
			this.j = 0;
			this.k = 0;
			this.l = 0;
			
			this.m = 1;
//			this.traceMe();
		}
	
		public function mul(withMatrix:ThreeDMatrix):ThreeDMatrix
		{
			var back:ThreeDMatrix = new ThreeDMatrix();
			back.setValues(
				this.a*withMatrix.a+this.b*withMatrix.d+this.c*withMatrix.g+this.tx*withMatrix.j,
				this.a*withMatrix.b+this.b*withMatrix.e+this.c*withMatrix.h+this.tx*withMatrix.k,
				this.a*withMatrix.c+this.b*withMatrix.f+this.c*withMatrix.i+this.tx*withMatrix.l,
				
				this.d*withMatrix.a+this.e*withMatrix.d+this.f*withMatrix.g+this.ty*withMatrix.j,
				this.d*withMatrix.b+this.e*withMatrix.e+this.f*withMatrix.h+this.ty*withMatrix.k,
				this.d*withMatrix.c+this.e*withMatrix.f+this.f*withMatrix.i+this.ty*withMatrix.l,
				
				this.g*withMatrix.a+this.h*withMatrix.d+this.i*withMatrix.g+this.tz*withMatrix.j,
				this.g*withMatrix.b+this.h*withMatrix.e+this.i*withMatrix.h+this.tz*withMatrix.k,
				this.g*withMatrix.c+this.h*withMatrix.f+this.i*withMatrix.i+this.tz*withMatrix.l,
				
				this.j*withMatrix.a+this.k*withMatrix.d+this.l*withMatrix.g+withMatrix.j,
				this.j*withMatrix.b+this.k*withMatrix.e+this.l*withMatrix.h+withMatrix.k,
				this.j*withMatrix.c+this.k*withMatrix.f+this.l*withMatrix.i+withMatrix.l,
				
				this.a*withMatrix.tx+this.b*withMatrix.ty+this.c*withMatrix.tz+this.tx,
				this.d*withMatrix.tx+this.e*withMatrix.ty+this.f*withMatrix.tz+this.ty,
				this.g*withMatrix.tx+this.h*withMatrix.ty+this.i*withMatrix.tz+this.tz);
				
			return back;
		}
		
//		public function mulMe(withMatrix:ThreeDMatrix){
//			var newOne = this.mul(withMatrix);
//			this=newOne;
//		}

	/*
	 *  | a b c tx  |
	 *  | d e f ty  |
	 *  | g h i tz  |
	 *  | j k l <1> |
	 */

		public function Transpose():ThreeDMatrix
		{
			var back:ThreeDMatrix  = this.clone();
			back.b = this.d;
			back.c = this.g;
			back.d = this.b;
			back.f = this.h;
			back.g = this.c;
			back.h = this.f;
//			back.j = this.tx;
//			back.k = this.ty;
//			back.l = this.tz;
//			back.tx = this.j;
//			back.ty = this.k;
//			back.tz = this.l;
			return back;
		}

		public function Inverse():ThreeDMatrix
		{
			// Determinante version
			var back = Adjunkte(); 
			var determinante = Determinante(); 
//			back.traceMe();
//			trace("determinante:"+determinante);
			back.Divide(determinante);
			return back;
		}
		public function Determinante():Number
		{
			var val = 
				this.a * Determinant2x2(new Array(e,f,h,i)) -
				this.b * Determinant2x2(new Array(d,f,g,i)) +
				this.c * Determinant2x2(new Array(d,e,g,h));
			return val;
		}
		public function Determinant2x2(values:Array):Number
		{
			return values[0]*values[3] - values[2]*values[1];
		}
		public function Adjunkte():ThreeDMatrix
		{
			var ret:ThreeDMatrix = new ThreeDMatrix();
				ret.setValues(
				Determinant2x2(new Array(e,f,h,i)), -Determinant2x2(new Array(b,c,h,i)), Determinant2x2(new Array(b,c,e,f)),
				-Determinant2x2(new Array(d,f,g,i)), Determinant2x2(new Array(a,c,g,i)), -Determinant2x2(new Array(a,c,d,f)),
				Determinant2x2(new Array(d,e,g,h)), -Determinant2x2(new Array(a,b,g,h)), Determinant2x2(new Array(a,b,d,e)),
				0,0,0,
				0,0,0
			);
			return ret;
		}
		
		public function traceMe(msg=""):void{
			trace(msg+": \n"+a+", "+b+", "+c+", "+tx+", \n"+d+", "+e+", "+f+", "+ty+", \n"+g+", "+h+", "+i+", "+tz+", \n"+j+", "+k+", "+l+", "+m);
		}
	}
}// package 3DEngine