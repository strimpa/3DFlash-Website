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
		var pos:ThreeDPoint;

		public function CubeCollection(position:ThreeDPoint) 
		{
			//super("CubeCollection");
			pos = position;

			var rowCount = 5;
			var size = 20;
			var totalWidth:Number = rowCount*size;
			var gap = 2;
			mCubes = new Array(rowCount*rowCount);
			var creationIndex = 0;
			trace("LOADING CUBES!");
			for(var row=0;row<rowCount;row++)
				for(var col=0;col<rowCount;col++)
				{
					var position:ThreeDPoint = new ThreeDPoint(-totalWidth*0.5 + size*row * 1.3, -totalWidth*0.5 + size*col * 1.3, 0);
					//var box = 
					mCubes[creationIndex] = new Cube(size, position, creationIndex, ContentManager.getContent(creationIndex));
					mCubes[creationIndex].name = "higherBox_"+creationIndex;
					ThreeDCanvas.appendToObjects(mCubes[creationIndex]);
					creationIndex++;
				}
		}
		
		function AddCube()
		{
		}
		
		static function setCubesActive(act:Boolean, keyword:String)
		{
			for each(var aCube:Cube in mCubes)
			{
				if(aCube.getContent().mCategory == keyword)
					aCube.setActive(act);
			}
		}
		static function setCubeActive(act:Boolean, index:uint)
		{
			for (var cubeIndex=0; cubeIndex < mCubes.length; cubeIndex++ )
			{
				if (cubeIndex == index)
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
