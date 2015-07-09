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
	
	public class DemoSAT2 extends Sprite
	{
		private var box1:SimpleSquare;
		private var box2:SimpleSquare;
		private var t:TextField;
		
		public function DemoSAT2() 
		{
			makeBoxes();
			t = new TextField(); addChild(t);
			t.autoSize = TextFieldAutoSize.LEFT
		}
		
		private function makeBoxes():void {
			box1 = new SimpleSquare(); addChild(box1); box1.name="box1"
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
			
			box2 = new SimpleSquare(); addChild(box2); box1.name="box2"
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
			stage.addEventListener(KeyboardEvent.KEY_DOWN, rotate);
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
		
		public function rotate (e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.R) {
				box1.addAngle(0.2); refresh()
			}
			if (e.keyCode == Keyboard.T) {
				box2.addAngle(0.2); refresh()
			}
		}
		
		private function refresh():void {
			//preparing the vectors from origin to points
			//since origin is (0,0), we can conveniently take the coordinates 
			//to form vectors
			var axis:Vector2d = new Vector2d(1, -1).unitVector;
			var vecs_box1:Vector.<Vector2d> = new Vector.<Vector2d>;
			var vecs_box2:Vector.<Vector2d> = new Vector.<Vector2d>;
			
			for (var i:int = 0; i < 5; i++) {
				var corner_box1:Point = box1.getDot(i)
				var corner_box2:Point = box2.getDot(i)
				
				vecs_box1.push(new Vector2d(corner_box1.x, corner_box1.y));
				vecs_box2.push(new Vector2d(corner_box2.x, corner_box2.y));
			}
			
			//setting min max for box1
			var min_proj_box1:Number = vecs_box1[1].dotProduct(axis); var min_dot_box1:int = 1;
			var max_proj_box1:Number = vecs_box1[1].dotProduct(axis); var max_dot_box1:int = 1;
			
			for (var j:int = 2; j < vecs_box1.length; j++) 
			{
				var curr_proj1:Number = vecs_box1[j].dotProduct(axis)
				//select the maximum projection on axis to corresponding box corners
				if (min_proj_box1 > curr_proj1) {
					min_proj_box1 = curr_proj1
					min_dot_box1 = j
				}
				//select the minimum projection on axis to corresponding box corners
				if (curr_proj1> max_proj_box1) {
					max_proj_box1 = curr_proj1
					max_dot_box1 = j
				}
			}
			
			box1.drawBox();
			if (max_dot_box1 > 0) box1.dots[max_dot_box1].fillColor = 0xff0000;
			if (min_dot_box1 > 0) box1.dots[min_dot_box1].fillColor = 0xffff00;
			trace(min_dot_box1, max_dot_box1)
			//getting min max for box2
			var min_proj_box2:Number = vecs_box2[1].dotProduct(axis); var min_dot_box2:int = 1;
			var max_proj_box2:Number = vecs_box2[1].dotProduct(axis); var max_dot_box2:int = 1;
			
			for (var k:int = 1; k < vecs_box2.length; k++) {
				var curr_proj2:Number = vecs_box2[k].dotProduct(axis)
				//select the maximum projection on axis to corresponding box corners
				if (max_proj_box2 < curr_proj2) {
					max_proj_box2 = curr_proj2
					max_dot_box2 = k
				}
				//select the minimum projection on axis to corresponding box corners
				if (min_proj_box2 > curr_proj2) {
					min_proj_box2 = curr_proj2
					min_dot_box2 = k
				}
			}
			box2.drawBox();
			if (max_dot_box2 > 0) box2.dots[max_dot_box2].fillColor = 0xff0000;
			if (min_dot_box2 > 0) box2.dots[min_dot_box2].fillColor = 0xffff00;
			
			var isSeparated:Boolean = max_proj_box2 < min_proj_box1 || max_proj_box1 < min_proj_box2
			if (isSeparated) t.text = "There's a gap between both boxes"
			else t.text = "No gap calculated."
			
			//drawing the line
			var startPoint:Point = new Point(stage.stageWidth >> 1, stage.stageWidth >> 1);
			graphics.clear();
			graphics.lineStyle(1);
			graphics.drawPath(new <int>[1,2],
				new <Number>[
					startPoint.x + min_proj_box1 * axis.x,
					startPoint.y + min_proj_box1 * axis.y,
					startPoint.x + max_proj_box2 * axis.x,
					startPoint.y + max_proj_box2 * axis.y
				]
			)	
			graphics.lineStyle(3,0xff0000);
			graphics.drawPath(new <int>[1,2,1,2],
				new <Number>[
					startPoint.x + min_proj_box1 * axis.x,
					startPoint.y + min_proj_box1 * axis.y,
					startPoint.x + max_proj_box1 * axis.x,
					startPoint.y + max_proj_box1 * axis.y,
					
					startPoint.x + min_proj_box2 * axis.x,
					startPoint.y + min_proj_box2 * axis.y,
					startPoint.x + max_proj_box2 * axis.x,
					startPoint.y + max_proj_box2 * axis.y,
				]
			)
			if (!isSeparated) {
				var from:Number = Math.min(max_proj_box1, max_proj_box2)
				var to:Number = Math.max(min_proj_box1, min_proj_box2)
				
				graphics.lineStyle(5, 0);
				if (min_proj_box2 < max_proj_box1) {
					graphics.drawPath(new <int>[1,2],
						new <Number>[
							startPoint.x + from * axis.x,
							startPoint.y + from * axis.y,
							startPoint.x + to * axis.x,
							startPoint.y + to * axis.y
						]
					)
				}
			}
		}
		
		
	}

}