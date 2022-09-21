package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import ThreeDPack.Cube;

	public class ScrollBar extends Sprite
	{
		const maxLength:uint = 525;
		const lengthStep:uint = 105;
		const targetY:uint = 132;
		const startY:uint = targetY + (maxLength / 2);
		const moveStep:uint = lengthStep / 2;
		var broadth:int = 20;
		var length:Number = 0;
		var x_offset:int = 5;
		var currPercent:Number;
		var targetField:TextField;
		var handle:Sprite;
		var handleHeight:Number = broadth - 4;
		var handleY:Number = 0;
		var mouseDownY:Number = 0;
		
		public function BindTextfield(targetField:TextField):void
		{
			this.targetField = targetField;
			this.targetField.addEventListener(Event.SCROLL, textFieldScrollHandler);
			length = 0;
			this.x = 670;
			this.y = startY;
			name = "ScrollBar";
			
			handleHeight = broadth - 4;
			handleY = 0;

			updateShapes();
			
			handle.alpha = 0;
		}
		
		public function UnbindTextfield():void
		{
			if (this.targetField)
			{
				this.targetField.removeEventListener(Event.SCROLL, textFieldScrollHandler);
				this.targetField = undefined;
			}
		}
		
		public function textFieldScrollHandler(event:Event):void
		{
			if(undefined!=targetField)
				handleY = (maxLength-handleHeight) * (targetField.scrollV/targetField.maxScrollV);
		}
		public function handleDownHandler(event:MouseEvent):void
		{
			var feeler:Sprite = ThreeDApp.addFeeler();
			mouseDownY = mouseY-handleY;
			feeler.addEventListener(MouseEvent.MOUSE_MOVE, handleMoveHandler);
			feeler.addEventListener(MouseEvent.MOUSE_UP, handleUpHandler);
		}
		public function handleUpHandler(event:MouseEvent):void
		{
			var feeler:Sprite = ThreeDApp.deleteFeeler();
			feeler.removeEventListener(MouseEvent.MOUSE_MOVE, handleMoveHandler);
			feeler.removeEventListener(MouseEvent.MOUSE_UP, handleUpHandler);
		}
		public function handleMoveHandler(event:MouseEvent):void
		{
			if (event.buttonDown)
			{
				handleY = (mouseY-mouseDownY);
				if (handleY < 0)
					handleY = 0;
				if (handleY > (maxLength - handleHeight))
					handleY = (maxLength - handleHeight);
				targetField.scrollV = targetField.maxScrollV * (handleY/(maxLength-handleHeight));
			}
		}
		
		private function updateShapes():void
		{
			graphics.clear();
			
			for (var childIndex = 0; childIndex < numChildren; childIndex++ )
				removeChildAt(childIndex);
			
			handle = new Sprite();
			handle.graphics.lineStyle(1, 0x3D3F3D, 1);
			handle.graphics.beginFill(0x66666f,1);
			handle.graphics.drawRect(x_offset + 2, handleY, broadth-4, handleHeight);
			handle.graphics.endFill();
			handle.addEventListener(MouseEvent.MOUSE_DOWN, handleDownHandler);
			this.addChild(handle);

			graphics.lineStyle(1, 0x3D3F3D, 1);
			graphics.beginFill(0x00FF00, 0);
			graphics.drawRect(x_offset, 0, broadth, length);
			graphics.endFill();
			
			//graphics.lineStyle(1, 0x666666, 1, false, "normal", "none");		
			//graphics.moveTo(width / 2, 0);
			//graphics.lineTo(width / 2, length);
		}
		
		public function Process():void
		{
			var shapeNeedsRedraw:Boolean = false;
			if (targetField != undefined)
			{
				alpha = 1;
				if(length < maxLength)
				{
					length += lengthStep;
					if (length > maxLength) length = maxLength;
					this.y -= moveStep;
					shapeNeedsRedraw = true;
				}
			}
			else
			{
				if (length > 0)
				{
					length -= lengthStep;
					if (length <0) length = 0;
					shapeNeedsRedraw = true;
					this.y += moveStep;
				}
				else alpha = 0;
			}
			if (null != handle)
			{
				if (targetField != undefined)
				{
					var targetHeight = maxLength * ((targetField.bottomScrollV - targetField.scrollV + 1) / targetField.numLines);
					if (handleHeight < targetHeight)
						handleHeight += lengthStep;
					if (handleHeight > targetHeight)
						handleHeight = targetHeight;
					shapeNeedsRedraw = true;
				}
				if (length >= maxLength)
				{
					if(handle.alpha<1)
						handle.alpha += 0.1;
				}
				else
				{
					if(handle.alpha>=0)
						handle.alpha -= 0.1;
					if (handleHeight > 0)
					{
						handleHeight -= lengthStep;
						if (handleHeight < 0) handleHeight = 0;
					}
				}
			}
			if(shapeNeedsRedraw)
				updateShapes();
		}
	}
}