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
	
	public class DemoSAT3 extends Sprite
	{
		private var box1:SimpleSquare;
		private var box2:SimpleSquare;
		private var t:TextField;
		
		public function DemoSAT3() {
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
		
		private function update(e:Event):void {
			refresh()
		}
		
		private function rotate (e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.R) {
				box1.addAngle(0.2); refresh()
			}
			if (e.keyCode == Keyboard.T) {
				box2.addAngle(0.2); refresh()
			}
		}
		
		private function refresh():void {
			//prepare the normals
			var normals_box1:Vector.<Vector2d> = box1.getNorm();
			var normals_box2:Vector.<Vector2d> = box2.getNorm();
			
			var vecs_box1:Vector.<Vector2d> = prepareVector(box1);
			var vecs_box2:Vector.<Vector2d> = prepareVector(box2);
			
			//results of P, Q
			var result_P1:Object = getMinMax(vecs_box1, normals_box1[1]);
			var result_P2:Object = getMinMax(vecs_box2, normals_box1[1]);
			var result_Q1:Object = getMinMax(vecs_box1, normals_box1[0]);
			var result_Q2:Object = getMinMax(vecs_box2, normals_box1[0]);
			
			//results of R, S
			var result_R1:Object = getMinMax(vecs_box1, normals_box2[1]);
			var result_R2:Object = getMinMax(vecs_box2, normals_box2[1]);
			var result_S1:Object = getMinMax(vecs_box1, normals_box2[0]);
			var result_S2:Object = getMinMax(vecs_box2, normals_box2[0]);
			
			var separate_p:Boolean = result_P1.max_proj < result_P2.min_proj || result_P2.max_proj < result_P1.min_proj
			var separate_Q:Boolean = result_Q1.max_proj < result_Q2.min_proj || result_Q2.max_proj < result_Q1.min_proj
			var separate_R:Boolean = result_R1.max_proj < result_R2.min_proj || result_R2.max_proj < result_R1.min_proj
			var separate_S:Boolean = result_S1.max_proj < result_S2.min_proj || result_S2.max_proj < result_S1.min_proj
			
			var isSeparated:Boolean = false;
			
			/*for (var i:int = 1; i < normals_box1.length-1; i++) 
			{
				var result_box1:Object = getMinMax(vecs_box1, normals_box1[i]);
				var result_box2:Object = getMinMax(vecs_box2, normals_box1[i]);
				
				isSeparated = result_box1.max_proj < result_box2.min_proj || result_box2.max_proj < result_box1.min_proj
				if (isSeparated) break;
			}
			if (!isSeparated) {
				for (var j:int = 1; j < normals_box2.length-1; j++) 
				{
					var result_P1:Object = getMinMax(vecs_box1, normals_box1[j]);
					var result_P2:Object = getMinMax(vecs_box2, normals_box1[j]);
					
					isSeparated = result_P1.max_proj < result_P2.min_proj || result_P2.max_proj < result_P1.min_proj
					if (isSeparated) break;
				}
			}*/
			
			isSeparated = separate_p || separate_Q || separate_R || separate_S
			if (isSeparated) t.text = "Separated boxes"
			else t.text = "Collided boxes."
		}
		
		
		
		/**
		 * Prepares the coordinates to vector data
		 * @param	current_box	box object
		 * @return	array of vectors
		 */
		private function prepareVector(current_box:SimpleSquare):Vector.<Vector2d> {
			var vecs_box:Vector.<Vector2d> = new Vector.<Vector2d>;
			
			for (var i:int = 0; i < 5; i++) {
				var corner_box:Point = current_box.getDot(i)
				vecs_box.push(new Vector2d(corner_box.x, corner_box.y));
			}
			
			return vecs_box;
		}
		
		/**
		 * Calculates the min-max projections 
		 * @param	vecs_box	vectors to box coordinate
		 * @param	axis		axis currently evaluating
		 * @return	object array of [min, min_index, max, max_index]
		 */
		private function getMinMax(vecs_box:Vector.<Vector2d>, axis:Vector2d):Object
		{
			var min_proj_box:Number = vecs_box[1].dotProduct(axis); var min_dot_box:int = 1;
			var max_proj_box:Number = vecs_box[1].dotProduct(axis); var max_dot_box:int = 1;
			
			for (var j:int = 2; j < vecs_box.length; j++) 
			{
				var curr_proj:Number = vecs_box[j].dotProduct(axis)
				//select the maximum projection on axis to corresponding box corners
				if (min_proj_box > curr_proj) {
					min_proj_box = curr_proj
					min_dot_box = j
				}
				//select the minimum projection on axis to corresponding box corners
				if (curr_proj> max_proj_box) {
					max_proj_box = curr_proj
					max_dot_box = j
				}
			}
			return { 
				min_proj:min_proj_box,
				max_proj:max_proj_box,
				min_index:min_dot_box,
				max_index:max_dot_box
			}
		}
	}

}