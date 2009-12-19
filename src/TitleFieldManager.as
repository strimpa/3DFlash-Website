package
{
	/**
	 * @author Gunnar
	 */
	import flash.text.*;
	import flash.geom.Point;
	import flash.display.Sprite;
	import ThreeDPack.CurvedLine;
	import ThreeDPack.ThreeDCanvas;
	import ThreeDPack.ThreeDPoint;
	import ThreeDPack.CurvedLineManager;
	import ThreeDPack.Cube;
	import flash.events.MouseEvent;

	public class TitleFieldManager 
	{
		static var inited:Boolean=false;
		static var mTitleTextFields:Array;
		static var mFieldFading:Array;
		static var mCubes:Array;
		
		function TitleFieldManager()
		{
			mTitleTextFields = new Array(50);
			mFieldFading = new Array(50);
			mCubes = new Array();
		}
		
		public function Init():void
		{
			for(var tf:int = 0;tf<mTitleTextFields.length;tf++)
			{
				mTitleTextFields[tf] = new Sprite();
				var field = new TextField();
				field.name = "textfield";
				field.defaultTextFormat = globals.textformatMenuTitle;
				field.selectable = false;
				field.autoSize = TextFieldAutoSize.LEFT;
				field.embedFonts = true;
				mTitleTextFields[tf].alpha = 0;
				mTitleTextFields[tf].x = 0;
				mTitleTextFields[tf].y = 0;
				mTitleTextFields[tf].addChild(field);
				ThreeDApp.overlaySprite.addChild(mTitleTextFields[tf]);
				mFieldFading[tf] = false;
				
				inited=true;
			}
		}
		
		public static function showTitleAtPoint(title:String, cube:Cube ):Sprite
		{
			if(!inited)
				return undefined;

			var one:ThreeDPoint,two:ThreeDPoint;
			one = cube.position;
			two = cube.position.plus(new ThreeDPoint(100+Math.random()*100,100+Math.random()*100));
			var one2d:Point = new Point(one.x,one.y);
			var two2d:Point =  new Point(two.x,two.y);
			var dist = two2d.subtract(one2d);
	
			var inactive:Sprite;
			var index = 0;
			for each(var tf:Sprite in mTitleTextFields)
			{
				inactive = tf;
				if(tf.alpha<0.2)
					break;
				index++;
			}
			mFieldFading[index] = false;
			var theTextField:TextField =(inactive.getChildByName("textfield") as TextField); 
			theTextField.text = title;
			//theTextField.border = 2;
			//theTextField.borderColor = 0xFFFFFF;
			theTextField.x = two2d.x;
			theTextField.y = two2d.y-50;
			var overflow = (theTextField.x+theTextField.width) - 780;
			if( overflow > 0 )
			{
				theTextField.x -= overflow;
				two2d.x -= overflow;
			}
			
			inactive.alpha = 1;
//			inactive.graphics.clear();
			
			var curve = CurvedLineManager.createCurve(
				//begin_p, control1_p, control2_p, end_p
					one2d,
					one2d.add(new Point(Math.random()*dist.x,Math.random()*dist.y)),
					one2d.add(new Point(Math.random()*dist.x,Math.random()*dist.y)),
					two2d,
					inactive
				);
			if(!curve)
			{
				trace("Couldn't draw curve!!");
			}
			mCubes[index] = cube;
			inactive.addEventListener(MouseEvent.MOUSE_OVER, cube.mouseOverHandler);
			inactive.addEventListener(MouseEvent.MOUSE_OUT, cube.mouseOutHandler);
			return inactive;
		}
		
		public static function fadeOutTitleAtIndex(index:int):Boolean
		{
			if(!inited)
				return false;
			if(mTitleTextFields[index])
			{
				mFieldFading[index] = true;
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public static function fadeOutTitle(field:Sprite):Boolean
		{
			if(!inited)
				return false;
			var index:Number = mTitleTextFields.indexOf(field); 
			if(index!=-1)
			{
				field.removeEventListener(MouseEvent.MOUSE_OVER, mCubes[index].mouseOverHandler);
				mFieldFading[index] = true;
				return true;
			}
			else
			{
				return false;
			}
		}
		
		public function Process():void
		{
			if(!inited)
				return;
			for(var tf:int = 0;tf<mFieldFading.length;tf++)
			{
//				mTitleTextFields[tf].graphics.clear();
				if(mFieldFading[tf])
				{
					mTitleTextFields[tf].alpha -= 0.1;
					if (mTitleTextFields[tf].alpha <= 0)
					{
						mTitleTextFields[tf].graphics.clear();
//						trace("mTitleTextFields[tf].alpha <= 0");
						mFieldFading[tf] = false;
					}
				}
			}
		}
	}
}
