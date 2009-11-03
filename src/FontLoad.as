package
{

	import flash.text.Font;
	import flash.display.Sprite;

	/**
	 * @author Gunnar
	 */
	public class FontLoad extends Sprite{
		//here image/Goudy.ttf points to the font file relative to this file
		[Embed(source="ITCEDSCR.TTF", fontName="Edwardian Script ITC",fontWeight="normal", mimeType="application/x-font-truetype")]
		public var EdFont:Class;
		function FontLoad()
		{
			Font.registerFont(EdFont);//registers font
			trace("Font loaded!");
		}
	}
}
