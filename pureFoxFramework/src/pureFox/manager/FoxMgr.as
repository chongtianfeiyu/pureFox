package pureFox.manager
{
	import flash.display.Stage;
	import flash.utils.Dictionary;
	
	import org.puremvc.as3.interfaces.IFacade;
	
	import pureFox.manager.interfaces.IManager;
	import pureFox.manager.loader.LoadManager;

	public class FoxMgr
	{
		public function FoxMgr()
		{
		}
		
		/**
		 * set up 管理器
		 * s 舞台
		 * fa IFacade
		 * fps 帧频
		 */
		public function setup(s:Stage,fa:IFacade,fps:int=60):void
		{
			stage = s;
			facade = fa;
			s.frameRate = fps;
			
			fox_setupManager(LoadManager);
			
			fox_extends_managers_setup();
		}
		
		private var stage:Stage;
		private var facade:IFacade;
		
		private var managers:Dictionary = new Dictionary();
		public function fox_setupManager(managerClass:Class):void
		{
			var imgr:IManager = new managerClass() as IManager;
			if(imgr)
			{
				managers [managerClass+""] = imgr;
				imgr.setup(stage,facade);
				trace("set up manager "+managerClass);
			}
		}
		
		/**
		 * get manager by class 
		 */
		protected function fox_getManager(managerClass:Class):*
		{
			var mgr:*;
			mgr = managers [managerClass+""];
			return mgr;
		}
		
		public function get mgr_load():LoadManager
		{
			return fox_getManager(LoadManager) as LoadManager;
		}
		
		/**
		 * setup extensive managers
		 */
		protected function fox_extends_managers_setup():void
		{
			throw new Error("plz set up extensive managers ! use setupManager(managerClass:Class) in parent");
		}
		
	}
}