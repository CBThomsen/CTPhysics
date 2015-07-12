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

		private static var debugField:TextField

		public function Main() {
			//Create debug field
			debugField = new TextField()
			debugField.x = 10
			debugField.y = 10
			debugField.width = 300
			debugField.height = 200
			addChild(debugField)


			//Creating a body
			boxA = new CTBody();
			var boxAShape:CTBoxShape = new CTBoxShape(boxA);
			var groundUserData:MovieClip = new Ground()
			groundUserData.width = 500
			groundUserData.height = 50

			boxAShape.setAsBox(500 / CTWorld.CTScale, 50 / CTWorld.CTScale)
			boxA.setMass(0)
			boxA.setShape(boxAShape);
			boxA.setUserData(groundUserData)
			ctWorld.createBody(boxA)
			addChild(boxA.ctUserData)

			//Creating a ground body
			var boxB:CTBody = new CTBody();
			var boxBShape:CTBoxShape = new CTBoxShape(boxB);
			groundUserData = new Ground()
			groundUserData.width = 50
			groundUserData.height = 50

			boxBShape.setAsBox(50 / CTWorld.CTScale, 50 / CTWorld.CTScale)
			boxB.setMass(0)
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
			box.setMass(Math.max(0.7, Math.random()*2))
			box.setShape(boxShape);
			box.setUserData(boxUserData)
			ctWorld.createBody(box)
			addChild(box.ctUserData)

			box.setPosition(mouseX / CTWorld.CTScale, mouseY / CTWorld.CTScale)
		}
		public function loop(e:Event) {
			//boxA.x = mouseX / CTWorld.CTScale
			//boxA.y = mouseY / CTWorld.CTScale
			ctWorld.step(1/60);

			this.graphics.clear();
			graphics.beginFill(0xff00ff)
			/*var bodies = ctWorld.getBodyArray();
			for(var i:int = 0; i < bodies.length; i++) {
				var vertices:Array = bodies[i].ctShape.getVertices();
				for(var j:int = 0; j < vertices.length; j++) {
					graphics.drawCircle(vertices[j].x*CTWorld.CTScale, vertices[j].y*CTWorld.CTScale, 2)
				}
			}*/
			if(ctWorld.collisionNormal) {
				graphics.lineStyle(2, 0xff00ff)
				graphics.moveTo(200, 200)
				graphics.lineTo(200 + ctWorld.collisionNormal.x * 100, 200 + ctWorld.collisionNormal.y *100)
			}
		}
		public static function writeText(string:String) {
			debugField.text = string
		}
	}
}