package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import ThreeDPack.Cube;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ContentControls  extends Sprite
	{
		public static const 
			CONTENTJUMP_LAST = 1,
			CONTENTJUMP_NEXT = 2;
		private const Y_OFFSET:uint = 400;
		private const X_OFFSET_LEFT:uint = 100;
		private const X_OFFSET_RIGHT:uint = 720;

		var x_offset:int = 5;
		var nextContentPage:ArrowButton;
		var lastContentPage:ArrowButton;
		var contentJumpFlags:uint = 0;
		var active:Boolean = false;
		var currentAlpha:Number = 0;
		
		public function ContentControls()
		{
			lastContentPage = new ArrowButton();
			lastContentPage.x = X_OFFSET_LEFT;
			lastContentPage.y = Y_OFFSET;
/*			lastContentPage.graphics.lineStyle(1, 0x3D3F3D, 1);
			lastContentPage.graphics.beginFill(0x66666f, 1);
			lastContentPage.graphics.moveTo(X_OFFSET_LEFT, 		Y_OFFSET);
			lastContentPage.graphics.lineTo(X_OFFSET_LEFT-50, 	Y_OFFSET+50);
			lastContentPage.graphics.lineTo(X_OFFSET_LEFT, 		Y_OFFSET+100);
			lastContentPage.graphics.lineTo(X_OFFSET_LEFT, 		Y_OFFSET);
			lastContentPage.graphics.endFill();
*/			lastContentPage.alpha = 0;
			this.addChild(lastContentPage);

			nextContentPage = new ArrowButton();
			nextContentPage.rotation = 180;
			nextContentPage.x = X_OFFSET_RIGHT;
			nextContentPage.y = Y_OFFSET;
/*			nextContentPage.graphics.lineStyle(1, 0x3D3F3D, 1);
			nextContentPage.graphics.beginFill(0x66666f,1);
			nextContentPage.graphics.moveTo(X_OFFSET_RIGHT, 		Y_OFFSET);
			nextContentPage.graphics.lineTo(X_OFFSET_RIGHT+50, 		Y_OFFSET+50);
			nextContentPage.graphics.lineTo(X_OFFSET_RIGHT, 		Y_OFFSET+100);
			nextContentPage.graphics.lineTo(X_OFFSET_RIGHT, 		Y_OFFSET);
			nextContentPage.graphics.endFill();
*/			nextContentPage.alpha = 0;
			this.addChild(nextContentPage);
		}
		
		public function nextContentCLickedHanlder(event:MouseEvent)
		{
			var currCube:ThreeDPack.Cube = ThreeDPack.ThreeDCanvas.currActiveCube;
			if (undefined != currCube)
			{
				var func:Function = currCube.AutoRotateRight;
				if (event.currentTarget == lastContentPage)
					func = currCube.AutoRotateLeft;
				currCube.collapsePolygons(ThreeDPack.DrawElement.COLLAPSED, func);
			}
		}
		public function Show()
		{
			active = true;
		}
		public function Hide()
		{
			active = false;
		}
		
		public function SetJumpFlags(flags:uint)
		{
			contentJumpFlags = flags;
			if (contentJumpFlags & CONTENTJUMP_LAST)
			{
				lastContentPage.alpha = 1;
				lastContentPage.addEventListener(MouseEvent.MOUSE_DOWN, nextContentCLickedHanlder);
			}
			else
			{
				lastContentPage.alpha = 0;
				lastContentPage.removeEventListener(MouseEvent.MOUSE_DOWN, nextContentCLickedHanlder);
			}
			if (contentJumpFlags & CONTENTJUMP_NEXT)
			{
				nextContentPage.alpha = 1;
				nextContentPage.addEventListener(MouseEvent.MOUSE_DOWN, nextContentCLickedHanlder);
			}
			else
			{
				nextContentPage.alpha = 0;
				nextContentPage.removeEventListener(MouseEvent.MOUSE_DOWN, nextContentCLickedHanlder);
			}
		}
		
		private function updateShapes():void
		{
//			for (var childIndex = 0; childIndex < numChildren; childIndex++ )
//				removeChildAt(childIndex);
		}
		
		public function Process():void
		{
			var shapeNeedsRedraw:Boolean = true;
			if(active && alpha < 1.0)
				alpha += 0.1;
			else if(!active && alpha > 0.0)
				alpha -= 0.1;
			else 
				shapeNeedsRedraw = false;
			if(shapeNeedsRedraw)
				updateShapes();
		}
	}	
}