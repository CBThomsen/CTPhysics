package  
{
	import com.wordpress.kahshiu.Shapes.Circle;
	import com.wordpress.kahshiu.utils.Vector2d;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Shiu
	 */
	public class SimpleSquare extends Sprite
	{
		public var dots:Vector.<Circle>;
		
		public function SimpleSquare() {
			dots = new Vector.<Circle>;
		}	
		
		public function prepareBox(center:Point, ...points):void {
			var cent:Circle = new Circle(10,0);	addChild(cent);
			cent.x = center.x;
			cent.y = center.y;
			
			dots.push(cent)
			
			for each (var item:Point in points) 
			{
				var others:Circle = new Circle(5, 0);	addChild(others);
				others.x = center.x + item.x;
				others.y = center.y + item.y;
				dots.push(others)
			}
		}
		
		public function drawBox():void {
			dots[i].alpha = 0.5
			dots[i].fillColor = 0;
			
			for (var i:int = 1; i < dots.length; i++) 
			{
				dots[i].alpha = 0.5
				dots[i].fillColor = 0;
			}
			
			graphics.clear();
			graphics.lineStyle(1);
			
			var cmd:Vector.<int> = new Vector.<int>;
			var coord:Vector.<Number> = new Vector.<Number>;
			for (var j:int = 1; j < dots.length; j++) 
			{
				if (j == 1) cmd.push(1);
				else cmd.push(2);
				coord.push(dots[j].x, dots[j].y)
			}
			cmd.push(2);
			coord.push(dots[1].x, dots[1].y);
			graphics.drawPath(cmd,	coord)
		}
		
		public function addAngle (value:Number):void {
			for (var i:int = 1; i < dots.length; i++) 
			{
				var xlength:Number = dots[i].x - dots[0].x
				var ylength:Number = dots[i].y - dots[0].y
				dots[i].x = xlength * Math.cos(value) - ylength * Math.sin(value);
				dots[i].y = xlength * Math.sin(value) + ylength * Math.cos(value);
				dots[i].x += dots[0].x;
				dots[i].y += dots[0].y;
			}
			drawBox();
		}
		
		public function getDot(value:int):Point {
			return localToGlobal(new Point(dots[value].x, dots[value].y));
		}
		
		public function getNorm():Vector.<Vector2d> {
			var normals:Vector.<Vector2d> = new Vector.<Vector2d>
			for (var i:int = 1; i < dots.length-1; i++) 
			{
				var currentNormal:Vector2d = new Vector2d(
					dots[i + 1].x - dots[i].x, 
					dots[i + 1].y - dots[i].y
				).normL
				normals.push(currentNormal);
			}
			normals.push(
				new Vector2d(
					dots[1].x - dots[dots.length-1].x, 
					dots[1].y - dots[dots.length-1].y
				).normL
			)
			return normals;
		}
	}

}