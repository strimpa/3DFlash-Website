package
{
	/**
	 * @author Gunnar
	 */
	import flash.text.*;

	public class globals {
		static var textformatsmall:TextFormat;
		static var textformatmenutitle:TextFormat;
		
		public function globals()
		{
		}
		
		public static function Init()
		{
			textformatsmall = new TextFormat();
	        textformatsmall.font = "Verdana";
	        textformatsmall.color = 0x3D3F3D;
	        textformatsmall.size = 8;
	        textformatsmall.underline = false;
		}
		
		public static function InitStreamFont()
		{
			var edFont:Font = ContentManager.fonts[0];
			trace("edFont: "+edFont.fontName);
			textformatmenutitle = new TextFormat();
	        textformatmenutitle.font = edFont.fontName;//"Edwardian Script ITC";//
	        textformatmenutitle.color = 0x888888;
	        textformatmenutitle.size = 60;
	        textformatmenutitle.underline = false;
		}
	}
}
