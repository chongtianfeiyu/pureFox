# pureFox
基于pureMVC，mornui的插件化页游框架
 预备知识点 
  pureMVC  参考最佳实践
  mornui   参看 http://www.mornui.com/
  
  pureFox只是一个框架，基于框架之上，可以构建各种游戏引擎，如 SLG，ARPG 等。
  有问题请咨询 as_fox#qq.com

1 如何使用pureFox框架

	 * 继承FoxClinet来启动puremvc框架
	 * 继承FoxPlugin来制作插件，在插件里注册各种puremvc功能
	 * 继承FoxMgr来 使用和扩展 管理器
	 * 
	 * 游戏开启流程
	 * 初始化mornui->初始化pureMVC框架->初始化基础manager->初始化扩展manager->游戏启动完毕->加载插件

2 具体实践
  2.1 项目设计
      1 将pureFox作为库项目 如：pureFoxFramework
      2 创建游戏项目，将pureFoxFramework添加到游戏项目
      3 游戏项目目录结构
          assets
            img 图片资源
            sound 声音资源
            configs 配置文件
          global
            保存用于发生通知的KEY
          manangers
            common 通用管理器。如 网络管理，声音管理，缓存管理，GC管理，日志管理，等游戏通用的管理器
            extensive 扩展管理器。如 特效管理，战斗管理，图层管理，数据管理，等不同游戏不通用的管理器
          plugins
            myplugin1 具体的某一个插件
              view 保存界面管理器 mediator
              modle 保存 vo 和 proxy
              contoller 保存 command
              MyPlugin1.as 需要继承FoxPlugin
            myplugin2
              ...
            myplugin3
              ...
            ...
          ui
            保存mornui导出的界面AS
          Client.as 客户端入口，必须继承FoxClient
  2.2 编码流程
      1 创建GM类
          public class GM extends FoxMgr
        	{
        		public function GM()
        		{
        			super();
        		}
        		//使用单例，方便使用
        		private static var _instance:GM;
        		public static function get instance():GM
        		{
        			if(_instance == null)
        			{
        				_instance = new GM();	
        			}
        			
        			return _instance;
        		}
        		
        		//在这里 setup 管理器
        		override protected function fox_extends_managers_setup():void
        		{
        			fox_setupManager(DataManager);
        			fox_setupManager(SoundManager);
        			fox_setupManager(SocketManager);
        		}
        		//封装各个管理器的 get，方便使用。 
        		public function get socket():SocketManager
        		{
        			return fox_getManager(SocketManager) as SocketManager;
        		}
        		
        		public function get sound():SoundManager
        		{
        			return fox_getManager(SoundManager) as SoundManager;
        		}
        		
        		public function get data():DataManager
        		{
        			return fox_getManager(DataManager) as DataManager;
        		}
        	}
      2 继承FoxClient,创建Client.as
          public class Client extends FoxClient
        	{
        		public function Client()
        		{
        			//默认 FoxClient 会启动，mornui，pureMVC 和 pureFox
        		}
        		
        		override protected function fox_override_setupManagers():void
        		{
        			GM.instance.setup(this.stage,this.facade);// 启动管理器
        			
        			// loadManager是框架已有的 管理器
        			GM.instance.mgr_load.addEventListener(LoadEvent.LOAD_ALL_COMPLETE,checkLoading);
        			GM.instance.mgr_load.addEventListener(LoadEvent.LOAD_COMPLETE,checkLoading);
        			GM.instance.mgr_load.addEventListener(LoadEvent.LOAD_PROGRESS,checkLoading);
        		}
        		
        		//处理加载提示
        		protected function checkLoading(e:LoadEvent):void
        		{
        			switch(e.type)
        			{
        				case LoadEvent.LOAD_ALL_COMPLETE:
        					break;
        				
        				case LoadEvent.LOAD_COMPLETE:
        					break;
        				
        				case LoadEvent.LOAD_PROGRESS:
        					break;
        			}
        			
        		}
        		
        		override protected function fox_override_Start():void
        		{
        		//一般 先加载配置文件，再根据配置文件 加载 插件，mornui库，或者fzip数据
        	  	GM.instance.mgr_load.addFzip("Fzip格式数据","提示信息");
        	  	GM.instance.mgr_load.addMornui("mornui导出的UI库","提示信息");
        			GM.instance.mgr_load.addPlugin("插件的路径","提示信息");
        			GM.instance.mgr_load.startLoad();
        		}
        	}
        	
        3 MyPlugin 继承 FoxPlugin
            public class MyPlugin extends FoxPlugin
          	{
          		public function MyPlugin()
          		{
          			  super();
          		}
          		
          		override protected function fox_override_registerPureMvcAndStart():void
          		{
          			trace(this.initData);//如果有 传递参数过来，会保存在 initData里
          			
          			可以使用一下三个方法注册pureMVC的内容，插件移除后，注册的pureMVC内容会自动移除掉。
          			this.fox_registerCommand 使用该方法注册 通知
          			this.fox_registerMediator 使用该方法 注册 界面管理器
          			this.fox_registerProxy 使用该方法 注册 代理
          			
          			也可以使用facade的方法，但是插件移除后，注册的pureMVC内容不会被自动移除掉。
          			this.facade.registerCommand
          			this.facade.registerMediator
          			this.facade.registerProxy
          		}
          	}
        4 然后就OK了。不断的制作游戏需要的各个插件。
