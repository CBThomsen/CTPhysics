package CTPhysics {
	import CTPhysics.Math.CTVector

	public class CTBody {
		public var ctShape:CTBoxShape
		public var ctUserData:*

		public var x:Number = 0
		public var y:Number = 0
		public var invMass:Number = 0
		public var mass:Number = 0
		public var friction:Number = 0.2
		public var restitution:Number = 0.1

		public var rotation:Number = 0 // radians
		private var oldRotation:Number = 0
		public var angularVelocity:Number = 0
		public var torque:Number = 0
		public var inertia:Number = 2

		public var velocity:CTVector = new CTVector(0,0)

		public function setUserData(ud:*) {
			ctUserData = ud
		}
		public function setShape(s:CTBoxShape) {
			ctShape = s
		}
		public function setPosition(_x:Number, _y:Number) {
			x = _x
			y = _y
		}
		public function setMass(m:Number) {
			mass = m
			if(mass != 0) {
				invMass = 1/mass
			} else {
				invMass = 0
			}
		}
		public function getMass():Number {
			return mass
		}
		public function getShape():CTShape {
			return ctShape
		}
		public function getPositionVector():CTVector {
			return new CTVector(x, y)
		}
		public function step() {
			//if(mass == 0) return
			ctShape.updatePosition();

			velocity.y += mass * CTWorld.CTGravity * CTWorld.CTTimeStep
			angularVelocity += torque * (1/inertia) * CTWorld.CTTimeStep

			rotation += angularVelocity * CTWorld.CTTimeStep
			//if(rotation != oldRotation) {
				ctShape.rotateVertices(rotation)
				/*oldRotation = rotation
			}*/

			x += velocity.x * CTWorld.CTTimeStep
			y += velocity.y * CTWorld.CTTimeStep
		}
	}
}