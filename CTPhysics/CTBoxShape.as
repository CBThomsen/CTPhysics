package CTPhysics {
	import CTPhysics.Math.CTVector


	public class CTBoxShape extends CTShape {

		private var localVertices:Array = new Array();
		private var vertices:Array = new Array();

		public function CTBoxShape(b:CTBody) {
			super(b)
		}
		public function setAsBox(w:Number, h:Number) {
			width = w
			height = h
			halfWidth = width/2
			halfHeight = height/2

			localVertices.push(new CTVector(-halfWidth, -halfHeight))
			localVertices.push(new CTVector(halfWidth, -halfHeight))
			localVertices.push(new CTVector(halfWidth, halfHeight))
			localVertices.push(new CTVector(-halfWidth, halfHeight))
		}
		public function rotateVertices(angle:Number) {
			var c:Number = Math.cos(angle)
			var s:Number = Math.sin(angle)
			
			for(var i:int = 0; i < vertices.length; i++) {
				vertices[i].x -= body.x
				vertices[i].y -= body.y
				var xNew = c * vertices[i].x - s * vertices[i].y
				var yNew = s * vertices[i].x + c * vertices[i].y
				vertices[i].x = xNew + body.x
				vertices[i].y = yNew + body.y
			}
		}
		public function getVertices() {
			return vertices;
		}
		override public function updatePosition() {
			for(var i:int = 0; i < localVertices.length; i++) {
				vertices[i] = new CTVector(body.x + localVertices[i].x, body.y + localVertices[i].y)
			}
		}
	}
}