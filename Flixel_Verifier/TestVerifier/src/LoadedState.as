package
{
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	public class LoadedState extends FlxState
	{
		
		private var status:FlxText;
		private var won:Boolean;
		
		
		public override function create():void
		{
			FlxScoreVerifier.init();
			
			status = new FlxText(0, FlxG.height/2, FlxG.width, "Press x to win!");
			status.alignment = "center";
			add(status);
			won = false;
			
		}
		
		public override function update():void
		{
			if (!won && FlxG.keys.justPressed("X")) {
				status.text = "you won!";
				won = true;
				FlxScoreVerifier.postScore("won", 1);
			}
			super.update();
		}
		
	}
}