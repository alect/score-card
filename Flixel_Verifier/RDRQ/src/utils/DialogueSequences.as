package utils
{
	import flash.utils.Dictionary;
	
	import org.flixel.FlxSprite;

	public class DialogueSequences
	{
		
		private static var jammer:FlxSprite = new FlxSprite(0, 0);
		jammer.loadGraphic(ResourceManager.jammerPortraitArt, false, true);
		private static var blocker:FlxSprite = new FlxSprite(0, 0, ResourceManager.blockerPortraitArt);
		private static var keymaster:FlxSprite = new FlxSprite(0, 0, ResourceManager.keymasterPortraitArt);
		private static var thrower:FlxSprite = new FlxSprite(0, 0, ResourceManager.throwerPortraitArt);
		private static var mayor:FlxSprite = new FlxSprite(0, 0, ResourceManager.mayorPortraitArt);
		private static var finalBoss:FlxSprite = new FlxSprite(0, 0, ResourceManager.bossPortraitArt);
		
		private static var jammerName:String = "Ada";
		private static var jammerFullName:String = "Ada Shoveface";
		private static var blockerName:String = "Marie";
		private static var blockerFullName:String = "Marie Furie";
		private static var keymasterName:String = "Kiera";
		private static var keymasterFullName:String = "Kiera Fightly";
		private static var throwerName:String = "Marge";
		private static var throwerFullName:String = "Margaret Thrasher";
		private static var mayorName:String = "Mayor";
		private static var finalBossName:String = "Leigh";
		private static var finalBossFullName:String = "Lady MacDeath";
		
		private static var jammer1Events:Array = 
			[ DialogueUtils.changeName(jammerName) 
			, DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("...")
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Where the hell is everyone? Practice was supposed to start 5 minutes ago?")
			, DialogueUtils.changeRightPortrait(mayor, true)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.changeName(mayorName)
			, DialogueUtils.text("You there! What are you standing around for!? The city needs your help!", mayorName, false)
			, DialogueUtils.changeName(jammerName)
			, DialogueUtils.text("Um, excuse me?")
			, DialogueUtils.changeName(mayorName) 
			, DialogueUtils.text("You're with the riot squad aren't you? Well get moving! The city is infested with these disgusting monsters!", mayorName, false)
			, DialogueUtils.changeName(jammerName)
			, DialogueUtils.text("Hold on a sec. I'm not with the riot squad, I'm a Riot QUEEN. See, we're a roller derby team and--")
			, DialogueUtils.changeName(mayorName)
			, DialogueUtils.text("I don't have time to argue semantics! It's election season and my opponent is certainly going to say I'm soft on the occult if you don't DO SOMETHING!", mayorName, false)
			, DialogueUtils.changeName(jammerName)
			, DialogueUtils.text("*Sigh* Fine! Everyone else is late anyways, so I might as well clean up a few monsters while I wait.")
			, DialogueUtils.changeName(mayorName)
			, DialogueUtils.text("Fantastic!", mayorName, false)
			, DialogueUtils.rightExit(100)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.changeName(jammerName)
			, DialogueUtils.text("Okay listen up, fourth wall! Use your mouse or the arrow keys to guide my moves so I can take out these monsters.")
			, DialogueUtils.text("I'd like to take care of this quickly, so try to do it in as few moves as possible. Got it?")
			, DialogueUtils.leftExit(300)
			, DialogueUtils.waitForAnimations];
		
		private static var jammer2Events:Array = 
			[ DialogueUtils.changeName(jammerName)
			, DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("What the hell is up with all these traffic cones?")
			, DialogueUtils.waitForAnimations
			, DialogueUtils.changeRightPortrait(mayor, true)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Oh those must be left over from my inaugaration parade.", mayorName, false)
			, DialogueUtils.text("You mean the one that took place three years ago?", jammerName, true)
			, DialogueUtils.text("We didn't really have the budget to remove them, but it's fine since I usually commute by helicopter.", mayorName, false)
			, DialogueUtils.text("...", jammerName, true)
			, DialogueUtils.text("Although my pilot did call in sick today. Something about being mauled by the unspeakable horrors walking the streets.", mayorName, false)
			, DialogueUtils.rightExit(100)
			, DialogueUtils.noSpeech
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Okay, I'd better be careful. If I'm not moving at full speed I'll be easy prey for those things. Try to keep me unharmed. Got it?", jammerName)
			, DialogueUtils.leftExit(300)
			, DialogueUtils.waitForAnimations];
		
		private static var blocker1Events:Array =
			[ DialogueUtils.changeRightPortrait(blocker, true)
			, DialogueUtils.text("Oh goodness me, " + jammerFullName + ", sorry I'm so late.", "???", false)
			, DialogueUtils.changeLeftPortrait(jammer, true) 
			, DialogueUtils.text(blockerFullName + "! Finally, what took you so long?", jammerName)
			, DialogueUtils.text("I was on my way here and everyone just seemed to be in big ole hustle.", blockerName, false)
			, DialogueUtils.text("There were a bunch of these poor creatures, looking so lost standing in the road.", blockerName, false)
			, DialogueUtils.text("They were so confused that they started pawing at the people running away. I was helping them cross the street so they didn't get hit by any cars.", blockerName, false)
			, DialogueUtils.text("Um, those are monsters, dude. They're attacking the city. We're supposed to be killing them.", jammerName)
			, DialogueUtils.text("Oh gracious, I couldn't do that! They're probably more scared of you than you are of them.", blockerName, false)
			, DialogueUtils.text("I bet. But everyone else is super late and I have to let off some steam. Also the mayor asked me to do it.", jammerName)
			, DialogueUtils.swapLeftPortrait(mayor, 500, 300)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Hello.", mayorName)
			, DialogueUtils.text("Oh, it's an honor to meet you sir!", blockerName, false)
			, DialogueUtils.text("Naturally. I'll trust I have your support in this issue?", mayorName)
			, DialogueUtils.text("Well I couldn't say no to the mayor.", blockerName, false)
			, DialogueUtils.text("Fantastic!", mayorName)
			, DialogueUtils.swapLeftPortrait(jammer, 100, 500)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("But I just can't bring myself to harm any of these poor things. I'll just push them where you need them, " + jammerName + ", and you can take care of the rest.", blockerName, false)
			, DialogueUtils.text("Hey, if you're not gonna hurt them, watch out! They can pack a punch.", jammerName, false)
			, DialogueUtils.text("Don't worry about me, I'm as tough as cold butter!", blockerName, false)
			, DialogueUtils.rightExit(400)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("You should probably work on your metaphors.", jammerName)
			, DialogueUtils.leftExit(500)
			, DialogueUtils.waitForAnimations];
		
		private static var blocker2Events:Array = 
			[ DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("More cones...", jammerName)
			, DialogueUtils.changeRightPortrait(blocker, true)
			, DialogueUtils.text("Oh, if they're small cones, I should be able to move them out of the way for you.", blockerName, false)
			, DialogueUtils.text("Oh, cool.", jammerName)
			, DialogueUtils.leftExit(500)
			, DialogueUtils.rightExit(500)
			, DialogueUtils.waitForAnimations ];
		
		
		private static var keymaster1Events:Array = 
			[ DialogueUtils.changeRightPortrait(mayor, true, 300)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Riot Queens, for your invaluable service to the city, I am proud to present you--", mayorName, false)
			, DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("Hold up, man! The streets are still covered in monsters. Aren't you jumping the gun a bit here?", jammerName)
			, DialogueUtils.text("Not at all! Municipal Ordinance 22563 dictates that the minimum monster smashing quota for heroic status be set at 22 monsters.", mayorName, false)
			, DialogueUtils.text("Okay, but can you hold off for a bit? We're kinda busy killing the monsters here.", jammerName)
			, DialogueUtils.text("And let my opponent slam me for failing to support our combat veterans? Never!", mayorName, false)
			, DialogueUtils.text("As I was saying, I am proud to present you with the key to the city!", mayorName, false)
			, DialogueUtils.text("Are you serious?", jammerName)
			, DialogueUtils.swapLeftPortrait(blocker, 600)
			, DialogueUtils.text("Oh my!", blockerName)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("Were you carrying that around in your pocket this whole time?", jammerName)
			, DialogueUtils.text("Of course, which is why I only have one copy. Now who shall I present this to?", mayorName, false)
			, DialogueUtils.leftExit(500)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("That would be me!", "???")
			, DialogueUtils.changeLeftPortrait(keymaster, true)
			, DialogueUtils.text(keymasterFullName + "! Ace Jammer of the Roller Derby Riot Queens!", keymasterName)
			, DialogueUtils.swapRightPortrait(blocker, 600)
			, DialogueUtils.text("Oh, hello, " + keymasterName + ".", blockerName, false)
			, DialogueUtils.swapRightPortrait(jammer, 600)
			, DialogueUtils.text(keymasterName + ", you do NOT get to call yourself the ace when you are this late to practice.", jammerName, false)
			, DialogueUtils.text("Ack! " + jammerName + ", I didn't see you there. Am I late, heheh? Well it's just because the whole town's a party right now! Seriously, why aren't you guys tearing it up!", keymasterName)
			, DialogueUtils.text("Because we're tearing up these monsters. Now that you're here we could possibly use your help.", jammerName, false)
			, DialogueUtils.text("Okay okay, but can I just ask one tiny favor?", keymasterName)
			, DialogueUtils.text("What?", jammerName, false)
			, DialogueUtils.text("Can I please please please have the key to the city? I swear I've always wanted it since, like, 3 minutes ago!", keymasterName)
			, DialogueUtils.text("You want that piece of junk? Fine! What the hell does it even open anyways?", jammerName, false)
			, DialogueUtils.swapRightPortrait(mayor, 500)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Why, it opens every door in the city!", mayorName, false)
			, DialogueUtils.text("Really?", keymasterName)
			, DialogueUtils.text("No, it actually only opens these locked doors I had scattered all over the city streets!", mayorName, false)
			, DialogueUtils.swapLeftPortrait(jammer, 500, 500)
			, DialogueUtils.text("Why the hell are those there anyways?", jammerName)
			, DialogueUtils.text("We felt it would improve community spirit to have our commuters navigate a \"fun-for-the-whole-family\" labyrinth of quality doors everyday.", mayorName, false)
			, DialogueUtils.swapLeftPortrait(blocker, 600)
			, DialogueUtils.text("What fun!", blockerName)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("...", jammerName)
			, DialogueUtils.text("Aren't you a private consultant to \"Doors Unlimited\"?", jammerName)
			, DialogueUtils.text("*Cough* Look at that! You're very busy killing those monsters aren't you? I'll let you get to it then.", mayorName, false)
			, DialogueUtils.swapRightPortrait(keymaster, 100, 500)
			, DialogueUtils.waitForAnimations
			, DialogueUtils.text("Okay then, " + keymasterName + ". I guess we're going to be relying on you to open those doors for us.", jammerName, false)
			, DialogueUtils.text("On it, chief!", keymasterName, false)
			, DialogueUtils.leftExit(500)
			, DialogueUtils.rightExit(400)
			, DialogueUtils.waitForAnimations];
		
		public static var keymaster2Events:Array =
			[ DialogueUtils.changeRightPortrait(keymaster, true)
			, DialogueUtils.text("Man this key is heavy, it's hard to do anything else while holding it.", keymasterName, false)
			, DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("Like what?", jammerName)
			, DialogueUtils.text("Like hit monsters.", keymasterName, false)
			, DialogueUtils.text("Is that why you keep getting hurt when you attack monsters?", jammerName)
			, DialogueUtils.text("Yeah, well! I bet I'm hitting them harder anyways.", keymasterName, false)
			, DialogueUtils.text("Sure...We'll just make sure you don't have to fight too many alright?", jammerName)
			, DialogueUtils.text("Thanks!", keymasterName, false)
			, DialogueUtils.leftExit(500)
			, DialogueUtils.rightExit(500)
			, DialogueUtils.waitForAnimations];
		
		public static var thrower1Events:Array =
			[ DialogueUtils.changeRightPortrait(thrower, true, 100)
			, DialogueUtils.text("...Oh, hey guys. What brings you to this neck of the woods?", "???", false)
			, DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("..." + throwerFullName + "...", jammerName)
			, DialogueUtils.text("Yeah?", throwerName, false)
			, DialogueUtils.text("What the hell are you doing here? And where's all your gear? We're supposed to be having practice right now!", jammerName)
			, DialogueUtils.text("...Doesn't look like practice to me.", throwerName, false)
			, DialogueUtils.text("Well the mayor asked us to clean up these monsters, but we're starting practice AS SOON AS THAT'S DONE!", jammerName)
			, DialogueUtils.text("Oh...I can dig it. I guess that means all these molotov cocktails I brought with me should come in handy. They can blow up all sorts of stuff.", throwerName, false)
			, DialogueUtils.text("...", jammerName)
			, DialogueUtils.text("Why do you have molotov cocktails...?", jammerName)
			, DialogueUtils.text("Like...For practice, you know. Practice rioting...", throwerName, false)
			, DialogueUtils.text("For god's sake, we're not rioting! We're the Riot QUEENS. You know, the Roller Derby team?", jammerName)
			, DialogueUtils.text("Oh yeah...I get my extracurriculars mixed up sometimes.", throwerName, false)
			, DialogueUtils.swapLeftPortrait(keymaster, 600)
			, DialogueUtils.text("Hey, " + throwerName + ", check it out! I tricked the mayor into giving me the key to the city!", keymasterName)
			, DialogueUtils.text("Haha...Radical!", throwerName, false)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("Anyways, let's finish this up quick. " + throwerName + ", you just stand there and throw your bombs.", jammerName)
			, DialogueUtils.text("...Okay, just don't expect me to take any hits...I seem to have forgotten my helmet...", throwerName, false)
			, DialogueUtils.swapLeftPortrait(blocker, 600)
			, DialogueUtils.text("Oh, I'll protect you, " + throwerName + ", I've got the endurance of slow mollases after all.", blockerName)
			, DialogueUtils.text("Mollases...Sweeet...", throwerName, false)
			, DialogueUtils.leftExit(600)
			, DialogueUtils.rightExit(100)
			, DialogueUtils.waitForAnimations];
		
		public static var throwerCatchEvents:Array = 
			[ DialogueUtils.changeLeftPortrait(thrower, true)
			, DialogueUtils.text("Hey..." + blockerName + "...how's your catching arm?", throwerName)
			, DialogueUtils.changeRightPortrait(blocker, true)
			, DialogueUtils.text("As good as a mockingbird in winter, why?", blockerName, false)
			, DialogueUtils.text("Think you could catch some of these cocktails I'm throwing?", throwerName)
			, DialogueUtils.text("Well I could give it the old high-school try!", blockerName, false)
			, DialogueUtils.swapRightPortrait(jammer, 500)
			, DialogueUtils.text("Uh, are you sure this is a good idea, guys?", jammerName, false)
			, DialogueUtils.text("Yeah, man...Piece of cake...", throwerName)
			, DialogueUtils.swapRightPortrait(blocker, 500)
			, DialogueUtils.text("I'm sure it'll all turn out peachy!", blockerName, false)
			, DialogueUtils.leftExit(100)
			, DialogueUtils.rightExit(400)
			, DialogueUtils.waitForAnimations];
		
		public static var throwerLockEvents:Array =
			[ DialogueUtils.changeLeftPortrait(thrower, true)
			, DialogueUtils.text("...Man...What's up with these doors...I can't seem to blow them up...", throwerName)
			, DialogueUtils.changeRightPortrait(mayor, true)
			, DialogueUtils.text("They're only the highest quality doors!", mayorName, false)
			, DialogueUtils.swapRightPortrait(keymaster, 100, 600)
			, DialogueUtils.text("I can open them, " + throwerName + ", leave it to me!", keymasterName, false)
			, DialogueUtils.text("...Good man...Bust me out of this prison...The walls feel like they're closing in...", throwerName)
			, DialogueUtils.swapRightPortrait(jammer, 500)
			, DialogueUtils.text("How'd you get in there, anyways?", jammerName, false)
			, DialogueUtils.text(".......?", throwerName)
			, DialogueUtils.leftExit(100)
			, DialogueUtils.rightExit(500)
			, DialogueUtils.waitForAnimations];
		
		public static var skateMonsterEvents:Array = 
			[ DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("Are those monsters...Wearing roller skates?", jammerName)
			, DialogueUtils.changeRightPortrait(keymaster, true)
			, DialogueUtils.text("Oh my god THEY'RE EVOLVING!", keymasterName, false)
			, DialogueUtils.swapRightPortrait(blocker, 500)
			, DialogueUtils.text("They look like they're having fun!", blockerName, false)
			, DialogueUtils.rightExit(400)
			, DialogueUtils.text("Okay, well they don't look very smart.", jammerName)
			, DialogueUtils.text("Let's see if we can figure out a pattern and take them out in the usual way.", jammerName)
			, DialogueUtils.leftExit(400)
			, DialogueUtils.waitForAnimations];
		
		private static var boss1Events:Array =
			[ DialogueUtils.changeRightPortrait(blocker, true)
				, DialogueUtils.changeLeftPortrait(jammer, true)
				, DialogueUtils.text("Oh, I just got a text from " + finalBossName + ". She says she's sorry she's late. Something at work is holding her up.", blockerName, false)
				, DialogueUtils.text("Okay, well at least she LET US KNOW she would be late.", jammerName)
				, DialogueUtils.text("Sorry!", blockerName, false)
				, DialogueUtils.leftExit(500)
				, DialogueUtils.rightExit(500)
				, DialogueUtils.waitForAnimations];
		
		private static var boss2Events:Array = 
			[ DialogueUtils.changeLeftPortrait(thrower, true)
			, DialogueUtils.text("...Oh, by the way guys, I ran into " + finalBossName + " earlier...", throwerName)
			, DialogueUtils.text("...She said work was taking way longer than normal...Something about a bunch of idiots getting in her way...", throwerName)
			, DialogueUtils.changeRightPortrait(jammer, true)
			, DialogueUtils.text("What does she do for work again?", jammerName, false)
			, DialogueUtils.text("...I dunno...Sell incense?", throwerName)
			, DialogueUtils.leftExit(100)
			, DialogueUtils.rightExit(400)
			, DialogueUtils.waitForAnimations];
		
		public static var bossIntroEvents:Array = 
			[ DialogueUtils.changeLeftPortrait(mayor, true)
			, DialogueUtils.text("There she is! The dreaded necromancer shows her face at last!", mayorName)
			, DialogueUtils.changeRightPortrait(finalBoss, true)
			, DialogueUtils.text("A pleasure Mister mayor.", "???", false)
			, DialogueUtils.text("You won't get away with what you've done to my fair city!", mayorName)
			, DialogueUtils.text("But I will. You cannot stop me with naught but bluster and crooked words. This city now belongs to " + finalBossFullName + "!", "???", false)
			, DialogueUtils.text("Not so! I've enlisted the aid of an elite strike force that will be more than your match!", mayorName)
			, DialogueUtils.text("Riot Queens! Bring this menace to justice!", mayorName)
			, DialogueUtils.swapLeftPortrait(blocker, 600)
			, DialogueUtils.text("So that's where you were. We were waiting for you, " + finalBossName + ".", blockerName)
			, DialogueUtils.swapLeftPortrait(keymaster, 600)
			, DialogueUtils.text("Hey, " + finalBossName + "! Whatcha up to!?", keymasterName)
			, DialogueUtils.swapLeftPortrait(thrower, 600)
			, DialogueUtils.text("...Man, where'd you get all the monsters? ...Wicked!", throwerName)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("You are so very very late...", jammerName)
			, DialogueUtils.text("Oh! Hi guys! Sorry about being late, work has been kind of hectic today!", finalBossName, false)
			, DialogueUtils.text("I'll be right over. I just need to defeat the mayor's \"elite strike force\". Whatever that means.", finalBossName, false)
			, DialogueUtils.text("Uh, I think he was referring to us, dude?", jammerName)
			, DialogueUtils.text("Haha, really!? How'd you guys get dragged into that?", finalBossName, false)
			, DialogueUtils.text("It's a long story...", jammerName)
			, DialogueUtils.text("...but the REAL question is why were you summoning unholy terrors to devour citizens instead of coming to practice!", jammerName)
			, DialogueUtils.text("Oh, this is my day job!", finalBossName, false)
			, DialogueUtils.text("...and the mayor is pretty much a huge tool.", finalBossName, false)
			, DialogueUtils.swapLeftPortrait(mayor, 600)
			, DialogueUtils.text("Hey!", mayorName)
			, DialogueUtils.swapLeftPortrait(keymaster, 600)
			, DialogueUtils.text("Haha!", keymasterName)
			, DialogueUtils.swapLeftPortrait(thrower, 600)
			, DialogueUtils.text("...Yup", throwerName) 
			, DialogueUtils.swapLeftPortrait(blocker, 600)
			, DialogueUtils.text("But he has such a nice smile...", blockerName)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("Well I really can't argue with that...", jammerName)
			, DialogueUtils.text("...", jammerName)
			, DialogueUtils.text("...But we're still going to beat you up!", jammerName)
			, DialogueUtils.text("What, why!?", finalBossName, false)
			, DialogueUtils.text("Not because of monsters or the mayor or anything...", jammerName)
			, DialogueUtils.text("...But because you were SO LATE TO PRACTICE!", jammerName)
			, DialogueUtils.swapLeftPortrait(keymaster, 600)
			, DialogueUtils.text("Yeah!", keymasterName)
			, DialogueUtils.swapLeftPortrait(thrower, 600)
			, DialogueUtils.text("...Glad it's not me...", throwerName) 
			, DialogueUtils.swapLeftPortrait(blocker, 600)
			, DialogueUtils.text("You know the rules, " + finalBossName + ".", blockerName)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("Riot Queens, take her out!", jammerName)
			, DialogueUtils.text("Well you're welcome to try! But you'll soon see, I'm no easy target!", finalBossName, false)
			, DialogueUtils.text("Give me your best shot! " + finalBossFullName + " will be your end!", finalBossName, false)
			, DialogueUtils.leftExit(500)
			, DialogueUtils.rightExit(500)
			, DialogueUtils.waitForAnimations];
		
		public static var bossOutroEvents:Array = 
			[ DialogueUtils.changeRightPortrait(finalBoss, true)
			, DialogueUtils.text("Argh! Okay, okay, I yield!", finalBossName, false)
			, DialogueUtils.changeLeftPortrait(jammer, true)
			, DialogueUtils.text("Good! Have you learned your lesson?", jammerName)
			, DialogueUtils.text("Yeah! Okay! Next time, I will totally unleash my monsters on a day when we don't have practice, sheesh!", finalBossName, false)
			, DialogueUtils.text("Awesome...", jammerName)
			, DialogueUtils.text("Okay guys, it took a while, but good practice! Let's get some ice-cream or something!", jammerName)
			, DialogueUtils.swapLeftPortrait(keymaster, 600)
			, DialogueUtils.text("Oooh! Let's get some fro-yo! I saw on the way over, berry-curve was only half destroyed!", keymasterName)
			, DialogueUtils.swapRightPortrait(mayor, 600)
			, DialogueUtils.text("Yes, Riot Queens! A delicious reward is certainly in order! Now, if you'll be so kind as to hand over this degenerate...", mayorName, false)
			, DialogueUtils.swapLeftPortrait(jammer, 600)
			, DialogueUtils.text("Man, Shove off! I've had enough civic duty for one day! Let's get out of here, guys.", jammerName)
			, DialogueUtils.text("...but", mayorName, false)
			, DialogueUtils.swapLeftPortrait(blocker, 400, 600)
			, DialogueUtils.text("Good luck in the elections, Mister Mayor!", blockerName)
			, DialogueUtils.swapLeftPortrait(keymaster, 400, 600)
			, DialogueUtils.text("I'm totally keeping the key to the city man, seeya!", keymasterName)
			, DialogueUtils.swapLeftPortrait(thrower, 400, 600)
			, DialogueUtils.text("It's been real, dude...See you at the next riot...", throwerName)
			, DialogueUtils.swapLeftPortrait(finalBoss, 100, 600)
			, DialogueUtils.text("Let's do this again sometime, Mayor? How about next week?", finalBossName)
			, DialogueUtils.leftExit(400)
			, DialogueUtils.text("...", mayorName, false)
			, DialogueUtils.waitForAnimations ];
		bossOutroEvents = DialogueUtils.makeEventsList(bossOutroEvents);
		
		public static var dialogueMap:Dictionary = new Dictionary();
		dialogueMap["intro"] = DialogueUtils.makeEventsList(jammer1Events);
		dialogueMap["damage"] = DialogueUtils.makeEventsList(jammer2Events);
		dialogueMap["blocker"] = DialogueUtils.makeEventsList(blocker1Events);
		dialogueMap["boss1"] = DialogueUtils.makeEventsList(boss1Events);
		dialogueMap["boss2"] = DialogueUtils.makeEventsList(boss2Events);
		dialogueMap["pushcones"] = DialogueUtils.makeEventsList(blocker2Events)
		dialogueMap["keymaster"] = DialogueUtils.makeEventsList(keymaster1Events);
		dialogueMap["keymaster2"] = DialogueUtils.makeEventsList(keymaster2Events);
		dialogueMap["thrower"] = DialogueUtils.makeEventsList(thrower1Events);
		dialogueMap["catch"] = DialogueUtils.makeEventsList(throwerCatchEvents);
		dialogueMap["lock"] = DialogueUtils.makeEventsList(throwerLockEvents);
		dialogueMap["skate"] = DialogueUtils.makeEventsList(skateMonsterEvents);
		dialogueMap["boss"] = DialogueUtils.makeEventsList(bossIntroEvents);
		
		
		
	}
}