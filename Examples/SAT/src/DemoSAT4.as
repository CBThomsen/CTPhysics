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
	
	public class DemoSAT4 extends Sprite
	{
		private var hex:SimpleSquare;
		private var tri:SimpleSquare;
		private var t:TextField;
		
		public function DemoSAT4() {
			makeBoxes();
			t = new TextField(); addChild(t);
			t.autoSize = TextFieldAutoSize.LEFT
		}
		
		private function makeBoxes():void {
			hex = new SimpleSquare(); addChild(hex); hex.name="box1"
			hex.prepareBox(
				new Point(200, 200), 
				new Point( 50, 0), 
				new Point( 30, 30), 
				new Point( -30, 30), 
				new Point( -50, 0), 
				new Point( -30, -30),
				new Point( 30, -30)
			)
			hex.drawBox();
			hex.addEventListener(MouseEvent.MOUSE_DOWN, move);
			hex.addEventListener(MouseEvent.MOUSE_UP, move);
			
			tri = new SimpleSquare(); addChild(tri); hex.name="box2"
			tri.prepareBox(
				new Point(300, 200), 
				new Point( 50, 0), 
				new Point( -30, 50),
				new Point( -30, -50)
			)
			tri.drawBox();
			tri.addEventListener(MouseEvent.MOUSE_DOWN, move);
			tri.addEventListener(MouseEvent.MOUSE_UP, move);
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
				hex.addAngle(0.2); refresh()
			}
			if (e.keyCode == Keyboard.T) {
				tri.addAngle(0.2); refresh()
			}
		}
		
		private function refresh():void {
			//prepare the normals
			var normals_hex:Vector.<Vector2d> = hex.getNorm();
			var normals_tri:Vector.<Vector2d> = tri.getNorm();
			
			var vecs_hex:Vector.<Vector2d> = prepareVector(hex);
			var vecs_tri:Vector.<Vector2d> = prepareVector(tri);
			var isSeparated:Boolean = false;
			
			//use hexagon's normals to evaluate
			for (var i:int = 0; i < normals_hex.length; i++) 
			{
				var result_box1:Object = getMinMax(vecs_hex, normals_hex[i]);
				var result_box2:Object = getMinMax(vecs_tri, normals_hex[i]);
				
				isSeparated = result_box1.max_proj < result_box2.min_proj || result_box2.max_proj < result_box1.min_proj
				if (isSeparated) break;
			}
			//use triangle's normals to evaluate
			if (!isSeparated) {
				for (var j:int = 1; j < normals_tri.length; j++) 
				{
					var result_P1:Object = getMinMax(vecs_hex, normals_tri[j]);
					var result_P2:Object = getMinMax(vecs_tri, normals_tri[j]);
					
					isSeparated = result_P1.max_proj < result_P2.min_proj || result_P2.max_proj < result_P1.min_proj
					if (isSeparated) break;
				}
			}
			
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
			
			for (var i:int = 0; i < current_box.dots.length; i++) {
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