package gamestates
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	import utils.*;
	
	public class MainMenuState extends FlxState
	{
		public override function create():void
		{
			FlxScoreVerifier.init(false);
			
			FlxG.mouse.show();
			
			var bg:FlxSprite = new FlxSprite();
			bg.loadGraphic(ResourceManager.titleArt);
			
			
			this.add(bg);
			
			var text:FlxText = new FlxText(0, 0, FlxG.width, "ROLLER DERBY RIOT QUEENS!");
			text.setFormat("Matchbox", 64, 0xffffffff, "center");
			text.alignment = "center";
			this.add(text);
			
			var play:FlxButton = new FlxButton(FlxG.width/2, text.y+text.height+10, null, play);
			play.loadGraphic(ResourceManager.playButtonArt, true, false, 96, 32);
			play.x = FlxG.width/2 - play.width - 10;
			play.y = FlxG.height - play.height - 20;
			this.add(play)
			var creditsButton:FlxButton = new FlxButton(FlxG.width/2, text.y+text.height+10, null, credits);
			creditsButton.loadGraphic(ResourceManager.creditsButtonArt, true, false, 96, 32);
			creditsButton.x = FlxG.width/2 + 10;
			creditsButton.y = FlxG.height - creditsButton.height - 20;
			this.add(creditsButton);
			
			//if (!FlxKongregate.hasLoaded)
		//		FlxKongregate.init(apiHasLoaded);	
			
		}
		
		private function apiHasLoaded():void
		{
			FlxKongregate.connect();
		}
		
		public override function draw():void
		{
			super.draw();
		}
		
		public function play():void
		{
			ResourceManager.playClick();
			FlxG.switchState(new LevelSelectState);
		}
		
		public function credits():void
		{
			ResourceManager.playClick();
			FlxG.switchState(new CreditsState);
		}
		
		
	}
}