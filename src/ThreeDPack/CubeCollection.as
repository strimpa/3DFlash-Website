package ThreeDPack
{

	/**
	 * @author Gunnar
	 */
	public class CubeCollection// extends DrawElement 
	{
		static const left:uint=0;
		static const right:uint=1;
		static const top:uint=1<<1;
		static const bottom:uint=1<<2;
		static const forward:uint=1<<3;
		static const back:uint=1<<4;
		static var mCubes:Array;
		static var mContents:Array;
		private var mCreationNum:uint; 
		var pos:ThreeDPoint;

		public function CubeCollection(position:ThreeDPoint) 
		{
			//super("CubeCollection");
			pos = position;

			var rowCount = 5;
			var size = 20;
			var totalWidth:Number = rowCount*size;
			var gap = 2;
			mCubes = new Array(rowCount * rowCount);
			mContents = new Array(rowCount * rowCount);
			mCreationNum = 0;
			for(var row=0;row<rowCount;row++)
				for(var col=0;col<rowCount;col++)
				{
					var position:ThreeDPoint = new ThreeDPoint(-totalWidth*0.5 + size*row * 1.3, -totalWidth*0.5 + size*col * 1.3, 0);
					//var box = 
					var newContent = ContentManager.getContent(mCreationNum);
					if (null == newContent)
						break;
					mContents.push(newContent);
					mCubes[mCreationNum] = new Cube(size, position, mCreationNum, newContent);
					mCubes[mCreationNum].name = "higherBox_"+mCreationNum;
					ThreeDCanvas.appendToObjects(mCubes[mCreationNum]);
					mCreationNum++;
				}
		}
		
		function AddCube()
		{
		}
		
		public static function findContentCube(title:String):Cube
		{
			for each(var c:Cube in mCubes)
			{
				if (c.getContent().mFolderName == title )
					return c;
			}
			return undefined;
		}
		
		public static function setCubesActiveByCategory(act:Boolean, keyword:String):void
		{
			for each(var aCube:Cube in mCubes)
			{
				if (null == aCube)
					break;
				if(aCube.getContent().mCategory == keyword)
					aCube.setActive(act);
				else
					aCube.setActive(!act);
			}
		}
		public static function setCubesActiveByKeyword(act:Boolean, keyword:String):void
		{
			for each(var aCube:Cube in mCubes)
			{
				if (null == aCube)
					break;
				if (aCube.getContent().mKeywords.indexOf(keyword) != -1)
					aCube.setActive(act);
				else
					aCube.setActive(!act);
			}
		}
		public static function setCubesActiveByIndex(act:Boolean, index:int=-1):void
		{
			for (var cubeIndex=0; cubeIndex < mCubes.length; cubeIndex++ )
			{
				if (null == mCubes[cubeIndex])
					break;
				if (cubeIndex == index || index==-1)
					mCubes[cubeIndex].setActive(act);
				else
					mCubes[cubeIndex].setActive(!act);
			}
		}

//		function draw()
//		{
//		}
	}
}
