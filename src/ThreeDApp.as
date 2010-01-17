package
{
	import flash.display.Sprite;
	import flash.display.*;
	import flash.net.URLRequest;
	import flash.events.*;
	import myUi.MySlider;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.utils.Timer;
	import ThreeDPack.*;
	import flash.system.Security;

	/**
	 * @author gunnar
	  *  
	  **/
	  
	public class ThreeDApp extends Sprite
	{
		public var noiseSeed:Number = 0;
		
		Security.allowDomain("localhost");
//		Security.allowDomain("www.gunnardroege.de");
		
		// Elements
		public static var elements:Sprite;
		public static var overlaySprite:Sprite;
		public static var debugText:TextField;
		public static var stateOutput:TextField;
		public static var canvas:ThreeDPack.ThreeDCanvas;
		public static var spectrumMiddle:ThreeDPack.ThreeDPoint = new ThreeDPoint(400,400,0);
		public var maskShape:Shape;
		public static var circleRadius:uint = 200;
		public var styleString:String = "	color:#3D3F3D;";

		public static var content:ContentManager;
		static var txtFieldMgr:TitleFieldManager;
		
		public static var keywords:KeywordManager;
		public static var curvedLines:CurvedLineManager;
		public static var loader:LoaderDisplay;
		public static var progress:ProgressTracker;

		// controls
		public var slider:MySlider;
		public var rotButton:SimpleButton;

		public static var image:Bitmap;
		public static var overlayBitmap:BitmapData;
		
		// Frame count
		public var lastSecondVal:Number=0;
		public var lastFrameCount:Number;
		public var frameCount:Number=0;
		
		public var lastDragPos:Point;
		public static var mouseIsOverBackground:Boolean=false;
		public static var mouseLastCubeOver:String = "";
		public static var mouseIsOverObject:Boolean = false;
		
		public static var enableDraw:Boolean = true;
		
		public function ThreeDApp()
		{
			//this.opaqueBackground = 0x000000;
			//canvas.blendMode = BlendMode.HARDLIGHT;
			//overlay.blendMode = BlendMode.ALPHA;
			
			globals.Init();
			txtFieldMgr = new TitleFieldManager();
			lastDragPos = new Point(0,0);
			
			CreateOutput();
			output("starting creation");
			output("loading background");

			elements = new Sprite();
			addChild(elements);
			overlaySprite = new Sprite();
			addChild(overlaySprite);
			loader = new LoaderDisplay(this);
			addChild(loader);

			CreateBG();
			output("create mask");

			maskShape = CreateMask(spectrumMiddle);

			output("create keywordmanager");
			keywords = new KeywordManager(elements);

			CreateOverlay();
			output("create 3D canvas");

			canvas = new ThreeDCanvas();
			elements.addChild(canvas);
			progress = new ProgressTracker();
			elements.addChild(progress);
			output("create bezier overlay");
			CreateBezierOverlay();
			output("create debug elements");
			CreateDebugElements();

			output("adding event listeners");
			this.addEventListener(Event.ENTER_FRAME, draw);

			output("creation finished, starting loading content"); 
			content = new ContentManager();
		}

		public static function InitCanvas(data:Object):void
		{
			output("loading finished, starting");
			canvas.Init(); 
		}
		public static function InitGlobals():void
		{
			globals.InitStreamFont();
			txtFieldMgr.Init();
		}
		
		public function click(event:TimerEvent):void
		{
//			curvedLines.registerPosition(this.stage.mouseX, this.stage.mouseY);
//			trace("Timer event");
		}
		
		public static function resetCurves():void
		{
			CurvedLineManager.doReset();
		}
		
		public function CreateBezierOverlay():void
		{
//			var curvedLines:Loader = new Loader();
//			var url:String = "../leeds/noise/dings.swf";
//			var urlReq:URLRequest = new URLRequest(url);
//			curvedLines.load(urlReq);
			curvedLines = new CurvedLineManager();
			curvedLines.alpha = 0.5;
			curvedLines.cacheAsBitmap = true;
			//elements.addEventListener(MouseEvent.MOUSE_DOWN, click);
//			var timer:Timer = new Timer(50);
//			timer.addEventListener(TimerEvent.TIMER, click); 
//			timer.start();
			elements.addChild(curvedLines);
			curvedLines.x = 0;
			curvedLines.y = 0;
		}
		
		public function CreateBG():void
		{
//			var rect:Shape = new Shape();
//			rect.graphics.beginFill(0x2D2D2D);
//			rect.graphics.lineStyle(0, 0x00000000);
//			rect.graphics.drawRect(0, 0, 1000, 1000);
//			rect.graphics.endFill();
//			addChild(rect);
//			rect.x = 0;

			var bg:Sprite = new Sprite();
			bg.name = "bg";
			bg.addEventListener(MouseEvent.MOUSE_DOWN, mouseClickHandler);
			bg.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			bg.addEventListener(MouseEvent.MOUSE_UP, mouseOutHandler);
			bg.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			bg.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			elements.addChild(bg);
		}
		
		public static function addToBackground(bg:DisplayObject):void
		{
			var theBG:Sprite = elements.getChildByName("bg") as Sprite; 
			theBG.addChild(bg);
		}
		
		public function CreateOverlay():void
		{
//			curvedLines = new Loader();
			overlayBitmap = new BitmapData(1, 50, true, 0xFF1D1D1D);
//			var randomNum:Number = Math.floor(Math.random() * 10);
//        	bitmapData_1.perlinNoise(60, 40, 20, randomNum, false, true, 1, true, null);
 //       	overlayBitmap.noise(500, 40, 50, BitmapDataChannel.ALPHA, true);
        	image = new Bitmap(overlayBitmap);
        	image.scaleX = 600;
        	image.scaleY = 8;
			
//			var url:String = "noise.png";
//			var urlReq:URLRequest = new URLRequest(url);
//			curvedLines.load(urlReq);
//			curvedLines.blendMode = BlendMode.HARDLIGHT;
//			addChild(curvedLines);
//			curvedLines.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
//			curvedLines.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
//			curvedLines.addEventListener(MouseEvent.MOUSE_DOWN, mouseClickHandler);

			elements.addChild(image);
			image.y = 200;
			image.x = 200;
			image.mask = maskShape;
			//image.blendMode = BlendMode.ALPHA;
			//image.filters = new Array(new BlurFilter(15,15,1));

			var border:Shape = new Shape();
			border.graphics.lineStyle(1, 0x3D3F3D);
			border.graphics.drawEllipse(spectrumMiddle.x-circleRadius, spectrumMiddle.y-circleRadius, circleRadius*2, circleRadius*2);
			elements.addChild(border);
		}
		
		public function updateOverlay():void
		{
			if(!overlayBitmap)
				return;
//			var alphaImage:BitmapData = new BitmapData(1, 100, true, 0xFF000000);
//			alphaImage.floodFill(1, 1, 0xFFFFFFFF);
//			overlayBitmap.copyChannel(alphaImage, overlayBitmap.rect, new Point(0,0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			overlayBitmap.noise(noiseSeed++, 15, 50, BitmapDataChannel.ALPHA, false);
		}
		
		public static function CreateMask(origin:ThreeDPack.ThreeDPoint):Shape
		{
			var localMaskShape = new Shape();
			localMaskShape.graphics.beginFill(0x2D2D2D);
			localMaskShape.graphics.lineStyle(0, 0x2D2D2D);
//			localMaskShape.graphics.drawRect(0, 0, 600, 400);
			localMaskShape.graphics.drawEllipse(origin.x-circleRadius, origin.y-circleRadius, circleRadius*2, circleRadius*2);
			localMaskShape.graphics.endFill();
			//addChild(localMaskShape);
			
//			image.mask = localMaskShape;
//			canvas.mask = localMaskShape;
			return localMaskShape; 
		}
		
		public static function SetOverBG(val:Boolean):void
		{
			mouseIsOverBackground=val;
			if(true)
				mouseIsOverObject=false;
		}
		public static function IsOverBG():Boolean
		{
			return mouseIsOverBackground;
		}
		public static function SetOverObject():void
		{
			mouseIsOverObject=true;
			mouseIsOverBackground=false;
		}
		public static function IsOverObject():Boolean
		{
			return mouseIsOverObject;
		}
		public static function SetMouseOverCube(title:String):void
		{
			mouseIsOverBackground=false;
			mouseIsOverObject=false;
			mouseLastCubeOver = title;
		}
		public static function GetLastMouseOverCube():String
		{
			return mouseLastCubeOver;
		}
		public static function IsStillOverThisCube(title:String):Boolean
		{
			return !IsOverBG() && !IsOverObject() && GetLastMouseOverCube()==title;
		}
		
		public function mouseMoveHandler(event:MouseEvent):void
		{
			mouseIsOverBackground=true;
			if(event.buttonDown && lastDragPos)
				mouseDragHandler(event);
			//if(ProgressTracker.getState()==ProgressTracker.SCOPE_SELECT)
				//ProgressTracker.setState(ProgressTracker.START);
		}
		public function mouseOverHandler(event:MouseEvent):void
		{
			lastDragPos = new Point(event.stageY, event.stageX);
			
		}

		public function mouseDragHandler(event:MouseEvent):void
		{
			var dragDelta:Point = new Point(event.stageY, event.stageX).subtract(lastDragPos);
			dragDelta.x = 0;
			canvas.mouseRotate(dragDelta);
			lastDragPos = new Point(event.stageY, event.stageX);
		}

		public function mouseOutHandler(event:MouseEvent):void
		{
			lastDragPos = undefined;
		}

		public function mouseClickHandler(event:MouseEvent):void
		{
			lastDragPos = new Point(event.stageY, event.stageX);
		}
		
		public function CreateOutput():void
		{
			stateOutput = new TextField();
			stateOutput.x = 500;
			stateOutput.y = 180;
			stateOutput.width = 300;
			stateOutput.height = 300;
			stateOutput.multiline = true;
			stateOutput.selectable = false;
			stateOutput.defaultTextFormat = globals.textformatSmall;
			stateOutput.text = "output created\n";
			addChild(stateOutput);
		} 
		
		public function CreateDebugElements():void
		{
			slider =new MySlider(new Point(10, height+20),500,0,0.1,0.0122);
//			addChild(slider);
			slider.setCallback(matrixCallback);
			debugText = new TextField();
			addChild(debugText);
			debugText.x = 100;
			debugText.y = 15;
		
			var buttonShape:Sprite = new Sprite();
			buttonShape.graphics.beginFill(0x888888);
			buttonShape.graphics.drawRect(0,0,50,20);
			buttonShape.graphics.endFill();
			rotButton = new SimpleButton(buttonShape,buttonShape,buttonShape,buttonShape);
			rotButton.addEventListener(MouseEvent.MOUSE_UP, rotButtonClick);
			addChild(rotButton);
			rotButton.x = 10;
			rotButton.y = 20;

//			var loadButtonShape:Sprite = new Sprite();
//			loadButtonShape.graphics.beginFill(0x888888);
//			loadButtonShape.graphics.drawRect(0,0,50,20);
//			loadButtonShape.graphics.endFill();
//			var loadButton:SimpleButton = new SimpleButton(buttonShape,buttonShape,buttonShape,buttonShape);
//			addChild(loadButton);
//			rotButton.x = 10;
//			rotButton.y = -20;
//			loadButton.addEventListener(MouseEvent.MOUSE_DOWN, loadButtonClick);
			
		}
		
		function matrixCallback(value:Number):void
		{
			ThreeDCanvas.projMatrix.Identity();// = new ThreeDMatrix();
			ThreeDCanvas.projMatrix.makeProjectionMatrix(0, 1000, value,value, 1,1);
		}
		
		public function rotButtonClick(event:MouseEvent):void
		{
//			canvas.toggleGlow();
			enableDraw = enableDraw?false:true;
		}
		
		private function loadButtonClick(event:MouseEvent):void
		{
			canvas.load();
		}
		
		public static function output(line:String):void
		{
			stateOutput.appendText(line+"\n");
			var numLines:Number = 20;
			if(stateOutput.numLines>numLines)
			{
				var lastLines:String = ""; 
				for(var lineIndex:Number=0;lineIndex<numLines;lineIndex++)
					lastLines += stateOutput.getLineText(stateOutput.numLines-numLines+lineIndex);
				stateOutput.text = lastLines;
			}
		}
		
		public static function getContent():ContentManager
		{
			return content;
		}
		
		private function draw(event:Event):void
		{
			if(debugText)
				debugText.text = "fps:"+lastFrameCount;//slider.getValue();
			
			var currSecondVal:Number = new Date().getSeconds();
			if(currSecondVal!=lastSecondVal)
			{
				lastSecondVal = currSecondVal;
				lastFrameCount = frameCount;
				frameCount=0;
			}
			frameCount++;

			if(frameCount%3==0)
				updateOverlay();
			
			txtFieldMgr.Process();
			canvas.Process(event);
			canvas.draw(event);
			
			keywords.draw();
			
			curvedLines.Process();
//			CurvedLineManager.doReset();
			curvedLines.draw();
			content.Process();
			
			loader.Process();
			loader.draw();
			
			progress.Process();
		} 
	}
}