package
{
	/**
	 * @author Gunnar
	 */
	import flash.text.*;
	import flash.geom.Point;
	import flash.display.Sprite;
	import ThreeDPack.ThreeDCanvas;

	public class TitleFieldManager 
	{
		static var inited:Boolean=false;
		static var mTitleTextFields:Array;
		static var mFieldFading:Array;
		
		function TitleFieldManager()
		{
			mTitleTextFields = new Array(50);
			mFieldFading = new Array(50);
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
		
		public static function showTitleAtPoint(title:String, position:Point):Sprite
		{
			if(!inited)
				return undefined;
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
			theTextField.x = position.x;
			theTextField.y = position.y;
			var overflow = (theTextField.x+theTextField.width) - 780;
			if( overflow > 0 )
			{
				theTextField.x -= overflow;
				position.x -= overflow;
			}
			
			inactive.alpha = 1;
			inactive.graphics.clear();
			
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
				mTitleTextFields[tf].graphics.clear();
				if(mFieldFading[tf])
					mTitleTextFields[tf].alpha -= 0.1;
				if(mTitleTextFields[tf].alpha<=0)
					mFieldFading[tf]=false;
			}
		}
	}
}
