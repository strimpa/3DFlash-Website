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
//		public static var currentDevDomain:String = "http://localhost/website/";
		public static var currentDevDomain:String = "http://www.gunnardroege.de/";
		public static var flashBinRoot:String = currentDevDomain;// + "3DEngine/bin/";
		public static var htmlRoot:String = currentDevDomain + "contentHtml/";
		public static var contentExtensions:Array = [ "pdf", "zip", "xml" ];
		public static var pictureExtensions:Array = [ "jpg", "png", "mov", "gif"];
		
		public static var needsCubeRotHint = true;
		
		public function globals()
		{
		}
		
		public static function Init()
		{
			textformatSmall = new TextFormat();
	        textformatSmall.font = "Verdana";
	        textformatSmall.color = 0x1D1F1D;
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
			textformatMenuTitle = new TextFormat();
	        textformatMenuTitle.font = edFont.fontName;//"Edwardian Script ITC";//
	        textformatMenuTitle.color = 0xBBBBBB;
	        textformatMenuTitle.size = 60;
	        textformatMenuTitle.underline = false;

			textformatCubeTitle = new TextFormat();
	        textformatCubeTitle.font = edFont.fontName;//"Edwardian Script ITC";//
	        textformatCubeTitle.color = 0xEEEEEE;
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
