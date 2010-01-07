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
		public override function OnCollapsing():void
		{
			CubeCollection.setCubesActive(false, ""+category);
			Obj2As.setObjectsActive(true);
			super.OnCollapsing();
		}
		public override function OnExtending():void
		{
			CubeCollection.setCubesActive(true, ""+category);
			Obj2As.setObjectsActive(false);
			super.OnExtending();
		}
	}
}
