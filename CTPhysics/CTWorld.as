package CTPhysics {
	import CTPhysics.Math.CTVector

	public class CTWorld {
		private var bodyArray:Array = new Array();

		public static var CTGravity:Number = 0
		public static var CTScale:int = 30
		public static var CTTimeStep:Number = 0

		public function CTWorld(g:Number, scale:int) {
			CTGravity = g
			CTScale = scale
		}
		public function createBody(b:CTBody) {
			bodyArray.push(b)
		}
		public function getBodyArray() {
			return bodyArray;
		}
		public function step(timeStep:Number) {
			CTTimeStep = timeStep

			for(var i:int = 0; i < bodyArray.length; i++) {
				bodyArray[i].step();
				if(bodyArray[i].ctUserData) {
					bodyArray[i].ctUserData.x = bodyArray[i].x * CTScale
					bodyArray[i].ctUserData.y = bodyArray[i].y * CTScale
					bodyArray[i].ctUserData.rotation = bodyArray[i].rotation * 180/Math.PI
				}
			}

			broadPhase();
		}
		public function broadPhase() {
			for(var a:int = 0; a < bodyArray.length; a++) {
				for(var b:int = 0; b < bodyArray.length; b++) {
					if(bodyArray[a] == bodyArray[b]) continue

					if(checkCollision(bodyArray[a], bodyArray[b])) {
						collisionResponse(bodyArray[a], bodyArray[b])
						if(bodyArray[a].mass != 0) {
							bodyArray[a].ctUserData.gotoAndStop(2)
						}
					} else {
						if(bodyArray[a].mass != 0) {
							bodyArray[a].ctUserData.gotoAndStop(1)
						}
					}
				}
			}
		}
		public function checkCollision(bodyA, bodyB) {
			//SAT check
			var axis:CTVector = new CTVector(1, -1).normalize();
			var bodyA_vertices:Array = bodyA.ctShape.getVertices();
			var bodyB_vertices:Array = bodyB.ctShape.getVertices();

			//Finding the min and max projections for shape A and B
			var minProjA:Number = bodyA_vertices[0].dot(axis)
			var maxProjA:Number = bodyA_vertices[0].dot(axis)
			var curProj:Number = 0
			for(var i:int = 1; i < bodyA_vertices.length; i++) {
				curProj = bodyA_vertices[i].dot(axis)
				if(minProjA > curProj) {
					minProjA = curProj
				}
				if(curProj > maxProjA) {
					maxProjA = curProj
				}
			}
			var minProjB:Number = bodyB_vertices[0].dot(axis)
			var maxProjB:Number = bodyB_vertices[0].dot(axis)
			for(var j:int = 1; j < bodyB_vertices.length; j++) {
				curProj = bodyB_vertices[j].dot(axis)
				if(minProjB > curProj) {
					minProjB = curProj
				}
				if(curProj > maxProjB) {
					maxProjB = curProj
				}
			}
			var isApart:Boolean = maxProjB < minProjA || maxProjA < minProjB
			if(isApart) {
				return false
			} else {
				return true
			}



			//Simple AABB check
			/*if(bodyA.x + bodyA.ctShape.halfWidth < bodyB.x - bodyB.ctShape.halfWidth || bodyA.x - bodyA.ctShape.halfWidth > bodyB.x + bodyB.ctShape.halfWidth) return false
			if(bodyA.y + bodyA.ctShape.halfHeight < bodyB.y - bodyB.ctShape.halfHeight || bodyA.y - bodyA.ctShape.halfHeight > bodyB.y + bodyB.ctShape.halfHeight) return false
			return true*/
		}
		public function collisionResponse(bodyA, bodyB) {
			//Calculate overlap / resolution vector
			var distanceVector:CTVector = new CTVector(bodyB.x - bodyA.x, bodyB.y - bodyA.y)
			var normal:CTVector = new CTVector(0,0)

			var xOverlap:Number = bodyA.ctShape.halfWidth + bodyB.ctShape.halfWidth - Math.abs(distanceVector.x)
			var yOverlap:Number = bodyA.ctShape.halfHeight + bodyB.ctShape.halfHeight - Math.abs(distanceVector.y)


			//Find normal and penetration
			var penetration:Number = 0

			if(xOverlap < yOverlap) {
				if(distanceVector.x < 0) {
					normal.x = -1
				} else {
					normal.x = 1
				}
				penetration = xOverlap
			} else {
				if(distanceVector.y < 0) {
					normal.y = -1
				} else {
					normal.y = 1
				}
				penetration = yOverlap
			}

			//Calculate impulse
			var deltaVelocity:CTVector = new CTVector(bodyB.velocity.x - bodyA.velocity.x, bodyB.velocity.y - bodyA.velocity.y)
			var velocityAlongNormal = deltaVelocity.dot(normal)
			if(velocityAlongNormal > 0) {
				return
			}

			var j = -(1 + Math.min(bodyA.restitution, bodyB.restitution)) * velocityAlongNormal;
			j /= bodyA.invMass + bodyB.invMass

			var impulse:CTVector = new CTVector(j*normal.x, j*normal.y)
			bodyA.velocity.subtract(new CTVector(impulse.x * bodyA.invMass, impulse.y * bodyA.invMass))
			bodyB.velocity.sum(new CTVector(impulse.x * bodyB.invMass, impulse.y * bodyB.invMass))

			correctPosition(bodyA, bodyB, normal, penetration)
		}
		public function correctPosition(bodyA, bodyB, normal, penetration) {
			var depth:Number = Math.max(penetration - 0.01, 0) / (bodyA.invMass + bodyB.invMass) * 0.5
			var correction:CTVector = new CTVector(normal.x * depth, normal.y * depth)
			bodyA.x -= bodyA.invMass * correction.x
			bodyA.y -= bodyA.invMass * correction.y

			bodyB.x += bodyB.invMass * correction.x
			bodyB.y += bodyB.invMass * correction.y
		}
	}
}