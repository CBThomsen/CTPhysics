package 
{
	import com.wordpress.kahshiu.utils.Vector2d;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Shiu
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
		}
		
	}
	
}