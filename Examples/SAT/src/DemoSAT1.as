package  
{
	
	import com.wordpress.kahshiu.utils.Vector2d;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * ...
	 * @author Shiu
	 */
	[SWF(width = '400', height = '300')]
	
	public class DemoSAT1 extends Sprite
	{
		private var box1:SimpleSquare;
		private var box2:SimpleSquare;
		private var t:TextField;
		
		public function DemoSAT1() 
		{
			makeBoxes();
			t = new TextField(); addChild(t);
			t.autoSize = TextFieldAutoSize.LEFT
		}
		
		private function makeBoxes():void {
			box1 = new SimpleSquare(); addChild(box1);
			box1.prepareBox(
				new Point(200, 200), 
				new Point( 0, -50), 
				new Point( 50, 0), 
				new Point( 0, 50), 
				new Point( -50, 0)
			)
			box1.drawBox();
			box1.addEventListener(MouseEvent.MOUSE_DOWN, move);
			box1.addEventListener(MouseEvent.MOUSE_UP, move);
			
			box2 = new SimpleSquare(); addChild(box2);
			box2.prepareBox(
				new Point(300, 200), 
				new Point( 0, -50), 
				new Point( 50, 0), 
				new Point( 0, 50), 
				new Point( -50, 0)
			)
			box2.drawBox();
			box2.addEventListener(MouseEvent.MOUSE_DOWN, move);
			box2.addEventListener(MouseEvent.MOUSE_UP, move);
		}
		
		public function move (e:MouseEvent):void {
			if (e.type == "mouseDown") {
				e.target.parent.startDrag();
				e.target.addEventListener(Event.ENTER_FRAME, update);
			}
			else if (e.type == "mouseUp") {
				e.target.parent.stopDrag();
				e.target.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		private function update(e:Event):void 
		{
			refresh()
		}
		
		private function refresh():void {
			var dot10:Point = box1.getDot(0);
			var dot11:Point = box1.getDot(1);
			
			var dot20:Point = box2.getDot(0);
			var dot24:Point = box2.getDot(4);
			
			//Actual calculations
			var axis:Vector2d = new Vector2d(1, -1).unitVector;
			var C:Vector2d = new Vector2d(
				dot20.x - dot10.x,
				dot20.y - dot10.y
			)
			var A:Vector2d = new Vector2d(
				dot11.x - dot10.x,
				dot11.y - dot10.y
			)
			var B:Vector2d = new Vector2d(
				dot24.x - dot20.x,
				dot24.y - dot20.y
			)
			var projC:Number = C.dotProduct(axis)
			var projA:Number = A.dotProduct(axis);
			var projB:Number = B.dotProduct(axis);
			
			var gap:Number = projC - projA + projB;	//projB is expected to be a negative value
			trace(projC, projA, projB)
			if (gap > 0) t.text = "There's a gap between both boxes"
			else if (gap > 0) t.text = "Boxes are touching each other"
			else t.text = "Penetration had happened."
			
			//drawing the line
			var stageCenter:Point = new Point(stage.stageWidth >> 1, stage.stageHeight >> 1);
			
			var toBox1:Vector2d = new Vector2d(
				dot10.x - stageCenter.x,
				dot10.y - stageCenter.y
			)
			var toBox2:Vector2d = new Vector2d(
				dot20.x - stageCenter.x,
				dot20.y - stageCenter.y
			)
			
			var offset1:Number = toBox1.dotProduct(axis);
			var beginPoint:Point = new Point(
				stageCenter.x + offset1 * axis.x, 
				stageCenter.y + offset1 * axis.y
			)
			var offset2:Number = toBox2.dotProduct(axis);
			var endPoint:Point = new Point(
				stageCenter.x + offset2 * axis.x, 
				stageCenter.y + offset2 * axis.y
			)
			graphics.clear();
			graphics.lineStyle(1);
			graphics.drawPath(new <int>[1,2],
				new <Number>[
					beginPoint.x,beginPoint.y,
					endPoint.x, endPoint.y,
				]
			)
			graphics.lineStyle(3,0xff0000);
			graphics.drawPath(new <int>[1,2,1,2],
				new <Number>[
					beginPoint.x, beginPoint.y,
					beginPoint.x + projA * axis.x, beginPoint.y + projA * axis.y,
					endPoint.x, endPoint.y,
					endPoint.x + projB * axis.x, endPoint.y + projB * axis.y
				]
			)
		}
		
		
	}

}