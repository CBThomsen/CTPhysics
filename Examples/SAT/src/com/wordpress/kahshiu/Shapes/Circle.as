package com.wordpress.kahshiu.Shapes 
{
	import flash.display.Sprite;
	/**
	 * Produce a circle
	 * @author Shiu
	 */
	public class Circle extends Sprite
	{
		private var _radius:Number;
		private var _fillColor:Number;
		private var _lineColor:Number;
		
		/**** Class properties ****/
		public function get radius():Number 
		{
			return _radius;
		}
		
		public function set radius(value:Number):void 
		{
			_radius = value;
			redraw()
		}
		
		public function get fillColor():Number 
		{
			return _fillColor;
		}
		
		public function set fillColor(value:Number):void 
		{
			_fillColor = value;
			redraw()
		}
		
		public function get lineColor():Number 
		{
			return _lineColor;
		}
		
		public function set lineColor(value:Number):void 
		{
			_lineColor = value;
			redraw()
		}
		
		/**** Functions ****/
		public function Circle(radius:Number = 10, fillColor:Number=0xff0000, lineColor:Number=0) 
		{
			this._radius = radius;
			this._fillColor = fillColor;
			this._lineColor = lineColor;
			redraw();
		}
		
		private function redraw():void 
		{
			graphics.clear();
			graphics.lineStyle(1, _lineColor);
			graphics.beginFill(_fillColor);
			graphics.drawCircle(0, 0, _radius);
			graphics.endFill();
		}
		
		
		
	}

}