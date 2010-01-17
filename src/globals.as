package
{
	/**
	 * @author Gunnar
	 */
	import flash.text.*;

	public class globals {
		public static var textformatSmall:TextFormat;
		public static var textformatSmallBright:TextFormat;
		public static var textformatMenuTitle:TextFormat;
		public static var textformatCubeTitle:TextFormat;
		
		public function globals()
		{
		}
		
		public static function Init()
		{
			textformatSmall = new TextFormat();
	        textformatSmall.font = "Verdana";
	        textformatSmall.color = 0x3D3F3D;
	        textformatSmall.size = 8;
	        textformatSmall.underline = false;
			
			textformatSmallBright = new TextFormat();
	        textformatSmallBright.font = "Verdana";
	        textformatSmallBright.size = 8;
			textformatSmallBright.color = 0xAAAAAA;
		}
		
		public static function InitStreamFont()
		{
			var edFont:Font = ContentManager.fonts[0];
			trace("edFont: "+edFont.fontName);
			textformatMenuTitle = new TextFormat();
	        textformatMenuTitle.font = edFont.fontName;//"Edwardian Script ITC";//
	        textformatMenuTitle.color = 0x888888;
	        textformatMenuTitle.size = 60;
	        textformatMenuTitle.underline = false;

			textformatCubeTitle = new TextFormat();
	        textformatCubeTitle.font = edFont.fontName;//"Edwardian Script ITC";//
	        textformatCubeTitle.color = 0x888888;
	        textformatCubeTitle.size = 40;
	        textformatCubeTitle.underline = false;
		}
		
		public static function stripString(string:String):String
		{
			if(string.charAt(string.length-1)==" ")
				return string.substr(0, string.length - 1);
			return string;
		}
	}
}
