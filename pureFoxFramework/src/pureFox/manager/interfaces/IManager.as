package pureFox.manager.interfaces
{
	import flash.display.Stage;
	
	import org.puremvc.as3.interfaces.IFacade;

	public interface IManager
	{
		function setup(s:Stage,fa:IFacade):void;
	}
}