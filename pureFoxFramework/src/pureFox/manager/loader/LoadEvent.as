package pureFox.manager.loader
{
	import flash.events.Event;
	
	public class LoadEvent extends Event
	{
		public static const LOAD_PROGRESS:String = "load_progress";
		public static const LOAD_COMPLETE:String = "load_complete";
		public static const LOAD_ALL_COMPLETE:String = "load_all_complete";
		
		public var msg:String="";
		public var isBig:Boolean;
		public function LoadEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}