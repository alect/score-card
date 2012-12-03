package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSound;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	public class Jammer extends RiotQueen
	{
		private static var nextIndex:int = 0;
		public var _myIndex:int;
		
		protected var _whipSmack:FlxSound;
		
		public function Jammer(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite.loadGraphic(ResourceManager.jammerArt, true, true);
			_sprite.addAnimation("move-down", [0, 1], 2, true);
			_sprite.addAnimation("move-up", [2, 3], 2, true);
			_sprite.addAnimation("move-side", [4, 5, 6, 7], 3, true);
			_sprite.frame = 0;
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			_myIndex = nextIndex++;
			_whipSmack = new FlxSound();
			_whipSmack.loadEmbedded(ResourceManager.whipSound);
			_attackPower = 1;
			
			health = 2;
			_maxHealth = 2;
			_name = "Ada";
			_portrait = ResourceManager.jammerPortraitArt;
			_uiPortrait = ResourceManager.jammerPortraitArt;
			_queenIndex = 0;
			_loseText = "Ouch! I think that's too much for me!";
			
		}
		
		public override function roundStart():void 
		{
			super.roundStart();
			_stopped = false;
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			_rollSound.play();
		}
		
		public override function isTurnReady():Boolean 
		{
			return this.pathSpeed == 0;	
		}
		
		public override function isRoundDone():Boolean
		{
			return _stopped;
		}
		
		public override function dependsOnPiece(otherPiece:GridPiece, currentGrid:Array):Boolean
		{
			if (otherPiece == this)
				return false;
			if (_stopped)
				return false;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var nextPoint:Point = gridPos;
			switch(this._rollDir) {
				case FlxObject.UP:
					nextPoint = new Point(gridPos.x, gridPos.y-1);
					break;
				case FlxObject.RIGHT:
					nextPoint = new Point(gridPos.x+1, gridPos.y);
					break;
				case FlxObject.DOWN:
					nextPoint = new Point(gridPos.x, gridPos.y+1);
					break;
				case FlxObject.LEFT:
					nextPoint = new Point(gridPos.x-1, gridPos.y);
			}
			if (nextPoint.y < 0 || nextPoint.x < 0 || nextPoint.x >= Globals.GRID_WIDTH || nextPoint.y >= Globals.GRID_HEIGHT)
				return false;
			var possibleClaimers:Array = currentGrid[nextPoint.x][nextPoint.y] as Array;
			
			return possibleClaimers.indexOf(otherPiece) != -1;
		}
		
		protected function stop(claimedGrid:Array):void
		{
			//if(!_stopped)
			//	_stopSound.play(true);
			_stopped = true;
			_rollSound.stop();
			// A small trick to make the animation stop on its current frame
			_sprite.frame = _sprite.frame;
			this._nextTarget = PlayState.instance.toGridCoordinates(x, y);
			claimedGrid[_nextTarget.x][_nextTarget.y].push(this);
		}
		
		protected function moveIfPossible(nextPoint:Point, claimedGrid:Array, currentGrid:Array):void
		{
			// We're stopped if we reached the end of the grid or an obstacle 
			if (nextPoint.y < 0 || nextPoint.x < 0 || nextPoint.x >= Globals.GRID_WIDTH || nextPoint.y >= Globals.GRID_HEIGHT)
				this.stop(claimedGrid);
				// Otherwise, search through the things that claimed the space we want 
				// and see if any of them would stop us from moving there
			else if (!this.canEnterPoint(nextPoint, currentGrid[nextPoint.x][nextPoint.y], claimedGrid[nextPoint.x][nextPoint.y]))
				this.stop(claimedGrid);
				// Otherwise we're good and should keep on moving 
			else {
				_nextTarget = nextPoint;
				
				// HACK HACK HACK
				// VERY special case to make the boss work 
				var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
				var onNextTile:Array = currentGrid[nextPoint.x][nextPoint.y] as Array;
				for each (var tileItem:GridPiece in onNextTile) {
					if (tileItem is EnemyJammer) {
						tileItem.beAttacked(this);
						_whipSmack.play(true);
					}
				}
				
				claimedGrid[nextPoint.x][nextPoint.y].push(this);
			}
		}
		
		private function canMove(nextPoint:Point, claimedGrid:Array):Boolean
		{
			if (nextPoint.y < 0 || nextPoint.x < 0 || nextPoint.x >= Globals.GRID_WIDTH || nextPoint.y >= Globals.GRID_HEIGHT)
				return false;
				// Otherwise, search through the things that claimed the space we want 
				// and see if any of them would stop us from moving there
			else if (!canMoveWithClaimers(claimedGrid[nextPoint.x][nextPoint.y]))
				return false;
			return true;
		}
		
		public override function checkStopped(claimedGrid:Array):Boolean
		{
			if (_stopped)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var nextPoint:Point = gridPos;
			switch(this._rollDir) {
				case FlxObject.UP:
					nextPoint = new Point(gridPos.x, gridPos.y-1);
					break;
				case FlxObject.RIGHT:
					nextPoint = new Point(gridPos.x+1, gridPos.y);
					break;
				case FlxObject.DOWN:
					nextPoint = new Point(gridPos.x, gridPos.y+1);
					break;
				case FlxObject.LEFT:
					nextPoint = new Point(gridPos.x-1, gridPos.y);
			}
			return !canMove(nextPoint, claimedGrid);
		}
		
		public override function preTurn(currentGrid:Array):void
		{
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var onCurrentTile:Array = currentGrid[gridPos.x][gridPos.y] as Array;
			for each (var tileItem:GridPiece in onCurrentTile) {
				if (tileItem is Bouncer) { 
					if ((tileItem as Bouncer).getBounceDirection(_rollDir) != Bouncer.NOBOUNCE) {
						_rollDir = (tileItem as Bouncer).getBounceDirection(_rollDir);
						(tileItem as Bouncer).bounce();
					}
				}
			}
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			// Here's where we kill/attack monsters.
			// Go through everything we might be standing on and see if it's a monster that needs to die
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var onCurrentTile:Array = currentGrid[gridPos.x][gridPos.y] as Array;
			for each (var tileItem:GridPiece in onCurrentTile) {
				if ( (tileItem.type & GridPiece.ENEMY_TYPE) != 0 && !_stopped) {
					tileItem.beAttacked(this);
					_whipSmack.play(true);
				}
			}
			
			
			
			if (_stopped) {
				this.stop(claimedGrid);
			// First grab out current grid position
				return;
			}
			
			switch(this._rollDir) {
				case FlxObject.UP:
					moveIfPossible(new Point(gridPos.x, gridPos.y-1), claimedGrid, currentGrid);
					break;
				case FlxObject.RIGHT:
					moveIfPossible(new Point(gridPos.x+1, gridPos.y), claimedGrid, currentGrid);
					break;
				case FlxObject.DOWN:
					moveIfPossible(new Point(gridPos.x, gridPos.y+1), claimedGrid, currentGrid);
					break;
				case FlxObject.LEFT:
					moveIfPossible(new Point(gridPos.x-1, gridPos.y), claimedGrid, currentGrid);
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
			else if ((claimer.type & (GridPiece.ENEMY_TYPE)) != 0 && _stopped)
				return false;

			return true;
		}
		
		public override function draw():void
		{
			if (!_stopped) {
				switch(_rollDir) {
					case FlxObject.UP:
						_sprite.play("move-up");
						break;
					case FlxObject.RIGHT:
						_sprite.play("move-side");
						_sprite.facing = FlxObject.LEFT;
						break;
					case FlxObject.DOWN:
						_sprite.play("move-down");
						break;
					case FlxObject.LEFT:
						_sprite.play("move-side");
						_sprite.facing = FlxObject.RIGHT;
						break;
					
				}
			}
			else {
				switch(_rollDir) {
					case FlxObject.UP:
						_sprite.frame = 2;
						break;
					case FlxObject.RIGHT:
						_sprite.frame = 4;
						_sprite.facing = FlxObject.LEFT;
						break;
					case FlxObject.DOWN:
						_sprite.frame = 0;
						break;
					case FlxObject.LEFT:
						_sprite.frame = 4;
						_sprite.facing = FlxObject.RIGHT;
						break;
					
				}
			}
			
			_sprite.x = this.x;
			_sprite.y = this.y;
			_sprite.draw();
			
		}
		
	}
}