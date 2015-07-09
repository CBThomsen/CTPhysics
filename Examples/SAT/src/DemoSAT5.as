package  
{
	import com.wordpress.kahshiu.Shapes.Circle;
	import com.wordpress.kahshiu.utils.Vector2d;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Shiu
	 */
	[SWF(width = '400', height = '300')]
	
	public class DemoSAT5 extends Sprite
	{
		private var box1:SimpleSquare;
		private var c:Circle;
		private var t:TextField;
		
		public function DemoSAT5() {
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
			
			c = new Circle(20); addChild(c); c.x = 100; c.y = 200
			c.addEventListener(MouseEvent.MOUSE_DOWN, move2);
			c.addEventListener(MouseEvent.MOUSE_UP, move2);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, rotate);
		}
		
		private function move (e:MouseEvent):void {
			if (e.type == "mouseDown") {
				e.target.parent.startDrag();
				e.target.addEventListener(Event.ENTER_FRAME, update);
			}
			else if (e.type == "mouseUp") {
				e.target.parent.stopDrag();
				e.target.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		private function move2 (e:MouseEvent):void {
			if (e.type == "mouseDown") {
				e.target.startDrag();
				e.target.addEventListener(Event.ENTER_FRAME, update);
			}
			else if (e.type == "mouseUp") {
				e.target.stopDrag();
				e.target.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		
		private function update(e:Event):void {
			refresh()
		}
		
		private function rotate (e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.R) {
				box1.addAngle(0.2); refresh()
			}
		}
		
		private function refresh():void {
			//prepare the vectors
			var v:Vector2d;
			var current_box_corner:Point;
			var center_box:Point = box1.getDot(0);
			
			var max:Number = Number.NEGATIVE_INFINITY;
			var box2circle:Vector2d = new Vector2d(c.x - center_box.x, c.y - center_box.y)
			var box2circle_normalised:Vector2d = box2circle.unitVector
			
			//get the maximum
			for (var i:int = 1; i < 5; i++) 
			{
				current_box_corner = box1.getDot(i)
				v = new Vector2d(
					current_box_corner.x - center_box.x , 
					current_box_corner.y - center_box.y);
				var current_proj:Number = v.dotProduct(box2circle_normalised)
				
				if (max < current_proj) max = current_proj;
			}
			trace(box2circle.magnitude, max, c.radius);
			trace(box2circle.magnitude - max - c.radius )
			if (box2circle.magnitude - max - c.radius > 0 && box2circle.magnitude > 0) t.text = "No Collision"
			else t.text = "Collision"
		}
	}

}