package pureFox.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	
	/**
	 * 继承FxClinet来启动puremvc框架
	 * 继承FxPlugin来制作插件，在插件里注册各种puremvc功能
	 * 继承Mgr来 使用和扩展 管理器
	 * 
	 * 游戏开启流程
	 * 初始化mornui->初始化pureMVC框架->初始化基础manager->初始化扩展manager->游戏启动完毕->加载插件
	 */
	public class FoxClient extends Sprite
	{
		/**
		 * pureMVC的facade的引用
		 */
		protected var facade:IFacade;
		/**
		 * 网页传递的数据
		 */
		protected var webData:Object;
		
		public function FoxClient()
		{
			super();
			
			if(stage==null)
			{
				this.addEventListener(Event.ADDED_TO_STAGE,start);
			}else
			{
				start();
			}
			
		}
		
		private function start(e:Event=null):void
		{
			webData = this.stage.loaderInfo.parameters;
			//setup mornui
			App.init(this);trace("setup mornui");
			
			//setup pureMVC
			facade = Facade.getInstance();	trace("setup pureMVC");

			//setup managers
			fox_override_setupManagers();trace("setup managers");
			
			//game start
			fox_override_Start();trace("game start");
		}
		
		protected function fox_override_setupManagers():void
		{
			throw new Error("need override ,set up managers!");
		}
		
		protected function fox_override_Start():void
		{
			throw new Error("need override ,game start!");
		}
		
	}
}