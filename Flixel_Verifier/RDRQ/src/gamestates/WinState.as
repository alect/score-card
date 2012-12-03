package gamestates
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSound;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	import utils.*;
	
	public class WinState extends FlxState
	{
		public override function create():void
		{
			var bg:FlxSprite = new FlxSprite(0, 0, ResourceManager.winArt);
			bg.scale = new FlxPoint(0.5, 0.5);
			bg.origin = new FlxPoint();
			this.add(bg);
			
			var title:FlxText = new FlxText(0, 0, FlxG.width, "RIOTOUS!");
			title.setFormat("Matchbox", 64, 0xffffffff, "center");
			this.add(title);
			
			// The back button 
			var backButton:FlxButton = new FlxButton(5, FlxG.height-30, null, goBack);
			backButton.loadGraphic(ResourceManager.backButtonArt, true, false, 96, 32);
			backButton.x = 5;
			backButton.y = FlxG.height - backButton.height - 5;
			this.add(backButton);
			
			var winSound:FlxSound = new FlxSound();
			winSound.loadEmbedded(ResourceManager.winRiff);
			winSound.play();
			
		}
		
		public function goBack():void
		{
			ResourceManager.playClick();
			FlxG.switchState(new CreditsState);
		}
	}
}