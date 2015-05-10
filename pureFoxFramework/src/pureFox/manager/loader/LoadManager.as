package pureFox.manager.loader
{
	import flash.display.Loader;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	
	import deng.fzip.FZip;
	
	import morn.core.managers.ResLoader;
	
	import org.puremvc.as3.interfaces.IFacade;
	
	import pureFox.core.interfaces.IPlugin;
	import pureFox.manager.interfaces.IManager;
	
	/**
	 * 负责加载
	 * 
	 * Fzip文件
	 * 插件
	 * mornui 资源库
	 */
	public class LoadManager extends EventDispatcher implements IManager
	{
		public function LoadManager()
		{
		}

		public function setup(s:Stage,fa:IFacade):void
		{
			_facade = fa;
		}
		
		private var _temps:Array = [];
		private var _total:int;
		private var _loadCount:int;
		
		/**
		 * 插件文件
		 * url:文件的路径
		 * data:传递的数据
		 * isBig:是否大的加载提示界面
		 */
		public function addPlugin(url:String,msg:String,data:Object=null,isBig:Boolean=false):void
		{
			var item:Item = new Item();
			item.type = Item.TYPE_PLUGIN;
			item.url=url;
			item.isBig=isBig;
			item.data = data;
			item.msg = msg;
			
			_temps.push(item);
			_total++;
		}
		
		/**
		 * mornui的资源文件
		 * url:文件的路径
		 * data:传递的数据
		 * isBig:是否大的加载提示界面
		 */
		public function addMornui(url:String,msg:String,isBig:Boolean=false):void
		{
			var item:Item = new Item();
			item.type = Item.TYPE_MORNUI;
			item.url=url;
			item.isBig=isBig;
			item.msg = msg;
			
			_temps.push(item);
			_total++;
		}
		
		/**
		 * FZip文件
		 * url:文件的路径
		 * data:传递的数据
		 * isBig:是否大的加载提示界面
		 */
		public function addFzip(url:String,msg:String,isBig:Boolean=false):void
		{
			var item:Item = new Item();
			item.type = Item.TYPE_FZIP;
			item.url=url;
			item.isBig=isBig;
			item.msg = msg;
			
			_temps.push(item);
			_total++;
		}
		
		/**
		 * 开始加载
		 */
		public function startLoad():void
		{
			_loadNext();
		}
		
		private var _facade:IFacade;
		private var _loader:Loader = new Loader();
		private var _urlLoader:URLLoader;
		private var _currentItem:Item;
		private var _isLoading:Boolean;
		private var _context:LoaderContext = new LoaderContext(false,ApplicationDomain.currentDomain);
		private function _loadNext():void
		{
			if(_isLoading)
			{
				return;
			}
			
			if(_temps.length)
			{
				_isLoading = true;
				_currentItem = _temps.shift();
				_loadCount++;
				
				trace("load-> "+_currentItem.url);
				
				if(!_currentItem||!_currentItem.url||_currentItem.url.length<1)
				{
					_loadNext();
					return;
				}
				
				_showLoadTip(0);
				
				if(_currentItem.type == Item.TYPE_PLUGIN)//加载插件
				{
					_loadPlugin();
				}else if(_currentItem.type == Item.TYPE_FZIP)//加载fzip  暂时嵌入在插件里面
				{
					
				}else if(_currentItem.type == Item.TYPE_MORNUI)//加载mornui
				{
					_loadMornui();
				}
				else
				{
					_isLoading = false;
					_loadNext();
				}
				
			}else
			{
				//所有 加载完毕
				
				_isLoading = false;
				_total = 0;
				_loadCount = 0;
				
				var evt:LoadEvent = new LoadEvent(LoadEvent.LOAD_ALL_COMPLETE);
				this.dispatchEvent(evt);
			}
		}
		
		//------------------------------------------------------------------------------------------------------
		private var _plugins:Dictionary = new Dictionary();
		private function _loadPlugin():void
		{
			var p:IPlugin = _getPlugin(_currentItem.url); 
			if(p)//如果有现成的就不加在了
			{
//				trace("load cache -> "+_currentItem.url);
				p.start(_facade,_currentItem.data);
				_isLoading = false;
				_loadNext();
			}else//如果没有缓存 就加载新的
			{
//				trace("load new -> "+_currentItem.url);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,_onLoaded);
				_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,_onProgress);
				
				_loader.load(new URLRequest(_currentItem.url),_context); 
			}
		}
		
		private function _getPlugin(url:String):IPlugin
		{
			var p:IPlugin = _plugins[url];
			return p;
		}
		
		/**
		 * 根据url删除插件
		 * url插件的url
		 * gc是否清除
		 */
		public function killPlugin(url:String,gc:Boolean=false):void
		{
			var p:IPlugin = _getPlugin(url);
			if(p)
			{
				p.dispose();
				
				if(gc)
				{
					delete _plugins[url];
					_plugins[url] = null;
				}
			}
		}
		
		private function _onLoaded(event:Event):void
		{
			var p:IPlugin = _loader.content as IPlugin; 
			if(p)//加载完毕后，保存起来
			{
				_plugins[_currentItem.url] = p;
				p.start(_facade,_currentItem.data);
			}
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,_onLoaded);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,_onProgress);	
			
			_isLoading = false;
			
			var evt:LoadEvent = new LoadEvent(LoadEvent.LOAD_COMPLETE);
			evt.msg = _currentItem.msg;
			this.dispatchEvent(evt);
			
			_loadNext();
		}
		
		//------------------------------------------------------------------------------------------------------
		private function _loadMornui():void
		{
			var res:* = ResLoader.getResLoaded(_currentItem.url);
			if(res)
			{
				_isLoading = false;
				_loadNext();
				return;
			}else
			{
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,_onResLoaded);
				_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,_onProgress);
				
				_loader.load(new URLRequest(_currentItem.url),_context);
			}
				
		}
		
		protected function _onResLoaded(event:Event):void
		{
			var content:* = _loader.content;
			if(content)
			{
				ResLoader.setResLoaded(_currentItem.url,content);
			}
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,_onResLoaded);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,_onProgress);	
			
			_isLoading = false;
			
			var evt:LoadEvent = new LoadEvent(LoadEvent.LOAD_COMPLETE);
			evt.msg = _currentItem.msg;
			this.dispatchEvent(evt);
			
			_loadNext();
		}
		//------------------------------------------------------------------------------------------------------
		private var _zip:FZip
		private function _loadFzip():void
		{
			if(_zip == null)
			{
				_zip = new FZip();
			}
		}
		
		private function _onProgress(event:ProgressEvent):void
		{
			var per:Number = event.bytesLoaded/event.bytesTotal;
			_showLoadTip(per);
		}
		
		private function _showLoadTip(per:Number):void
		{
			var evt:LoadEvent = new LoadEvent(LoadEvent.LOAD_PROGRESS);
			evt.msg = "["+ _loadCount+"/"+_total+"]"+" "+(Number(per.toFixed(3))*100)+"% "+ _currentItem.msg;
			evt.isBig = _currentItem.isBig;
			this.dispatchEvent(evt);
		}
		
	}
}

class Item
{
	public var url:String="";
	public var type:String="";
	public var isBig:Boolean=false;//是否使用大的loading条加载，只有在client中几个主界面素材的时候才会赋值为true
	public var data:Object=new Object();
	public var msg:String="";//加载提示语言
	
	public static const TYPE_PLUGIN:String = "type_plugin";
	public static const TYPE_FZIP:String = "type_fzip";
	public static const TYPE_MORNUI:String = "type_mornui";
}