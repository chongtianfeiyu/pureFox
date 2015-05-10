package pureFox.core.interfaces
{
	import org.puremvc.as3.interfaces.IFacade;

	public interface IPlugin
	{
		function start(fa:IFacade,data:Object=null):void;
		function dispose():void;
	}
}