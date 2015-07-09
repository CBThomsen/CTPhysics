package CTPhysics {
	public class CTShape {
		public var width:Number = 0
		public var height:Number = 0
		public var halfWidth:Number
		public var halfHeight:Number

		protected var body:CTBody

		public function CTShape(b:CTBody) {
			body = b
		}
		public function updatePosition() {
			//
		}
	}
}