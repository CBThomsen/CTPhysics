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

					var skip:Boolean = false
					for(var c:int = 0; c < collisionPairs.length; c++) {
						if(bodyArray[a] == collisionPairs[c][0] && bodyArray[b] == collisionPairs[c][1]
						   || bodyArray[a] == collisionPairs[c][1] && bodyArray[b] == collisionPairs[c][0]) {
						   	skip = true
						}
					}
					if(skip) continue

					collisionPairs.push(new Array(bodyArray[a], bodyArray[b]))

					if(checkCollision(bodyArray[a], bodyArray[b])) {
						bodyArray[a].ctUserData.gotoAndStop(2)
						bodyArray[b].ctUserData.gotoAndStop(2)
					} else {
						bodyArray[a].ctUserData.gotoAndStop(1)
						bodyArray[b].ctUserData.gotoAndStop(1)
					}
				}
			}
		}
		public var bodyA_normals:Array
		public var bodyB_normals:Array
		public var bodyA_vertices:Array
		public var bodyB_vertices:Array
		public var resultP1:Object
		public var resultP2:Object
		public var resultQ1:Object
		public var resultQ2:Object
		public var contactPoints:Array = new Array();
		public var overlapNormal:CTVector
		public function checkCollision(bodyA, bodyB) {
			//SAT check
			bodyA_normals = bodyA.ctShape.getNormals();
			bodyB_normals = bodyB.ctShape.getNormals();

			bodyA_vertices = bodyA.ctShape.getVertices();
			bodyB_vertices = bodyB.ctShape.getVertices();

			//Variables for finding the lowest overlap and the normal that it belongs to
			//Info is used for collision resolution
			var lowestOverlap:Number = 0

			//Project along all the edges and see if there's a gap between min and max
			var result1:Object
			var result2:Object
			var seperate:Boolean
			var result:Array = new Array();

			//Do it for A
			for(var pa:int = 0; pa < bodyA_normals.length; pa++) {
				result1 = getMinMaxProjection(bodyA_vertices, bodyA_normals[pa])
				result2 = getMinMaxProjection(bodyB_vertices, bodyA_normals[pa])
				seperate = result1.max_proj < result2.minProj || result2.maxProj < result1.minProj
				if(seperate) {
					return false
				}
				result.push(new Array(result1, result2, bodyA_normals[pb]))
			}
			//Do it for B
			for(var pb:int = 0; pb < bodyB_normals.length; pb++) {
				result1 = getMinMaxProjection(bodyA_vertices, bodyB_normals[pb])
				result2 = getMinMaxProjection(bodyB_vertices, bodyB_normals[pb])
				seperate = result1.max_proj < result2.minProj || result2.maxProj < result1.minProj
				if(seperate) {
					return false
				}
				result.push(new Array(result1, result2, bodyB_normals[pb]))
			}

			//Find out how much overlap is at the 4 edges and store normal for the lowest overlap

			for(var i:int = 0; i < result.length; i++) {
				//Find det laveste overlap og gem det og normallen
				var currentOverlap = Math.abs(intervalDistance(result[i][0].minProj, result[i][0].maxProj, result[i][1].minProj, result[i][1].maxProj))
				if(currentOverlap < lowestOverlap || !lowestOverlap) {
					//Finding normal and seperation vector
					lowestOverlap = currentOverlap
					overlapNormal = result[i][2]

					var d:CTVector = bodyA.getPositionVector().subtract(bodyB.getPositionVector())
					if(d.dot(overlapNormal) < 0) {
						overlapNormal = new CTVector(-overlapNormal.x, -overlapNormal.y)
					}
				}
			}
			overlapNormal.normalize();
			contactPoints = new Array();
			contactPoints = getContactPoints(bodyA_vertices, bodyB_vertices, overlapNormal)

			for(var c:int = 0; c < contactPoints.length; c++) {
				collisionResponse(bodyA, bodyB, overlapNormal, lowestOverlap, contactPoints[c])
			}


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

			var minIndex:int = 0
			var maxIndex:int = 0

			for(var i:int = 1; i < vertices.length; i++) {
				curProj = vertices[i].dot(axis)
				if(minProj > curProj) {
					minProj = curProj
					minIndex = i
				}
				if(curProj > maxProj) {
					maxProj = curProj
					maxIndex = i
				}
			}
			return { minProj:minProj, maxProj:maxProj, minIndex: minIndex, maxIndex: maxIndex }
		}
		public var e1:CTEdge
		public var e2:CTEdge
		public function getContactPoints(aVertices, bVertices, n) {
			e1 = findCollisionEdge(aVertices, new CTVector(-n.x, -n.y))
			e2 = findCollisionEdge(bVertices, n)

			//Find reference and incident edge by checking which is the most perpendicular to the normal
			var referenceEdge:CTEdge
			var incidentEdge:CTEdge
			var flip:Boolean = false

			if(Math.abs(e1.vector.dot(n)) <= Math.abs(e2.vector.dot(n))) {
				referenceEdge = e1.clone();
				incidentEdge = e2.clone();
			} else {
				referenceEdge = e2.clone();
				incidentEdge = e1.clone();
				// we need to set a flag indicating that the reference
				// and incident edge were flipped so that when we do the final
				// clip operation, we use the right edge normal
				flip = true
			}

			//Normalize the edge vector
			var refV = referenceEdge.vector.clone().normalize();

			//Begin clipping
			var o1:Number = refV.dot(referenceEdge.startVertex)
			var clippedPoints:Array = clip(incidentEdge.startVertex, incidentEdge.endVertex, refV, o1)

			//If we dont have 2 points left then fail
			if(clippedPoints.length < 2) { 
				return new Array();
			}

			//Clip what is left of the incident edge by the second vertex of the reference edge
			//Need to clip in opposite direction so we flip the direction

			var o2:Number = refV.dot(referenceEdge.endVertex)
			clippedPoints = clip(clippedPoints[0].point, clippedPoints[1].point, new CTVector(-refV.x, -refV.y), -o2)

			if(clippedPoints.length < 2) { 
				return new Array();
			}

			//Get the reference edge normal
			var refNorm:CTVector = referenceEdge.vector.clone().crossProduct(-1)
			refNorm.normalize();
			//Check if we have to flip the normal
			if(flip) {
				refNorm = refNorm.times(-1)
			}
			//refNorm.normalize();

			//Get the largest depth
			var max = refNorm.dot(referenceEdge.max)
			for(var i:int = 0; i < clippedPoints.length; i++) {
				var depth:Number = refNorm.dot(clippedPoints[i].point) - max
				if(depth < 0) {
					clippedPoints.splice(i, 1)
					i -= 1
				} else {
					clippedPoints[i].depth = depth
				}
			}

			return clippedPoints
		}
		public function findCollisionEdge(vertices, n) {
			//First find the two edges involved
			var edgeVertexIndex:int = 0 
			var max:Number = 0

			for(var i:int = 0; i < vertices.length; i++) {
				var proj = n.dot(vertices[i])
				if(proj > max) {
					max = proj
					edgeVertexIndex = i
				}
			}

			var v:CTVector = vertices[edgeVertexIndex]
			var v1:CTVector
			var v0:CTVector

			if(edgeVertexIndex+1 > vertices.length-1) {
				v1 = vertices[0]
			} else {
				v1 = vertices[edgeVertexIndex+1]
			}
			if(edgeVertexIndex-1 < 0) {
				v0 = vertices[vertices.length-1]
			} else {
				v0 = vertices[edgeVertexIndex-1]
			}
			var v1ToV:CTVector = new CTVector(v1.x - v.x, v1.y - v.y)
			var v0ToV:CTVector = new CTVector(v0.x - v.x, v0.y - v.y)

			v1ToV.normalize();
			v0ToV.normalize();

			//The edge that is most perpendicular to seperation normal n will have a dot product closer to zero
			var edge:CTEdge
			if(v1ToV.dot(n) <= v0ToV.dot(n)) {
				//Right edge - v0 to v
				edge = new CTEdge(v, v0, v)
			} else {
				//Left edge - v1 to v
				edge = new CTEdge(v, v, v1)
			}
			return edge
		}
		public function clip(v1, v2, n, o) {
			var clippedPoints:Array = new Array();
			var d1 = n.dot(v1) - o
			var d2 = n.dot(v2) - o
			//If either point is past o along n we keep it
			if(d1 >= 0) clippedPoints.push({point: v1})
			if(d2 >= 0) clippedPoints.push({point: v2})

			//Check if they're on opposing sides so the correct point can be computed
			if(d1 * d2 < 0) {
				//If they are on a different side d1 and d2 will be (+) * (-)
				//And it will give a (-)
				//Get the vector for the edge we are clipping
				var e:CTVector = new CTVector(v2.x - v1.x, v2.y - v1.y)
				//Compute location along e
				var u:Number = d1 / (d1 - d2);
				e.times(u)
				e.sum(v1)
				//Add the point
				clippedPoints.push({point: e})
			}
			return clippedPoints
		}
		public function collisionResponse(bodyA, bodyB, normal, penetration, contactPoint) {
			//penetration = contactPoint.depth*0.01
			//Calculate moment of inertia
			var inertiaA:Number = (bodyA.invMass * Math.pow(bodyA.ctShape.width + bodyA.ctShape.height, 2)) / 6
			var inertiaB:Number = (bodyB.invMass * Math.pow(bodyB.ctShape.width + bodyB.ctShape.height, 2)) / 6

			//Get point vector from COM to contact point for body A
			var contactPointVectorA:CTVector = new CTVector(bodyA.x - contactPoint.point.x, bodyA.y - contactPoint.point.y)
			//Get point vector from COM to contact point for body B
			var contactPointVectorB:CTVector = new CTVector(bodyB.x - contactPoint.point.x, bodyB.y - contactPoint.point.y)


			//Find velocity for point by adding cross product of angular velocity and the contact point
			/*var velPointA:CTVector = bodyA.velocity.clone().sum(contactPointVectorA.clone().crossProduct(bodyA.angularVelocity))
			var velPointB:CTVector = bodyB.velocity.clone().sum(contactPointVectorB.clone().crossProduct(bodyB.angularVelocity))

			//Find out if the objects are moving apart by projecting to the normal
			var velPointProjectionA:Number = velPointA.dot(normal)
			var velPointProjectionB:Number = velPointB.dot(normal)
			if(velPointProjectionA <= 0 && velPointProjectionB <= 0) {
				trace("YE!")
				return
			}*/
			/*
			var j:Number = -velPointProjection / (bodyA.invMass + contactPointVector.vectorCrossProduct(normal) / inertiaA)
			var impulse:CTVector = new CTVector(j * normal.x * penetration, j * normal.y * penetration)

			bodyA.velocity.sum(new CTVector(impulse.x * bodyA.invMass, impulse.y * bodyA.invMass))
			bodyB.velocity.sum(new CTVector(impulse.x * bodyB.invMass, impulse.y * bodyB.invMass))*/

			//bodyA.angularVelocity = bodyA.angularVelocity + contactPointVector.clone().vectorCrossProduct(impulse)
			if(!contactPoint.point) {
				trace("We!")
				return
			}
			
			//Calculate impulse
			var j = -(1 + Math.min(bodyA.restitution, bodyB.restitution))
			j /= bodyA.invMass + bodyB.invMass

			var impulse:CTVector = new CTVector(j*normal.x, j*normal.y)
			impulse.times(penetration*10)

			bodyA.velocity.subtract(new CTVector(impulse.x * bodyA.invMass, impulse.y * bodyA.invMass))
			bodyB.velocity.sum(new CTVector(impulse.x * bodyB.invMass, impulse.y * bodyB.invMass))


			if(bodyA.invMass != 0) {
				bodyA.angularVelocity += contactPointVectorA.vectorCrossProduct(impulse) * 1 / inertiaA
			}
			if(bodyB.invMass != 0) {
				bodyB.angularVelocity -= contactPointVectorB.vectorCrossProduct(impulse) * 1 / inertiaB
			}

			correctPosition(bodyA, bodyB, normal, penetration)
		}
		public function correctPosition(bodyA, bodyB, normal, penetration) {
			var depth:Number = Math.max(penetration - 0.01, 0) / (bodyA.invMass + bodyB.invMass) * 0.4
			var correction:CTVector = new CTVector(normal.x * depth, normal.y * depth)
			bodyA.x -= bodyA.invMass * correction.x
			bodyA.y -= bodyA.invMass * correction.y

			bodyB.x -= bodyB.invMass * correction.x
			bodyB.y -= bodyB.invMass * correction.y
		}
	}
}