package utils
{
	import flash.geom.Rectangle;
	
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxPath;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	/**
	 * The intention of the dialogue window class is to represent an interface to the game's dialogue window which can be sent text to display to the player. 
	 * Other functions include setting and changing the portrait that appears next to the dialogue window
	 */
	public class DialogueWindow extends FlxSprite
	{
		private static const dialogue_height:Number = 96;
		
		private var _leftPortrait:FlxSprite = null;
		private var _rightPortrait:FlxSprite = null;
		
		// Sprite indicating whether the speech is coming from the right or the left
		private var _speechDir:FlxSprite = null;
		
		private const _textIndent:Number = 12;
		
		// Here is our private buffer of text strings to include during this dialogue 
		private var _commandBuffer:Array = [];
		
		// The FlxText we use to display our current string on the dialogue window 
		private var _displayText:FlxText = null;
		
		// The FlxText we use to display the name of the person who's talking
		private var _nameText:FlxText = null;
		
		private var _runningEvents:Boolean = false;
		private var _waitingForAdvance:Boolean = false;
		private var _waitingForAnimation:Boolean = false;
		private var _callAfterEvents:Function;
		
		public function DialogueWindow(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			this.loadGraphic(ResourceManager.dialogueArt);
			_nameText = new FlxText(this.x + _textIndent, this.y+12, FlxG.width-2*_textIndent, "???:");
			//_nameText.setFormat("Graph35");
			_displayText = new FlxText(this.x+_textIndent, _nameText.y+15, this.width-2*_textIndent, "...");
			//_displayText.setFormat("Graph35", 8);
			_speechDir = new FlxSprite(-10, -10);
			_speechDir.loadGraphic(ResourceManager.speachDirArt, false, true);
		}
		
		public override function draw():void
		{
			super.draw();
			if (_leftPortrait != null) {
				var dummyLeft:FlxSprite = new FlxSprite(_leftPortrait.x, _leftPortrait.y);
				dummyLeft.makeGraphic(_leftPortrait.width, _leftPortrait.height, 0x00000000, true);
				dummyLeft.stamp(_leftPortrait);
				// Clear any pixels to the left if we need to 
				if (_leftPortrait.x < this.x)
					dummyLeft.framePixels.fillRect(new Rectangle(0, 0, this.x-_leftPortrait.x, _leftPortrait.height), 0x00000000);
				dummyLeft.draw();
			}
			if (_rightPortrait != null) {
				// Same thing for the right portrait 
				var dummyRight:FlxSprite = new FlxSprite(_rightPortrait.x, _rightPortrait.y);
				dummyRight.makeGraphic(_rightPortrait.width, _rightPortrait.height, 0x00000000, true);
				dummyRight.stamp(_rightPortrait);
				if (_rightPortrait.x+_rightPortrait.width > this.x+this.width)
					dummyRight.framePixels.fillRect(new Rectangle(this.x+this.width-_rightPortrait.x, 0, _rightPortrait.x+_rightPortrait.width-(this.x+this.width), _rightPortrait.height), 0x00000000);
				dummyRight.draw();
			}
			// Most important, if we have text, draw it
			_displayText.draw();
			_nameText.draw();
			//_speechDir.draw();
			
			
		}
		
		
		public override function update():void
		{
			if (_leftPortrait != null) {
				_leftPortrait.velocity = new FlxPoint();
				_leftPortrait.preUpdate();
				_leftPortrait.update();
				_leftPortrait.postUpdate();
			}
			if (_rightPortrait != null) {
				_rightPortrait.velocity = new FlxPoint();
				_rightPortrait.preUpdate();
				_rightPortrait.update();
				_rightPortrait.postUpdate();
			}
			_nameText.update();
			_displayText.update();
			_speechDir.update();
			super.update();
			
			var waitingForSomething:Boolean = _waitingForAdvance || _waitingForAnimation;
			
			// Now here's where we do stuff with our events
			if (_waitingForAdvance && (FlxG.mouse.justReleased() || FlxG.keys.justPressed("SPACE") || FlxG.keys.justPressed("ENTER"))) {
				ResourceManager.playClick();
				_waitingForAdvance = false;
			}
			if (_waitingForAnimation) {;
				_waitingForAnimation = false
				if (_leftPortrait != null && _leftPortrait.pathSpeed != 0)
					_waitingForAnimation = true;
				if (_rightPortrait != null && _rightPortrait.pathSpeed != 0) 
					_waitingForAnimation = true;
			}
			
			// If we're not waiting to advance and our command buffer is ready for more, go for it
			
			if (!waitingForSomething && _runningEvents && _commandBuffer.length > 0) {
				var command:Function = _commandBuffer.pop();
				command(this);
			}
			else if (!waitingForSomething && _runningEvents && _commandBuffer.length == 0) {
				_runningEvents = false;
				_callAfterEvents();
			}
			
		
			
		}
		
		// Runs a list of events from an array, including text changes and portrait animations
		public function runEvents(events:Array, callAfter:Function):void
		{
			clearWindow();
			this._commandBuffer = events;
			_commandBuffer.reverse();
			_runningEvents = true;
			_callAfterEvents = callAfter;
		}
		
		public function clearWindow():void
		{
			_displayText.text = "";
			_nameText.text = "";
			_leftPortrait = null;
			_rightPortrait = null;
		}
		
		public function setText(text:String):void 
		{
			// Have to create a new flxText to display the text maybe?
			_displayText.text = text;
		}
		
		public function setName(name:String):void
		{
			_nameText.text = name + ": ";
		}
		
		public function waitForAdvance():void
		{
			_waitingForAdvance = true;
		}

		public function waitForAnimation():void
		{
			_waitingForAnimation = true;
		}
		
		// Function that sets the left and right portraits
		public function setLeftPortrait(sprite:FlxSprite, enter:Boolean = false, enterSpeed:Number=500):void
		{
			var isNew:Boolean = _leftPortrait == null;
			if (isNew) {
				_leftPortrait = sprite;
				_leftPortrait.facing = FlxObject.RIGHT;
			}
			else {
				var oldX:Number = _leftPortrait.x;
				_leftPortrait = sprite;
				_leftPortrait.x = oldX;
				_leftPortrait.y = FlxG.height-dialogue_height-_leftPortrait.height;
				_leftPortrait.facing = FlxObject.RIGHT;
			}

			if (enter) {
				_leftPortrait.x = this.x-_leftPortrait.width;
				_leftPortrait.y = FlxG.height-dialogue_height-_leftPortrait.height;
				leftEnter(enterSpeed);
			}
			else {
				_leftPortrait.x = this.x;
				_leftPortrait.y = FlxG.height-dialogue_height-_leftPortrait.height;
			}
			
		}
		
		public function setRightPortrait(sprite:FlxSprite, enter:Boolean=false, enterSpeed:Number=500):void
		{
			var isNew:Boolean = _rightPortrait == null;
			_rightPortrait = sprite;
			_rightPortrait.facing = FlxObject.LEFT;

			if(enter) {
				_rightPortrait.x = this.x+this.width;
				_rightPortrait.y = FlxG.height-dialogue_height-_rightPortrait.height;
				rightEnter(enterSpeed);
			}
			else {
				_rightPortrait.x = this.x+this.width-_rightPortrait.width;
				_rightPortrait.y = FlxG.height-dialogue_height-_rightPortrait.height;
			}
		}
		// make the left portrait exit if we can 
		public function leftExit(speed:Number):void
		{	
			// Wherever the left portrait is, make it go to the left of the window
			var movePoint:FlxPoint = new FlxPoint(this.x-_leftPortrait.width+_leftPortrait.width/2, FlxG.height-dialogue_height-_leftPortrait.height+_leftPortrait.height/2);
			_leftPortrait.followPath(new FlxPath([movePoint]), speed);
		}
		
		// make the right portrait exit if we can 
		public function rightExit(speed:Number):void
		{	
			// Wherever the left portrait is, make it go to the left of the window
			var movePoint:FlxPoint = new FlxPoint(this.x+this.width+_leftPortrait.width/2, FlxG.height-dialogue_height-_rightPortrait.height+_rightPortrait.height/2);
			_rightPortrait.followPath(new FlxPath([movePoint]), speed);
		}
		
		// Now let's make them enter too
		public function leftEnter(speed:Number):void
		{
			var movePoint:FlxPoint = new FlxPoint(this.x+_leftPortrait.width/2, FlxG.height-dialogue_height-_leftPortrait.height+_leftPortrait.height/2);
			_leftPortrait.followPath(new FlxPath([movePoint]), speed);
		}
		
		public function rightEnter(speed:Number):void
		{
			var movePoint:FlxPoint = new FlxPoint(this.x+this.width-_rightPortrait.width+_rightPortrait.width/2, FlxG.height-dialogue_height-_rightPortrait.height+this._rightPortrait.height/2);
			_rightPortrait.followPath(new FlxPath([movePoint]), speed);
		}
		
		// Play with the speech direction thingy
		public function removeSpeechDir():void
		{
			_speechDir.x = -_speechDir.width;
		}
		
		public function setSpeechDirLeft():void
		{
			_speechDir.y = FlxG.height-dialogue_height-_speechDir.height;
			_speechDir.facing = FlxObject.RIGHT;
			if (_leftPortrait != null) { 
				_speechDir.x = this.x+_leftPortrait.width+5;
			}
			else
				_speechDir.x = this.x;
		}
		
		public function setSpeechDirRight():void
		{
			_speechDir.y = FlxG.height-dialogue_height-_speechDir.height;
			_speechDir.facing = FlxObject.LEFT;
			if (_rightPortrait != null) {
				_speechDir.x = this.x+this.width-_rightPortrait.width-_speechDir.width-5;
			}
			else
				_speechDir.x = this.x+this.width-_speechDir.width;
		}
		
	}
}