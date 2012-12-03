package
{
	import org.flixel.FlxGame;
	import gamestates.MainMenuState;
	import utils.*;
	[SWF(width="960", height="640", backgroundColor="#808080")]
	[Frame(factoryClass="Preloader")]	
	
	public class RDRQ extends FlxGame
	{
		public function RDRQ()
		{		
			Globals.createOrRetrieveSave();
			super(480, 320, MainMenuState, 2);
			
		}
	}
}