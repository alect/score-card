package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.osmf.layout.AbsoluteLayoutFacet;
	
	import utils.*;
	
	public class GridPiece extends FlxObject
	{
		// Some constants for the type of the cell piece
		// Designed so they can be combined easily with bit-twiddles
		public static const WALL_TYPE:uint = 0x1;
		public static const JAMMER_TYPE:uint = 0x2;
		public static const BLOCKER_TYPE:uint = 0x4;
		public static const ENEMY_TYPE:uint = 0x8;
		public static const PLAYER_TYPE:uint = 0x10;
		public static const MISC_TYPE:uint = 0x20;
		public static const BOSS_TYPE:uint = 0x40;
		
		protected var _stopped:Boolean = true;
		protected var _pushed:Boolean = false;
		protected var _dying:Boolean = false;
		
		// Whether we have already claimed a point this turn
		protected var _claimed:Boolean = false;
		
		// Mainly for monsters and riot queens
		protected var _attackPower:Number;
		
		// Okay, here we go, the damn sprite
		protected var _sprite:FlxSprite;
		
		
		public function get attackPower():Number
		{
			return _attackPower;
		}
		
		
		public function get stopped():Boolean
		{
			return _stopped;
		}
		public function set stopped(value:Boolean):void
		{
			_stopped = value;
		}
		
		public function get pushed():Boolean
		{
			return _pushed;
		}
		public function set pushed(value:Boolean):void
		{
			_pushed = value;
		}
		
		protected var _type:uint;
		public function get type():uint 
		{
			return _type;
		}
		protected var _nextTarget:Point;
		public function get nextTarget():Point
		{
			return _nextTarget;
		}
		
		public function switchTarget(claimedGrid:Array, newTarget:Point):void
		{
			// If we've already claimed another target, need to remove that claim
			var possibleClaim:Array = claimedGrid[_nextTarget.x][_nextTarget.y] as Array;
			var maybeIndex:int = possibleClaim.indexOf(this);
			if (maybeIndex != -1)
				possibleClaim.splice(maybeIndex, 1);
			// Now change our target and claim the new spot
			_nextTarget = newTarget;
			claimedGrid[_nextTarget.x][_nextTarget.y].push(this);
		}
		
		
		public function beAttacked(attacker:GridPiece):void
		{
			if (_dying)
				return;
			this.health -= attacker.attackPower;
			if (health <= 0) {
				_dying = true;
				_sprite.flicker(0.3);
				_type = 0;
			}
		}
		
		public override function update():void
		{
			
			if (_dying && !_sprite.flickering) {
				this.kill();
				PlayState.instance.removeFromGame(this);
			}
			if (pathSpeed == 0) {
				// Make sure we're locked in to our current position
				var actualPoint:Point = PlayState.instance.toActualCoordinates(PlayState.instance.toGridCoordinates(x, y));
				x = actualPoint.x;
				y = actualPoint.y;
				this.velocity = new FlxPoint();
				
			}
			super.update();
			_sprite.update();
		}
		
		public function pauseSounds():void
		{
			
		}
		
		public function resumeSounds():void
		{
			
		}
		
		// need to always set our velocities to 0 before doing anything else 
		public override function preUpdate():void
		{
			super.preUpdate();
			_sprite.preUpdate();
		}

		public override function postUpdate():void
		{
			super.postUpdate();
			_sprite.postUpdate();
		}
		
		
		// Only putting this here in case we want accelerator panels or something else that complicates things
		// Actually, this value is used as the primary factor when figuring out the turn order. 
		// Inanimate objects should totally have a really high move speed so they can go first and update 
		// the grid properly
		protected var _moveSpeed:Number;
		public function get moveSpeed():Number
		{
			return _moveSpeed;
		}
		
		public function GridPiece(X:Number=0, Y:Number=0)
		{
			super(X, Y, Globals.CELL_SIZE, Globals.CELL_SIZE);
			_nextTarget = PlayState.instance.toGridCoordinates(x, y);
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			this.health = 1;
			_attackPower = 0;
		}
		
		public function roundStart():void
		{
			// place stuff you want to happen before the start of the round here. 
			_pushed = false;
		}
		
		public function checkStopped(claimedGrid:Array):Boolean
		{
			return true;
		}
		
		public function dependsOnPiece(otherPiece:GridPiece, currentGrid:Array):Boolean
		{
			return false;
		}
		
		// Explicitly called before sorting happens so people can change directions before the 
		// dependency checks
		public function preTurn(currentGrid:Array):void
		{
			
		}
		
		public function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			// For the base piece, just go ahead and return our current position
			_nextTarget = PlayState.instance.toGridCoordinates(x, y);
			claimedGrid[_nextTarget.x][_nextTarget.y].push(this);
		}
		
		public function postTurn(currentGrid:Array):void
		{
			// Mostly here for the monsters
		}
		
		// Function primarily used by the blocker to figure out what can be pushed where
		public function canEnterPoint(point:Point, currentOccupiers:Array, claimedOccupiers:Array):Boolean
		{
			// Default behavior (for walls and such) is to not be moved, so return false
			return false;
		}
			
		public function isTurnReady():Boolean
		{
			return this.pathSpeed == 0;
		}
		
		// Used to determine when the round is over. 
		public function isRoundDone():Boolean
		{
			return _stopped;
		}
		
	}
}