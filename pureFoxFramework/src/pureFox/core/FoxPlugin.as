package pureFox.core
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import pureFox.core.interfaces.IPlugin;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.IProxy;
	
	/**
	 * 插件的基类
	 * 
	 * 只需要重写 o_registerPureMvcAndStart 方法
	 * 然后 调用 相应的方法 主城MVC
	 */
	public class FoxPlugin extends Sprite implements IPlugin
	{
		protected var facade:IFacade;
		
		public function FoxPlugin()
		{
			super();
		}
		
		private var _commandNames:Vector.<String>;
		private var _mediatorNames:Vector.<String>;
		private var _proxyNames:Vector.<String>;
		private var _data:Object;
		public function start(fa:IFacade,data:Object=null):void
		{
			_commandNames = new Vector.<String>;
			_mediatorNames = new Vector.<String>;
			_proxyNames = new Vector.<String>;
			
			_data = data;
			
			facade = fa;
			trace("<plugin> "+this,"start !");
			fox_override_registerPureMvcAndStart();
		}
		
		public function dispose():void
		{
			_autoRemovePureMVC();
			facade = null;
		}
		
		/**
		 * 自动移除pureMVC注册的mvc内容
		 */
		private function _autoRemovePureMVC():void
		{
			if(_commandNames)
			{
				var i:int = _commandNames.length;
				var key:String="";
				
				//自动移除command
				while(i--)
				{
					key = _commandNames[i];
					facade.removeCommand(key); 
					trace("[core] remove  command ",key);
				}
				
				//自动移除mediator
				i = _mediatorNames.length;
				while(i--)
				{
					key = _mediatorNames[i];
					facade.removeMediator(key);
					trace("[core] remove  mediator ",key);
				}
				
				//自动移除proxy
				i = _proxyNames.length;
				while(i--)
				{
					key = _proxyNames[i];
					facade.removeProxy(key);
					trace("[core] remove  proxy ",key);
				}
			}
			
			_commandNames = null;
			_mediatorNames = null;
			_proxyNames = null;
		}
		
		
		/**
		 * 注册command，当插件移除时，会自动清除注册的command
		 */
		protected function fox_registerCommand(noteName:String,commandClassRef:Class):void
		{
			facade.registerCommand(noteName,commandClassRef);
			_commandNames.push(noteName);
		}
		
		/**
		 * 注册mediator，当插件移除时，会自动清除注册的mediator
		 */
		protected function fox_registerMediator(mediator:IMediator):void
		{
			facade.registerMediator(mediator);
			_mediatorNames.push(mediator.getMediatorName());
		}
		
		/**
		 * 注册proxy，当插件移除时，会自动清除注册的proxy
		 */
		protected function fox_registerProxy(proxy:IProxy):void
		{
			facade.registerProxy(proxy);
			_proxyNames.push(proxy.getProxyName());
		}
		
		/**
		 * 在这里 注册puremvc相关的command,proxy,mediator
		 * 使用一下方法注册的 插件移除后会自动删除注册的command,proxy,mediator
		 * fox_registerCommand
		 * fox_registerMediator
		 * fox_registerProxy
		 */
		protected function fox_override_registerPureMvcAndStart():void
		{
			throw new Error("注册puremvc相关的command,proxy,mediator");
		}
		
		/**
		 * 加载插件 传递的数据
		 */
		public function get initData():Object
		{
			return _data;
		}

	}
}