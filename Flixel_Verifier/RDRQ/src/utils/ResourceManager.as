package utils
{
	import org.flixel.FlxSound;

	public class ResourceManager
	{
		// Place embedded assets here 
		
		// Art Assets go here 
		[Embed(source="assets/art/floortiles.png")]
		public static var floorMap:Class;
		
		[Embed(source="assets/art/asphalt.png")]
		public static var bgArt:Class;
		
		[Embed(source="assets/art/sidewalk.png")]
		public static var sidewalkArt:Class;
		
		[Embed(source="assets/art/sidebarbg.png")]
		public static var sideBarTile:Class;
		
		[Embed(source="assets/art/sidebar.png")]
		public static var sideBarArt:Class;
		
		[Embed(source="assets/art/wall.png")]
		public static var wallArt:Class;
		
		[Embed(source="assets/art/smallwall.png")]
		public static var pushwallArt:Class;
		
		[Embed(source="assets/art/arrow.png")]
		public static var arrowArt:Class;
		
		[Embed(source="assets/art/jammeranim.png")]
		public static var jammerArt:Class;
		
		[Embed(source="assets/art/blockeranim.png")]
		public static var blockerArt:Class;
		
		[Embed(source="assets/art/keymaster.png")]
		public static var keymasterArt:Class;
		
		[Embed(source="assets/art/dropperanim.png")]
		public static var throwerArt:Class;
		
		[Embed(source="assets/art/cocktail.png")]
		public static var molotovArt:Class;
		
		[Embed(source="assets/art/explosion.png")]
		public static var explosionArt:Class;
		
		[Embed(source="assets/art/monster01anim.png")]
		public static var monsterArt:Class;
		
		[Embed(source="assets/art/monsterskate.png")]
		public static var monsterSkate:Class;
		
		[Embed(source="assets/art/bossanim.png")]
		public static var bossArt:Class;
		
		[Embed(source="assets/art/bossportrait.png")]
		public static var bossPortraitArt:Class;
		
		[Embed(source="assets/art/bouncer.png")]
		public static var bouncerArt:Class;
		
		[Embed(source="assets/art/door.png")]
		public static var doorArt:Class;
		
		[Embed(source="assets/art/jammerportrait.png")]
		public static var jammerPortraitArt:Class;
		
		[Embed(source="assets/art/blockerportrait.png")]
		public static var blockerPortraitArt:Class;
		
		[Embed(source="assets/art/blockerportraitsmall.png")]
		public static var blockerUIPortraitArt:Class;
		
		[Embed(source="assets/art/keymasterportrait.png")]
		public static var keymasterPortraitArt:Class;
		
		[Embed(source="assets/art/keymasterportraitsmall.png")]
		public static var keymasterUIPortraitArt:Class;
		
		[Embed(source="assets/art/dropperportrait.png")]
		public static var throwerPortraitArt:Class;
		
		[Embed(source="assets/art/dropperportraitsmall.png")]
		public static var throwerUIPortraitArt:Class;
		
		[Embed(source="assets/art/mayor.png")]
		public static var mayorPortraitArt:Class;
		
		[Embed(source="assets/art/undo.png")]
		public static var undoButtonArt:Class;
		
		[Embed(source="assets/art/reset.png")]
		public static var resetButtonArt:Class;
		
		[Embed(source="assets/art/dialoguebox2.png")]
		public static var dialogueArt:Class;
		
		[Embed(source="assets/art/speaker.png")]
		public static var speachDirArt:Class;
		
		[Embed(source="assets/art/levelbutton.png")]
		public static var levelButtonArt:Class;
		
		[Embed(source="assets/art/titledraftsmall.png")]
		public static var titleArt:Class;
		
		[Embed(source="assets/art/asphaltong.png")]
		public static var bgFullArt:Class;
		
		[Embed(source="assets/art/playbutton.png")]
		public static var playButtonArt:Class;
		
		[Embed(source="assets/art/creditsbutton.png")]
		public static var creditsButtonArt:Class;
		
		[Embed(source="assets/art/backbutton.png")]
		public static var backButtonArt:Class;
		
		[Embed(source="assets/art/menu.png")]
		public static var menuButtonArt:Class;
		
		[Embed(source="assets/art/win.png")]
		public static var winArt:Class;
		
		// Audio Assets go here 
		[Embed(source="assets/audio/whipSmack.mp3")]
		public static var whipSound:Class;
		
		[Embed(source="assets/audio/recordscratch2.mp3")]
		public static var winRiff:Class;
		
		[Embed(source="assets/audio/vacuum.mp3")]
		public static var loseRiff:Class;
		
		[Embed(source="assets/audio/roll.mp3")]
		public static var rollSound:Class;
		
		[Embed(source="assets/audio/stop.mp3")]
		public static var stopSound:Class;
		
		[Embed(source="assets/audio/hurt.mp3")]
		public static var hurtSound:Class;
		
		[Embed(source="assets/audio/locksound.mp3")]
		public static var lockSound:Class;
		
		[Embed(source="assets/audio/explosion.mp3")]
		public static var explosionSound:Class;
		
		[Embed(source="assets/audio/cat.mp3")]
		public static var catSound:Class;
		
		[Embed(source="assets/audio/mood-indigo-beat.mp3")]
		public static var moodMusic:Class;
		
		[Embed(source="assets/audio/fruity-rose.mp3")]
		public static var moodMusic2:Class;

		public static var bgMusic:Array = [moodMusic, moodMusic2];
		
		[Embed(source="assets/audio/click.mp3")]
		public static var clickRaw:Class;
		private static var clickSound:FlxSound = new FlxSound();
		clickSound.loadEmbedded(clickRaw);
		public static function playClick():void
		{
			clickSound.play(true);
		}
		
		// Level Assets go here
		[Embed(source="assets/levels/testlevel.oel", mimeType="application/octet-stream")]
		public static var testlevel:Class;
		
		[Embed(source="assets/levels/testlevel2.oel", mimeType="application/octet-stream")]
		public static var testlevel2:Class;
		
		[Embed(source="assets/levels/testblocker.oel", mimeType="application/octet-stream")]
		public static var testblocker:Class;
		
		[Embed(source="assets/levels/testblocker2.oel", mimeType="application/octet-stream")]
		public static var testblocker2:Class;
		
		[Embed(source="assets/levels/testblocker3.oel", mimeType="application/octet-stream")]
		public static var testblocker3:Class;
		
		[Embed(source="assets/levels/testkey1.oel", mimeType="application/octet-stream")]
		public static var testkey1:Class;
		
		[Embed(source="assets/levels/testpush.oel", mimeType="application/octet-stream")]
		public static var testpush:Class;
		
		[Embed(source="assets/levels/throwertest.oel", mimeType="application/octet-stream")]
		public static var throwerTest:Class;
		
		[Embed(source="assets/levels/testthrower2.oel", mimeType="application/octet-stream")]
		public static var throwerTest2:Class;
		
		[Embed(source="assets/levels/throwertest4.oel", mimeType="application/octet-stream")]
		public static var throwerTest4:Class;
		
		[Embed(source="assets/levels/jammer1.oel", mimeType="application/octet-stream")]
		public static var jammer1:Class;
		
		[Embed(source="assets/levels/jammer2.oel", mimeType="application/octet-stream")]
		public static var jammer2:Class;
		
		[Embed(source="assets/levels/blocker1.oel", mimeType="application/octet-stream")]
		public static var blocker1:Class;
		
		[Embed(source="assets/levels/blocker2.oel", mimeType="application/octet-stream")]
		public static var blocker2:Class;
		
		[Embed(source="assets/levels/blocker3.oel", mimeType="application/octet-stream")]
		public static var blocker3:Class;
		
		[Embed(source="assets/levels/blocker4.oel", mimeType="application/octet-stream")]
		public static var blocker4:Class;
		
		[Embed(source="assets/levels/keymaster1.oel", mimeType="application/octet-stream")]
		public static var keymaster1:Class;
		
		[Embed(source="assets/levels/keymaster2.oel", mimeType="application/octet-stream")]
		public static var keymaster2:Class;
		
		[Embed(source="assets/levels/keymaster3.oel", mimeType="application/octet-stream")]
		public static var keymaster3:Class;
		
		[Embed(source="assets/levels/keymaster4.oel", mimeType="application/octet-stream")]
		public static var keymaster4:Class;
		
		[Embed(source="assets/levels/thrower1.oel", mimeType="application/octet-stream")]
		public static var thrower1:Class;
		
		[Embed(source="assets/levels/thrower2.oel", mimeType="application/octet-stream")]
		public static var thrower2:Class;
		
		[Embed(source="assets/levels/thrower3.oel", mimeType="application/octet-stream")]
		public static var thrower3:Class;
		
		[Embed(source="assets/levels/bosslevel.oel", mimeType="application/octet-stream")]
		public static var bosslevel:Class;
		
		[Embed(source="assets/levels/testskatemonster.oel", mimeType="application/octet-stream")]
		public static var testskatemonster:Class;
		
		[Embed(source="assets/levels/skatemonster1.oel", mimeType="application/octet-stream")]
		public static var skatemonster1:Class;
		
		[Embed(source="assets/levels/skatemonster2.oel", mimeType="application/octet-stream")]
		public static var skatemonster2:Class;
		
		[Embed(source="assets/levels/skatemonster3.oel", mimeType="application/octet-stream")]
		public static var skatemonster3:Class;
		
		public static var levelList:Array = 
			[ jammer1, jammer2, blocker1, blocker3, blocker2, blocker4, keymaster1
			, keymaster2, keymaster3, keymaster4, testpush, throwerTest, throwerTest4, throwerTest2
			, thrower1, thrower2, thrower3, skatemonster1, skatemonster2,  skatemonster3, bosslevel];
		
		
		// Font Assets
		[Embed(source="assets/fonts/MATCHBOX.TTF", fontFamily="Matchbox", embedAsCFF="false")] 	
		public static var titleFont:String;
		
		[Embed(source="assets/fonts/pf_tempesta_seven_compressed_bold.ttf", fontFamily="Graph35", embedAsCFF="false")]
		public static var mainFont:String;
		
		
	}
}