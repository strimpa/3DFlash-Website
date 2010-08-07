package
{
	import flash.display.LoaderInfo;
	import ThreeDPack.Polygon;
	
	public class LoadingStruct
	{
		public var myInfo:LoaderInfo;
		public var myName:String;
		public var myOwner:Polygon;
		
		public function LoadingStruct(eventTarget:LoaderInfo, name:String, owner:Polygon):void
		{
			this.myName = name;
			this.myInfo = eventTarget;
			this.myOwner = owner;
		}
		
		public function deleteOwnerRef():void
		{
			if(myOwner!=undefined)
			{
				var refIndex:int = myOwner.myCurrentLoaders.indexOf(myInfo);
				myOwner.myCurrentLoaders.splice(refIndex, 1);
				if(myOwner.myCurrentLoaders.length==0)
				{
					myOwner.OnLoaded();
				}
			}
		}
	}
}