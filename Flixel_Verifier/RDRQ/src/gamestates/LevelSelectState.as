package gamestates
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	
	import utils.*;
	
	public class LevelSelectState extends FlxState
	{
		public override function create():void
		{
			// First put in a background
			var bg:FlxSprite = new FlxSprite(0, 0, ResourceManager.bgFullArt);
			this.add(bg);
			
			// And a tint 
			var tint:FlxSprite = new FlxSprite();
			tint.makeGraphic(FlxG.width, FlxG.height, Globals.BG_TINT);
			this.add(tint);
			
			// And some text to tell us that it's the level select screen 
			var levelText:FlxText = new FlxText(0, 0, FlxG.width, "LEVEL SELECT");
			levelText.setFormat("Matchbox", 32, 0xffffffff, "center");
			this.add(levelText);
			
			
			var buttonX:Number = Globals.CELL_SIZE;
			var buttonY:Number = Globals.CELL_SIZE*2;
			
			for (var i:int = 0; i < ResourceManager.levelList.length; i++) {
				var levelButton:FlxButton;
				if (i > Globals.unlockLevelIndex) {
					levelButton = new FlxButton(0, 0, "x", function():void {ResourceManager.playClick();});
					levelButton.loadGraphic(ResourceManager.levelButtonArt, true, false, Globals.CELL_SIZE, Globals.CELL_SIZE);
					levelButton.color = 0xff808080;
				}
				else {
					levelButton = new FlxButton(0, 0, (i+1).toString(), levelButtonFunction(i));
					levelButton.loadGraphic(ResourceManager.levelButtonArt, true, false, Globals.CELL_SIZE, Globals.CELL_SIZE);
				}
				levelButton.x = buttonX;
				levelButton.y = buttonY;
				levelButton.labelOffset = new FlxPoint(-2, 8);
				buttonX+= 2*Globals.CELL_SIZE;
				if (buttonX >= FlxG.width-Globals.CELL_SIZE) {
					buttonY += 2*Globals.CELL_SIZE;
					buttonX = Globals.CELL_SIZE;
				}
				
				this.add(levelButton);
				
			}
			
			// The back button 
			var backButton:FlxButton = new FlxButton(5, FlxG.height-30, null, goBack);
			backButton.loadGraphic(ResourceManager.backButtonArt, true, false, 96, 32);
			backButton.x = 5;
			backButton.y = FlxG.height - backButton.height - 5;
			this.add(backButton);
			
		}
		
		public function levelButtonFunction(i:int):Function
		{
			function levelFunction():void
			{
				ResourceManager.playClick();
				var playState:PlayState = new PlayState();
				playState._currentLevelIndex = i;
				FlxG.switchState(playState);
			}
			return levelFunction;
		}
		
		public function goBack():void
		{
			ResourceManager.playClick();
			FlxG.switchState(new MainMenuState());
		}
	}
}