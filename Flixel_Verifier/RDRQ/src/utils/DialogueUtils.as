// ActionScript file
package utils
{
	import org.flixel.FlxSprite;

	public class DialogueUtils
	{
		// Utility function that will recursively concatenate an events list until it's a single array
		public static function makeEventsList(events:Array):Array
		{
			var retArray:Array = [];
			for each(var event:Object in events) {
				if (event is Array) {
					var subEventsList:Array = makeEventsList(event as Array);
					retArray = retArray.concat(subEventsList);
				}
				else {
					retArray.push(event);
				}
				
			}
			return retArray;
		}
	
		public static function changeLeftPortrait(sprite:FlxSprite, enter:Boolean = false, enterSpeed:Number=500):Function
		{
			return function(window:DialogueWindow):void 
			{
				window.setLeftPortrait(sprite, enter, enterSpeed);
			};
		}
		
		public static function changeRightPortrait(sprite:FlxSprite, enter:Boolean=false, enterSpeed:Number=500):Function
		{
			return function(window:DialogueWindow):void
			{
				window.setRightPortrait(sprite, enter, enterSpeed);
			};
			
		}
		
		public static function swapLeftPortrait(sprite:FlxSprite, exitSpeed:Number, enterSpeed:Number = -1):Array
		{
			var retEvents:Array = [leftExit(exitSpeed), waitForAnimations];
			if (enterSpeed == -1)
				retEvents.push(changeLeftPortrait(sprite, true, exitSpeed));
			else
				retEvents.push(changeLeftPortrait(sprite, true, enterSpeed));
			
			return retEvents;

		}
		
		public static function swapRightPortrait(sprite:FlxSprite, exitSpeed:Number, enterSpeed:Number = -1):Array
		{
			var retEvents:Array = [rightExit(exitSpeed), waitForAnimations];
			if (enterSpeed == -1)
				retEvents.push(changeRightPortrait(sprite, true, exitSpeed));
			else
				retEvents.push(changeRightPortrait(sprite, true, enterSpeed));
			
			return retEvents;

		}
		
		public static function waitForAnimations(window:DialogueWindow):void
		{
			window.waitForAnimation();
		}
		
		public static function waitForAdvance(window:DialogueWindow):void
		{
			window.waitForAdvance();
		}
		
		public static function noSpeech(window:DialogueWindow):void
		{
			window.removeSpeechDir();
		}
		
		public static function leftEnter(speed:Number):Function
		{
			return function(window:DialogueWindow):void
			{
				window.leftEnter(speed);
			};
		}
		
		public static function rightEnter(speed:Number):Function
		{
			return function(window:DialogueWindow):void
			{
				window.rightEnter(speed);
			};
		}
		
		public static function leftExit(speed:Number):Function
		{
			return function(window:DialogueWindow):void
			{
				window.leftExit(speed);
			};
		}
		
		public static function rightExit(speed:Number):Function
		{
			return function(window:DialogueWindow):void
			{
				window.rightExit(speed);
			};
		}
		
		public static function changeName(name:String):Function
		{
			return function(window:DialogueWindow):void
			{
				window.setName(name);
			}
		}
		
		public static function text(text:String, name:String=null, leftDir:Boolean=true):Function
		{
			return function(window:DialogueWindow):void 
			{ 
				if (name != null)
					window.setName(name);
				window.setText(text);
				if (leftDir)
					window.setSpeechDirLeft();
				else
					window.setSpeechDirRight();
				
				window.waitForAdvance();
			};
		}
	}
}