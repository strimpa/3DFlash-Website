package ThreeDPack
{
	import flash.net.URLRequest;
	
	public class Obj2As
	 //extends ThreeDObject
	 {
	
		//var name:String="Obj2As";
		static var filePath:String;
		static var httpStatus:Number;
		static var lorem_lv:TargetLoadVars;
		static var my_txt:String;
		static var objects:Array;
	
		public function Obj2As(filePath:String):void
		{
			//name="Obj2As";
			trace("Obj2As Konstruktor with param: "+filePath);
			filePath = filePath;
			lorem_lv = new TargetLoadVars(this);
			lorem_lv.loadItem(filePath);
		}
	
		public static function onData(data:String):void
		{
			if (data != undefined) {
				my_txt = data;
				parseObjString();
				trace("loaded");
			} else {
				my_txt = "Unable to load external file.";
				trace("error!!");
			}
			//trace("that");
		}
		
		static private function endObject(obj:ThreeDObject, normalsCalculated, smoothingGroupsPresent):void
		{
			obj.calcDepth();
			
			// Set the flag to have no normals artificially calculated
			if(normalsCalculated)
				obj.normalsCalculated = true;
			obj.calcMoveVecs();
			if(smoothingGroupsPresent)
			{
				obj.calcEdgeSmoothFlags();
			}
			ThreeDCanvas.appendToObjects(obj);
		}

		static function setObjectsActive(act:Boolean=true)
		{
			for each(var anObject:ThreeDObject in objects)
			{
				if(!anObject.moving)
					anObject.setActive(act);
			}
		}
		
		static private function parseObjString():void
		{
			objects = new Array(); 
			ThreeDApp.output("loading finished for "+filePath);
			ThreeDApp.output("starting parsing");
			var lines:Array = my_txt.split("\n");
			if(lines != undefined){
				var newObject:MenuElement = new MenuElement();
				newObject.normals = new Array();
//				this.points = new Array();
//				this.polygons= new Array();
				var currSmoothingGroup:Number=0;
				var vertIndex:Number=0;
				var normalIndex:Number=0;
				var polyIndex:Number=0;
				var objectIndex:Number=0;
				for(var lineIndex:Number=0; lineIndex<lines.length;lineIndex++){
					var values:Array;
					ThreeDApp.output(lines[lineIndex]);
//					trace(lines[lineIndex]);
					if(lines[lineIndex].charAt(0)=="g") // object
					{
//						if(newObject!=undefined)
							
						var name:String = lines[lineIndex].substring((lines[lineIndex].indexOf(" ")+1), 
												  						lines[lineIndex].length);
						if(lines[lineIndex].length>1)
						{
							newObject.name = name; 
							ThreeDApp.output("new Object:"+name);
						}
						else
						{
							newObject.category = objectIndex++;
							objects.push(newObject);
							endObject(newObject, normalIndex!=0, currSmoothingGroup>0);
							newObject = new MenuElement();
							newObject.normals = new Array();
							normalIndex = 0;
							vertIndex = 0;
							polyIndex = 0;
							ThreeDApp.output("ended Object:"+newObject.name);
						}
						
					}
					else if(lines[lineIndex].charAt(0)=="s") // smoothing group
					{
						currSmoothingGroup = lines[lineIndex].substring((lines[lineIndex].indexOf(" ")+1), 
												  						lines[lineIndex].length);
						trace("currSmoothingGroup:"+currSmoothingGroup);
						newObject.isMovable = (currSmoothingGroup!=1);
					}
					else if(lines[lineIndex].indexOf("vn")==0)
					{
						values = (lines[lineIndex].substring((lines[lineIndex].indexOf(" ")+2), 
												  						lines[lineIndex].length)
							   					).split(" ");
						newObject.normals.push(new ThreeDPoint(values[0], values[1], values[2]));
						normalIndex++;
//						trace("normalIndex:"+normalIndex+", newObject.normals.length:"+newObject.normals.length);
					}
					else if(lines[lineIndex].charAt(0)=="v")
					{
						values = (lines[lineIndex].substring((lines[lineIndex].indexOf(" ")+2), 
												  						lines[lineIndex].length)
							   					).split(" ");
						newObject.points[vertIndex++] = new ThreeDPoint(values[0], values[1], values[2]);
					}
					else if(lines[lineIndex].charAt(0)=="f")
					{
						// face information
						var faces:Array = new Array();
						var uVs:Array = new Array();
						var newNormals:Array = new Array();
						values = (lines[lineIndex].substring((lines[lineIndex].indexOf(" ")+1), 
																	  	lines[lineIndex].length)
							   					).split(" ");
					
						// vert index/ UV/ normal
						for(var infoSplitInd:Number=0;infoSplitInd<values.length;infoSplitInd++)
						{
							var info:Array = values[infoSplitInd].split("/");
							faces[infoSplitInd] = info[0];
							if(info.length>1)
								uVs[infoSplitInd] = info[1];
							if(info.length>2)
							{
								newNormals[infoSplitInd] = info[2];
							}
						}
							   					
						// 1 to 0 based array indices
						var lowerInd:Number;
						for(lowerInd=0;lowerInd<faces.length;lowerInd++)
						{
							faces[lowerInd] = new Number(newObject.points.length)+new Number(faces[lowerInd]);
						}
						for(lowerInd=0;lowerInd<newNormals.length;lowerInd++)
						{
							newNormals[lowerInd] = new Number(newObject.normals.length)+new Number(newNormals[lowerInd]);
						}
						newObject.addPoly(new Polygon(faces, polyIndex, newObject, newNormals));
						newObject.polygons[polyIndex].smoothingGroup = currSmoothingGroup;
						polyIndex++;
					}
				}
//				trace("point count:"+this.points.length+"\n poly count:"+this.polygons.length);
			}
			
			endObject(newObject, normalIndex!=0, currSmoothingGroup>0);
			
			ThreeDApp.output("Obj2As parsed:"+filePath);
		}
	}
}// package ThreeDCanvas 3DEngine