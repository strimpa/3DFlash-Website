package ThreeDPack
{
	import flash.events.MouseEvent;

	/**
	 * @author Gunnar
	 */
	public class MenuElement extends ThreeDObject {
		var category:Number;
		public function MenuElement() {
			super();
		}
		public override function mouseClickHandler(event:MouseEvent):void
		{
			if(getState()==EXTENDED)
				ThreeDApp.resetCurves();
			super.mouseClickHandler(event);
		}
		public override function setState(state:uint)
		{
			ThreeDApp.output("category:"+category);
			if(state==EXTENDED)
			{
				CubeCollection.setCubesActive(true, ""+category);
				Obj2As.setObjectsActive(false);
			}
			if(state==COLLAPSED)
			{
				CubeCollection.setCubesActive(false, ""+category);
				Obj2As.setObjectsActive(true);
			}
			super.setState(state);
		}
	}
}
