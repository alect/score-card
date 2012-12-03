package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxBasic;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxRect;
	import org.flixel.FlxSound;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	public class RiotQueen extends GridPiece
	{
		// Used to sort the queens in terms of turn order 
		protected var _queenIndex:int;
		public function get queenIndex():int
		{
			return _queenIndex;
		}
		
		protected var _loseText:String = "Arrrgh, I'm hit!";
		public function get loseText():String 
		{
			return _loseText;
		}
		
		protected var _inControl:Boolean = false;
		
		protected var _chosenMove:Boolean = false;
		public function set chosenMove(value:Boolean):void
		{
			_chosenMove = value;
		}
		public function get chosenMove():Boolean
		{
			return _chosenMove;
		}
		
		
		protected var _rollSound:FlxSound;
		//protected var _stopSound:FlxSound;
		
		protected var _hurtSound:FlxSound;
		
		protected var _maxHealth:Number;
		public function get maxHealth():Number
		{
			return _maxHealth;
		}
		
		protected var _name:String;
		public function get name():String
		{
			return _name;
		}
		
		// Riot queens also have a portrait for their 
		// Dialogue sequences. 
		protected var _portrait:Class;
		public function get portrait():Class
		{
			return _portrait;
		}
		
		protected var _uiPortrait:Class;
		public function get uiPortrait():Class
		{
			return _uiPortrait;
		}
		
		
		public function set inControl(value:Boolean):void
		{
			_inControl = value;
		}
		public function get inControl():Boolean
		{
			return _inControl;
		}
		
		protected var _arrowSprite:FlxSprite;
		
		protected var _rollDir:uint = FlxObject.UP;
		
		public function RiotQueen(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite = new FlxSprite();
			
			_arrowSprite = new FlxSprite();
			_arrowSprite.loadRotatedGraphic(ResourceManager.arrowArt, 4);
			_arrowSprite.alpha = 0.7;
			
			_type = GridPiece.PLAYER_TYPE | GridPiece.JAMMER_TYPE;
			_sprite.loadGraphic(ResourceManager.jammerArt, true, true);
			_sprite.frame = 0;
		
			
			_rollSound = new FlxSound();
			_rollSound.loadEmbedded(ResourceManager.rollSound, true);
			
			_hurtSound = new FlxSound();
			_hurtSound.loadEmbedded(ResourceManager.hurtSound);
			
			//_stopSound = new FlxSound();
			//_stopSound.loadEmbedded(ResourceManager.stopSound);
			
			_portrait = ResourceManager.jammerPortraitArt;
			_maxHealth = 2;
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
		}
		
		public override function pauseSounds():void
		{
			_rollSound.pause();
		}
		
		public override function resumeSounds():void
		{
			_rollSound.resume();
		}
		
		public override function beAttacked(attacker:GridPiece):void
		{
			this.health -= attacker.attackPower;
			// Get a red tint for a while after being attacked
			_sprite.color = 0xffff0000;
			_hurtSound.play(true);
			if (health <= 0) {
				PlayState.instance.riotQueenDefeated(this);
			}
		}
		
		public override function roundStart():void
		{
			// Make our arrow dissapear when the round starts
			_chosenMove = false;
		}
		
		public override function update():void {
			super.update();
			
			if (_sprite.color != 0xffffffff) {
				// Increase the other colors
				var green:uint = (_sprite.color & 0x0000ff00);
				if (green < 0x0000ff00)
					green = Math.min(0x0000ff00, green + 0x00000a00);
				var blue:uint = (_sprite.color & 0x000000ff);
				if (blue < 0x000000ff) 
					blue = Math.min(0x000000ff, blue+0xa);
				_sprite.color = 0xffff0000 | green | blue;
			}
			
			if (_inControl) {
				var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
				var canMoveUp:Boolean = true;
				var canMoveRight:Boolean = true;
				var canMoveDown:Boolean = true;
				var canMoveLeft:Boolean = true;
				
				_nextTarget = new Point(gridPos.x, gridPos.y-1);
				canMoveUp = PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.UP);
				_nextTarget = new Point(gridPos.x+1, gridPos.y);
				canMoveRight = PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.RIGHT);
				_nextTarget = new Point(gridPos.x, gridPos.y+1);
				canMoveDown = PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.DOWN);
				_nextTarget = new Point(gridPos.x-1, gridPos.y);
				canMoveLeft = PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.LEFT);
				
				// If we can't move anywhere, just end the turn
				if (!(canMoveUp || canMoveRight || canMoveDown || canMoveLeft)) {
					_inControl = false;
					_chosenMove = true;
				}
				
				// Here's where we place the control scheme. 
				// Use the arrow keys or the mouse to decide which direction this 
				// Riot queen will be going at the start of the round. 
				
				if (FlxG.keys.justPressed("UP")) {
					_nextTarget = new Point(gridPos.x, gridPos.y-1);
					if (canMoveUp) {
						_rollDir = FlxObject.UP;
						ResourceManager.playClick();
						_inControl = false;
						_chosenMove = true;
					}
				}
				else if (FlxG.keys.justPressed("RIGHT")) {
					_nextTarget = new Point(gridPos.x+1, gridPos.y);
					if (canMoveRight) {
						_rollDir = FlxObject.RIGHT;
						ResourceManager.playClick();
						_inControl = false;
						_chosenMove = true;
					}
				}
				else if (FlxG.keys.justPressed("DOWN")) { 
					_nextTarget = new Point(gridPos.x, gridPos.y+1);
					if (canMoveDown) {
						_rollDir = FlxObject.DOWN;
						ResourceManager.playClick();
						_inControl = false;
						_chosenMove = true;
					}
				}
				else if (FlxG.keys.justPressed("LEFT")) { 
					_nextTarget = new Point(gridPos.x-1, gridPos.y);
					if (canMoveLeft) {
						_rollDir = FlxObject.LEFT;
						ResourceManager.playClick();
						_inControl = false;
						_chosenMove = true;
					}
				}
				
				// TODO: Mouse Controls
				if (FlxG.mouse.justPressed()) {
					// Let's see if it landed to the right of us
					var mouseRect:FlxRect = new FlxRect(FlxG.mouse.x, FlxG.mouse.y, 1, 1);
					var upRect:FlxRect = new FlxRect(this.x, this.y-Globals.CELL_SIZE, Globals.CELL_SIZE, Globals.CELL_SIZE);
					var rightRect:FlxRect = new FlxRect(this.x+Globals.CELL_SIZE, this.y, Globals.CELL_SIZE, Globals.CELL_SIZE);
					var downRect:FlxRect = new FlxRect(this.x, this.y+Globals.CELL_SIZE, Globals.CELL_SIZE, Globals.CELL_SIZE);
					var leftRect:FlxRect = new FlxRect(this.x-Globals.CELL_SIZE, this.y, Globals.CELL_SIZE, Globals.CELL_SIZE);
					
					if (upRect.overlaps(mouseRect)) {
						_nextTarget = new Point(gridPos.x, gridPos.y-1);
						if (canMoveUp) {
							_rollDir = FlxObject.UP;
							ResourceManager.playClick();
							_inControl = false;
							_chosenMove = true;
						}
					}
					else if (rightRect.overlaps(mouseRect)) { 
						_nextTarget = new Point(gridPos.x+1, gridPos.y);
						if (canMoveRight) {
							_rollDir = FlxObject.RIGHT;
							ResourceManager.playClick();
							_inControl = false;
							_chosenMove = true;
						}
					}
					else if (downRect.overlaps(mouseRect)) { 
						_nextTarget = new Point(gridPos.x, gridPos.y+1);
						if (canMoveDown) {
							_rollDir = FlxObject.DOWN;
							ResourceManager.playClick();
							_inControl = false;
							_chosenMove = true;
						}
					}
					else if (leftRect.overlaps(mouseRect)) { 
						_nextTarget = new Point(gridPos.x-1, gridPos.y);
						if (canMoveLeft) {
							_rollDir = FlxObject.LEFT;
							ResourceManager.playClick();
							_inControl = false;
							_chosenMove = true;
						}
					}
					
				}
				
			}
		}
		
		public override function draw():void {
			_sprite.x = this.x;
			_sprite.y = this.y;
			
			switch(_rollDir) {
				case FlxObject.UP:
					_sprite.frame = 2;
					break;
				case FlxObject.RIGHT:
					_sprite.frame = 1;
					_sprite.facing = FlxObject.LEFT;
					break;
				case FlxObject.DOWN:
					_sprite.frame = 0;
					break;
				case FlxObject.LEFT:
					_sprite.frame = 1;
					_sprite.facing = FlxObject.RIGHT;
					break;
					
			}
			
			_sprite.draw();
			
		}
		
		public function drawArrows():void
		{
			// If we're controlling this riot queen right now, have to decide which direction she'll face
			// Draw arrows on the grid to indicate possible directions
			if (_inControl) {
				_arrowSprite.color = 0xffffffff;
				var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
				// First above us. 
				_nextTarget = new Point(gridPos.x, gridPos.y-1);
				if (PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.UP)) {
					
					_arrowSprite.x = x;
					_arrowSprite.y = y-Globals.CELL_SIZE;
					_arrowSprite.frame = 0;
					_arrowSprite.draw();
				}
				
				// Next to the right 
				_nextTarget = new Point(gridPos.x+1, gridPos.y);
				if (PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.RIGHT)) {
					_arrowSprite.x = x+Globals.CELL_SIZE;
					_arrowSprite.y = y;
					_arrowSprite.frame = 1;
					_arrowSprite.draw();
				}
				
				// Next down 
				_nextTarget = new Point(gridPos.x, gridPos.y+1);
				if (PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.DOWN)) {
					_arrowSprite.x = x;
					_arrowSprite.y = y+Globals.CELL_SIZE;
					_arrowSprite.frame = 2;
					_arrowSprite.draw();
				}
				
				// Next Left
				_nextTarget = new Point(gridPos.x-1, gridPos.y);
				if (PlayState.instance.queenCanMoveHere(_nextTarget, this, FlxObject.LEFT)) {
					_arrowSprite.x = x-Globals.CELL_SIZE;
					_arrowSprite.y = y;
					_arrowSprite.frame = 3;
					_arrowSprite.draw();
				}
			}
			else if(_chosenMove) {
				_arrowSprite.color = 0xff00ff00;
				switch(_rollDir) {
					
					case FlxObject.UP:
						// First above us. 
						_arrowSprite.x = x;
						_arrowSprite.y = y-Globals.CELL_SIZE;
						_arrowSprite.frame = 0;
						_arrowSprite.draw();
						break;
					case FlxObject.RIGHT:
						_arrowSprite.x = x+Globals.CELL_SIZE;
						_arrowSprite.y = y;
						_arrowSprite.frame = 1;
						_arrowSprite.draw();
						break;
					case FlxObject.DOWN:
						_arrowSprite.x = x;
						_arrowSprite.y = y+Globals.CELL_SIZE;
						_arrowSprite.frame = 2;
						_arrowSprite.draw();
						break;
					case FlxObject.LEFT:
						_arrowSprite.x = x-Globals.CELL_SIZE;
						_arrowSprite.y = y;
						_arrowSprite.frame = 3;
						_arrowSprite.draw();
						break;
				}
			}
		}
		
	}
}