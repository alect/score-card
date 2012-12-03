package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	public class EnemyJammer extends Jammer
	{
		private var _attackedThisTurn:Boolean;
		
		public function EnemyJammer(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite = new FlxSprite();
			_sprite.loadGraphic(ResourceManager.bossArt, true, true);
			_sprite.addAnimation("move-down", [0, 1], 6, true);
			_sprite.addAnimation("move-up", [2, 3], 6, true);
			_sprite.addAnimation("move-side", [4, 5], 6, true);
			_sprite.frame = 0;
			_type = GridPiece.ENEMY_TYPE | GridPiece.BOSS_TYPE;
			health = 3;
			_maxHealth = 5;
			
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			
			_attackPower = 1;
			
			_name = "Boss";
			_portrait = ResourceManager.bossPortraitArt;
			
				
			
		}
		
		public override function beAttacked(attacker:GridPiece):void
		{
			this.health -= attacker.attackPower;
			_sprite.color = 0xffff0000;
			_hurtSound.play(true);
			if (health <= 0) {
				PlayState.instance.wonGame();
			}
		}
		
		protected override function moveIfPossible(nextPoint:Point, claimedGrid:Array, currentGrid:Array):void
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
				// Let's see if our next target features another riot queen who's headed in this direction
				if (!_attackedThisTurn) {
					var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
					var onNextTile:Array = currentGrid[nextPoint.x][nextPoint.y] as Array;
					for each (var tileItem:GridPiece in onNextTile) {
						if ((tileItem.type & GridPiece.PLAYER_TYPE) != 0 && tileItem.nextTarget.equals(gridPos)) {
							tileItem.beAttacked(this);
							_whipSmack.play(true);
						}
					}
				}
				
				claimedGrid[nextPoint.x][nextPoint.y].push(this);
			}
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			_attackedThisTurn = false;
			// Here's where we kill/attack monsters.
			// Go through everything we might be standing on and see if it's a monster that needs to die
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var onCurrentTile:Array = currentGrid[gridPos.x][gridPos.y] as Array;
			for each (var tileItem:GridPiece in onCurrentTile) {
				if ((tileItem.type & GridPiece.PLAYER_TYPE) != 0 && !_stopped) {
					tileItem.beAttacked(this);
					_attackedThisTurn = true;
					_whipSmack.play(true);
				}
			}
			
			
			
			if (_stopped) {
				this.stop(claimedGrid);
				// First grab our current grid position
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
		
		public override function roundStart():void
		{
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			// Need to choose a direction here deterministically and stick with it.
			var dirFound:Boolean = false;
			var currentDir:uint = _rollDir;
			while (!dirFound) {
				if (PlayState.instance.bossCanMoveHere(getNextPoint(gridPos, currentDir), this, currentDir)) 
					dirFound = true;
				else {
					currentDir = nextDirection(currentDir);
					if (currentDir == _rollDir) 
						dirFound = true;
				}
			}
			
			_rollDir = currentDir;
			
			
			super.roundStart();
			
		}
		
		public function getNextPoint(gridPos:Point, dir:uint):Point
		{
			var newPoint:Point = gridPos;
			switch(dir) { 
				case FlxObject.UP:
					newPoint = new Point(gridPos.x, gridPos.y-1);
					break;
				case FlxObject.RIGHT:
					newPoint = new Point(gridPos.x+1, gridPos.y);
					break;
				case FlxObject.DOWN:
					newPoint = new Point(gridPos.x, gridPos.y+1);
					break;
				case FlxObject.LEFT:
					newPoint = new Point(gridPos.x-1, gridPos.y);
					break;
			}	
			return newPoint;
		}
		
		private function nextDirection(dir:uint):uint
		{
			switch(dir) {
				case FlxObject.UP:
					return FlxObject.RIGHT;
				case FlxObject.RIGHT:
					return FlxObject.DOWN;
				case FlxObject.DOWN:
					return FlxObject.LEFT;
				case FlxObject.LEFT:
					return FlxObject.UP;
				default:
					return FlxObject.UP;
			}
		}
		
		protected override function canEnter(claimer:GridPiece):Boolean
		{
			if (claimer == this)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.ENEMY_TYPE)) != 0) {
				if ((claimer is Bouncer) && (claimer as Bouncer).canEnterBouncer(gridPos))
					return true;
				else 
					return false;
			}
			else if ((claimer.type & (GridPiece.PLAYER_TYPE)) != 0 && _stopped)
				return false;
			else if (claimer is Blocker)
				return false;
			
			return true;
		}
		
		public function canEnterHere(claimer:GridPiece):Boolean
		{
			if (claimer == this)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.ENEMY_TYPE)) != 0) {
				if ((claimer is Bouncer) && (claimer as Bouncer).canEnterBouncer(gridPos))
					return true;
				else 
					return false;
			}
			else if ((claimer.type & (GridPiece.PLAYER_TYPE)) != 0 && _stopped)
				return false;
			else if (claimer is Blocker)
				return false;
			
			return true;
		}
	}
}