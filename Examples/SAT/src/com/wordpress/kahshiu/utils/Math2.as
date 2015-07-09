package  com.wordpress.kahshiu.utils 
{
	/**
	 * Math2 
	 * -Provide additional Math functionality
	 * @author shiu
	 * @version 1.0	 
	 * Date written:	9 August 2011
	 */
	public class Math2 
	{
		/**
		 * Convert given degree into radian
		 * @param	deg Angle in degree
		 * @return Angle in radian
		 */
		public static function radianOf (deg:Number):Number
		{
			return deg/180*Math.PI;
		}
		
		/**
		 * Convert given radian into degree
		 * @param	rad	Angle in radian
		 * @return Angle in degree
		 */
		public static function degreeOf (rad:Number):Number
		{
			return rad/Math.PI*180;
		}
		
		/**
		 * Perform Pyhtagoras' Theorem on lengths
		 * @param	xDist
		 * @param	yDist
		 * @return
		 */
		public static function Pythagoras(xDist:Number, yDist:Number):Number
		{
			return Math.sqrt(xDist*xDist+yDist*yDist);
		}
		
		/**
		 * Perform cosine rule to calculate the angle between b and c
		 * @param	a	Side of triangle
		 * @param	b	Side of triangle
		 * @param	c	Side of triangle
		 * @return	angle sandwiched between b and c
		 */
		public static function cosineRule(a:Number, b:Number, c:Number):Number
		{
			var angle:Number = (b * b + c * c - a * a) / (2 * b * c);
			return Math.cos(angle);
		}
		
		/**
		 * Bound input value between range
		 * @param	lowerBound Minimum value allowed
		 * @param	upperBound Maximum value allowed
		 * @param	input Current value to bound
		 * @return A value within boundaries
		 */
		public static function implementBound(lowerBound:Number, upperBound:Number, input:Number):Number
		{
			return Math.min(Math.max(lowerBound, input), upperBound);
		}
	}

}