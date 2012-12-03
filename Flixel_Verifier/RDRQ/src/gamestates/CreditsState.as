package gamestates
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxButton;
	
	import utils.*;
	
	public class CreditsState extends FlxState
	{
		private var creditsText:String =
			"Alec Thomson - Concept, Design, and Programming\n" +
			"Alison Malouf - Art and Love \n" +
			"\n" +
			"Some sounds based on recordings from freesound.org:\n" +
			"\n" +
			"-\"Whip Crack 01\" by CGEffex\n" +
			"-\"record_scratch_short\" by Halleck\n" +
			"-\"click-1-d\" by TicTacShotUp\n" +
			"-\"scratch162\" by Junggle\n" +
			"-\"cat2\" by NoiseCollector\n" +
			"\n" +
			"Creative Commons Music hosted on SoundCloud.com:\n" +
			"\n" +
			"- \"Mood Indigo Beat\" by Uneeq (http://soundcloud.com/uneeqatlu/mood-indigo-beat)\n" +
			"- \"Fruity Rose\" by MBull (http://soundcloud.com/mbull-1/fruity-rose)";
		
		public override function create():void
		{
			var bg:FlxSprite = new FlxSprite(0, 0, ResourceManager.bgFullArt);
			this.add(bg);
			
			var tint:FlxSprite = new FlxSprite();
			tint.makeGraphic(FlxG.width, FlxG.height, Globals.BG_TINT);
			this.add(tint);
		
			var creditsTitle:FlxText = new FlxText(0, 0, FlxG.width, "CREDITS");
			creditsTitle.setFormat("Matchbox", 32, 0xffffffff, "center");
			this.add(creditsTitle);
			
			var credits:FlxText = new FlxText(Globals.CELL_SIZE, Globals.CELL_SIZE*2, FlxG.width-Globals.CELL_SIZE, creditsText);
			credits.setFormat("Graph35", 8, 0xffffffff);
			this.add(credits);
			
			// The back button 
			var backButton:FlxButton = new FlxButton(5, FlxG.height-30, null, goBack);
			backButton.loadGraphic(ResourceManager.backButtonArt, true, false, 96, 32);
			backButton.x = 5;
			backButton.y = FlxG.height - backButton.height - 5;
			this.add(backButton);
		}
		
		public function goBack():void
		{
			ResourceManager.playClick();
			FlxG.switchState(new MainMenuState());
		}
		
	}
}