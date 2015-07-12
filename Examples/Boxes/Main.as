package {
	import flash.display.MovieClip
	import flash.events.Event
	import flash.events.MouseEvent

	import flash.text.TextField

	import CTPhysics.CTWorld
	import CTPhysics.CTBody
	import CTPhysics.CTBoxShape

	public class Main extends MovieClip {
		private var ctWorld:CTWorld = new CTWorld(10, 30);
		private var boxA:CTBody
		private var boxB:CTBody

		private static var debugField:TextField

		public function Main() {
			//Create debug field
			debugField = new TextField()
			debugField.x = 10
			debugField.y = 10
			debugField.width = 300
			debugField.height = 200
			addChild(debugField)

			var groundUserData:MovieClip = new Ground()
			groundUserData.width = 500
			groundUserData.height = 50

			//Creating a body
			boxA = new CTBody();
			var boxAShape:CTBoxShape = new CTBoxShape(boxA);

			boxAShape.setAsBox(500 / CTWorld.CTScale, 50 / CTWorld.CTScale)
			boxA.setMass(0)
			boxA.setShape(boxAShape);
			boxA.setUserData(groundUserData)
			ctWorld.createBody(boxA)
			addChild(boxA.ctUserData)

			//Creating a ground body
			boxB = new CTBody();
			var boxBShape:CTBoxShape = new CTBoxShape(boxB);
			groundUserData = new Ground()
			groundUserData.width = 50
			groundUserData.height = 50

			boxBShape.setAsBox(50 / CTWorld.CTScale, 50 / CTWorld.CTScale)
			boxB.setMass(0)
			boxB.angularVelocity = 0
			boxB.rotation = 0.7
			boxB.setShape(boxBShape);
			boxB.setUserData(groundUserData)
			ctWorld.createBody(boxB)
			addChild(boxB.ctUserData)

			boxA.setPosition(100 / CTWorld.CTScale, 400 / CTWorld.CTScale)
			boxB.setPosition(200 / CTWorld.CTScale, 200 / CTWorld.CTScale)

			//Starting loop
			addEventListener(Event.ENTER_FRAME, loop)

			//Make click listener to spawn objects
			stage.addEventListener(MouseEvent.CLICK, spawnObject)
		}
		public function spawnObject(e:MouseEvent) {
			var box:CTBody = new CTBody();
			var boxShape:CTBoxShape = new CTBoxShape(box);
			var boxUserData:TestBox = new TestBox();
			boxUserData.width = Math.random()*10 + 25
			boxUserData.height = Math.random()*10 + 25

			boxShape.setAsBox(boxUserData.width / CTWorld.CTScale, boxUserData.height / CTWorld.CTScale)
			box.setMass(Math.max(0.7, Math.random()*1))
			box.setShape(boxShape);
			box.setUserData(boxUserData)
			ctWorld.createBody(box)
			addChild(box.ctUserData)

			box.setPosition(mouseX / CTWorld.CTScale, mouseY / CTWorld.CTScale)
		}
		public function loop(e:Event) {
			//boxB.x = mouseX / CTWorld.CTScale
			//boxB.y = mouseY / CTWorld.CTScale
			ctWorld.step(1/60);

			this.graphics.clear();
			graphics.beginFill(0xff00ff)
			graphics.lineStyle(5, 0xff00ff)

			/*if(ctWorld.e1) {
				graphics.moveTo(ctWorld.e1.startVertex.x * CTWorld.CTScale, ctWorld.e1.startVertex.y * CTWorld.CTScale)
				graphics.lineTo(ctWorld.e1.startVertex.x * CTWorld.CTScale + 2, 
								ctWorld.e1.startVertex.y * CTWorld.CTScale + 2)
			}*/

			if(ctWorld.e1) {
				graphics.moveTo(ctWorld.e1.startVertex.x * CTWorld.CTScale, ctWorld.e1.startVertex.y * CTWorld.CTScale)
				graphics.lineTo(ctWorld.e1.startVertex.x * CTWorld.CTScale + ctWorld.e1.vector.x * CTWorld.CTScale, 
								ctWorld.e1.startVertex.y * CTWorld.CTScale + ctWorld.e1.vector.y * CTWorld.CTScale)
			}
			graphics.lineStyle(2, 0xff0000)
			if(ctWorld.e2) {
				graphics.moveTo(ctWorld.e2.startVertex.x * CTWorld.CTScale, ctWorld.e2.startVertex.y * CTWorld.CTScale)
				graphics.lineTo(ctWorld.e2.startVertex.x * CTWorld.CTScale + ctWorld.e2.vector.x * CTWorld.CTScale, 
								ctWorld.e2.startVertex.y * CTWorld.CTScale + ctWorld.e2.vector.y * CTWorld.CTScale)
			}
			if(ctWorld.contactPoints.length != 0) {
				for(var i:int = 0; i < ctWorld.contactPoints.length; i++) {
					var p = ctWorld.contactPoints[i].point
					graphics.moveTo(p.x * CTWorld.CTScale, p.y * CTWorld.CTScale)
					graphics.lineTo(p.x * CTWorld.CTScale+2, p.y * CTWorld.CTScale+2)
				}
			} else {
			}

			/*graphics.endFill();


			graphics.lineStyle(2, 0x000000)
			var bodies = ctWorld.getBodyArray();
			for(var i:int = 0; i < bodies.length; i++) {
				var vertices:Array = bodies[i].ctShape.getVertices();
				for(var j:int = 0; j < vertices.length; j++) {
					graphics.drawCircle(vertices[j].x*CTWorld.CTScale, vertices[j].y*CTWorld.CTScale, 2)
				}
			}
			graphics.lineStyle(2, 0xff00ff)
			var vertices2:Array = ctWorld.bodyB_vertices
			for(var j:int = 0; j < vertices2.length; j++) {
				graphics.drawCircle(vertices2[j].x*CTWorld.CTScale, vertices2[j].y*CTWorld.CTScale, 2)
			}
			

			if(ctWorld.overlapNormal) {
				graphics.lineStyle(2, 0xff00ff)
				graphics.moveTo(200, 200)
				graphics.lineTo(200 + ctWorld.overlapNormal.x * 100, 200 + ctWorld.overlapNormal.y *100)
			}
			if(ctWorld.bodyA_normals[0]) {
				graphics.lineStyle(2, 0xff00ff)
				graphics.moveTo(200, 200)
				graphics.lineTo(200 + ctWorld.bodyA_normals[0].x * 25, 200 + ctWorld.bodyA_normals[0].y *25)
				graphics.moveTo(200, 200)
				graphics.lineTo(200 + ctWorld.bodyA_normals[1].x * 25, 200 + ctWorld.bodyA_normals[1].y *25)

				graphics.moveTo(100, 400)
				graphics.lineTo(100 + ctWorld.bodyB_normals[0].x * 25, 400 + ctWorld.bodyB_normals[0].y *25)
				graphics.moveTo(100, 400)
				graphics.lineTo(100 + ctWorld.bodyB_normals[1].x * 25, 400 + ctWorld.bodyB_normals[1].y *25)
			}*/
		}
		public static function writeText(string:String) {
			debugField.text = string
		}
	}
}