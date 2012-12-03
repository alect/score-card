package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	
	import utils.*;
	
	public class Thrower extends RiotQueen
	{
		
		public function Thrower(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			
			_sprite.loadGraphic(ResourceManager.throwerArt, true, true);
			_sprite.addAnimation("throw-down", [9, 0], 4);
			_sprite.addAnimation("throw-side", [10, 1], 4);
			_sprite.addAnimation("throw-up", [11, 2], 4);
			health = 1;
			_maxHealth = 1;
			_name = "Marge";
			
			_portrait = ResourceManager.throwerPortraitArt;
			_uiPortrait = ResourceManager.throwerUIPortraitArt;
			
			_queenIndex = 4;
			_type = GridPiece.PLAYER_TYPE;
			_loseText = "Whoa, man! This is getting too heavy for me.";
		}
		
		public override function roundStart():void
		{
			super.roundStart();
			PlayState.instance.addAbove(new Molotov(x, y, _rollDir));
			// play an animation based on our roll dir
			switch(_rollDir) {
				case FlxObject.UP:
					_sprite.play("throw-up");
					break;
				case FlxObject.RIGHT:
					_sprite.facing = FlxObject.LEFT;
					_sprite.play("throw-side");
					break;
				case FlxObject.DOWN:
					_sprite.play("throw-down");
					break;
				case FlxObject.LEFT:
					_sprite.facing = FlxObject.RIGHT;
					_sprite.play("throw-side");
					break;
				
			}
			
		}
		
		public override function canEnterPoint(point:Point, currentOccupiers:Array, claimedOccupiers:Array):Boolean
		{
			// Determines if we can move into a given point
			return canMoveWithClaimers(claimedOccupiers) && canMoveWithCurrent(point, currentOccupiers);
		}
		
		protected function canMoveWithClaimers(claimers:Array):Boolean
		{
			for each(var claimer:GridPiece in claimers) {
				if (!canEnter(claimer))
					return false;
			}
			return true;
		}
		
		protected function canMoveWithCurrent(nextPoint:Point, current:Array):Boolean
		{
			// Want to see if there's a person in front of us who's hasn't claimed a different spot yet
			// (topological cycle)
			for each (var claimer:GridPiece in current) {
				if (claimer.nextTarget.equals(nextPoint) && !canEnter(claimer))
					return false;
			}
			return true;
		}
		
		protected function canEnter(claimer:GridPiece):Boolean
		{
			if (claimer == this)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.PLAYER_TYPE)) != 0) {
				if ((claimer is Bouncer) && (claimer as Bouncer).canEnterBouncer(gridPos))
					return true;
				else 
					return false;
			}
			return true;
		}
		
		public override function draw():void {
			_sprite.x = this.x;
			_sprite.y = this.y;
			
			if (_sprite.finished) {
			
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
			}
			
			_sprite.draw();
			
		}
		
	}
}