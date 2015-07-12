package CTPhysics {
	import CTPhysics.Math.CTVector

	public class CTWorld {

		private var collisionPairs:Array = new Array();
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
			collisionPairs = []

			for(var a:int = 0; a < bodyArray.length; a++) {
				for(var b:int = 0; b < bodyArray.length; b++) {
					if(bodyArray[a] == bodyArray[b]) continue
					for(var c:int = 0; c < collisionPairs.length; c++) {
						if(bodyArray[a] == collisionPairs[c][0] && bodyArray[b] == collisionPairs[c][1]
						   || bodyArray[a] == collisionPairs[c][1] && bodyArray[b] == collisionPairs[c][0]) {
							continue
						}
					}

					collisionPairs.push(new Array(bodyArray[a], bodyArray[b]))

					if(checkCollision(bodyArray[a], bodyArray[b])) {
						//collisionResponse(bodyArray[a], bodyArray[b])
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
		public var bodyA_normals:Array
		public var bodyB_normals:Array
		public var resultP1:Object
		public var resultP2:Object
		public var resultQ1:Object
		public var resultQ2:Object
		public function checkCollision(bodyA, bodyB) {
			//SAT check
			bodyA_normals = bodyA.ctShape.getNormals();
			bodyB_normals = bodyB.ctShape.getNormals();

			var bodyA_vertices:Array = bodyA.ctShape.getVertices();
			var bodyB_vertices:Array = bodyB.ctShape.getVertices();

			//Variables for finding the lowest overlap and the normal that it belongs to
			//Info is used for collision resolution
			var lowestOverlap:Number = 0
			var overlapNormal:CTVector
			var lowestMaxProj:Number
			var highestMinProj:Number

			//Project along all the edges and see if there's a gap between min and max
			resultP1 = getMinMaxProjection(bodyA_vertices, bodyA_normals[0])
			resultP2 = getMinMaxProjection(bodyB_vertices, bodyA_normals[0])
			var separate_P:Boolean = resultP1.max_proj < resultP2.minProj || resultP2.maxProj < resultP1.minProj
			if(separate_P) return false

			resultQ1 = getMinMaxProjection(bodyA_vertices, bodyA_normals[1])
			resultQ2 = getMinMaxProjection(bodyB_vertices, bodyA_normals[1])
			var separate_Q:Boolean = resultQ1.maxProj < resultQ2.minProj || resultQ2.maxProj < resultQ1.minProj
			if(separate_Q) return false

			var resultR1:Object = getMinMaxProjection(bodyA_vertices, bodyB_normals[0])
			var resultR2:Object = getMinMaxProjection(bodyB_vertices, bodyB_normals[0])
			var separate_R:Boolean = resultR1.maxProj < resultR2.minProj || resultR2.maxProj < resultR1.minProj
			if(separate_R) return false

			var resultS1:Object = getMinMaxProjection(bodyA_vertices, bodyB_normals[1])
			var resultS2:Object = getMinMaxProjection(bodyB_vertices, bodyB_normals[1])
			var separate_S:Boolean = resultS1.maxProj < resultS2.minProj || resultS2.maxProj < resultS1.minProj
			if(separate_S) return false

			//Find out how much overlap is at the 4 edges and store normal for the lowest overlap
			var result:Array = new Array()
			result.push(new Array(resultP1, resultP2, bodyA_normals[0]))
			result.push(new Array(resultQ1, resultQ2, bodyA_normals[1]))
			result.push(new Array(resultR1, resultR2, bodyB_normals[0]))
			result.push(new Array(resultS1, resultS2, bodyB_normals[1]))

			for(var i:int = 0; i < result.length; i++) {
				//Find det laveste overlap og gem det
				var currentOverlap = Math.abs(intervalDistance(result[i][0].minProj, result[i][0].maxProj, result[i][1].minProj, result[i][1].maxProj))
				if(currentOverlap < lowestOverlap || !lowestOverlap) {
					lowestOverlap = currentOverlap
					overlapNormal = result[i][2]

					var d:CTVector = bodyA.getPositionVector().subtract(bodyB.getPositionVector())
					if(d.dot(overlapNormal) < 0) {
						overlapNormal = new CTVector(-overlapNormal.x, -overlapNormal.y)
					}
				}
			}
			collisionResponse(bodyA, bodyB, overlapNormal, lowestOverlap)
			collisionNormal = overlapNormal
			overlapLength = lowestOverlap

			return true
		}
		public function intervalDistance(minA, maxA, minB, maxB) {
			if(minA < minB) {
				return minB - maxA
			} else {
				return minA - maxB
			}
		}

		public function getMinMaxProjection(vertices, axis) {
			//Finding the min and max projections for shape A and B
			var minProj:Number = vertices[0].dot(axis)
			var maxProj:Number = vertices[0].dot(axis)
			var curProj:Number = 0
			for(var i:int = 1; i < vertices.length; i++) {
				curProj = vertices[i].dot(axis)
				if(minProj > curProj) {
					minProj = curProj
				}
				if(curProj > maxProj) {
					maxProj = curProj
				}
			}
			return { minProj:minProj, maxProj:maxProj}
		}
		public var collisionNormal
		public var overlapLength
		public function collisionResponse(bodyA, bodyB, normal, penetration) {
			normal.normalize();
			//Calculate impulse
			var j = -(1 + Math.min(bodyA.restitution, bodyB.restitution)) * 3
			j /= bodyA.invMass + bodyB.invMass

			Main.writeText(j)

			var impulse:CTVector = new CTVector(j*normal.x * penetration, j*normal.y * penetration)

			bodyA.velocity.subtract(new CTVector(impulse.x * bodyA.invMass, impulse.y * bodyA.invMass))
			bodyB.velocity.sum(new CTVector(impulse.x * bodyB.invMass, impulse.y * bodyB.invMass))

			correctPosition(bodyA, bodyB, normal, penetration)
		}
		public function correctPosition(bodyA, bodyB, normal, penetration) {
			var depth:Number = Math.max(penetration - 0.01, 0) / (bodyA.invMass + bodyB.invMass) * 0.4
			var correction:CTVector = new CTVector(normal.x * depth, normal.y * depth)
			bodyA.x += bodyA.invMass * correction.x
			bodyA.y += bodyA.invMass * correction.y

			bodyB.x -= bodyB.invMass * correction.x
			bodyB.y -= bodyB.invMass * correction.y
		}
	}
}
