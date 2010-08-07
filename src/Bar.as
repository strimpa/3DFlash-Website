import flash.display

class Bar extends Sprite
{
	var length:int;
	var width:int = 20;
	var currPercent:Number;
	var handle:Sprite;
	
	public function Scrollbar(targetField:TextField)
	{
		handle = new Sprite();
		handle.graphics.beginFill(0xFF0000,1);
		handle.graphics.lineStyle(1, 0x666666, 1, false, "normal", "none");		
		handle.graphics.drawCircle(width / 2, width / 2, width);
		handle.graphics.endFill();
		this.addChild(handle);
		
		var line:Sprite = new Sprite();
		line.graphics.lineStyle(1, 0x666666, 1, false, "normal", "none");		
		line.graphics.moveTo(width / 2, 0);
		line.graphics.lineTo(width / 2, length);
		line
		
		length = targetField._height;
		targetField.addChild(this);
		this.x = targetField._x + targetField._width;
		this.y = targetField._y;
	}
}