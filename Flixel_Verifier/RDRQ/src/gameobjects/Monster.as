package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import utils.*;

	public class Monster extends GridPiece
	{
		public function get dying():Boolean 
		{
			return _dying;
		}
		
		protected var _attackedThisRound:Boolean = false;
		
		protected var _maybeTargets:Array = [];
		public function Monster(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			
			_sprite = new FlxSprite(0, 0);
			_sprite.loadGraphic(ResourceManager.monsterArt, true, true);
			_sprite.addAnimation("attacking", [1, 2, 0], 10, false);
			_sprite.addAnimation("pushed", [3, 4, 5], 5, true);
			
			_type = GridPiece.ENEMY_TYPE;
			_attackPower = 1;
		}
		
		public override function draw():void
		{
			_sprite.x = this.x;
			_sprite.y = this.y;
			
			if(_pushed) {
				_sprite.play("pushed");
			}
			else if(_sprite.finished) {
				_sprite.frame = 0;
			}
			
			_sprite.draw();
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			_pushed = false;
			if (_dying) {
				super.performTurn(currentGrid, claimedGrid);
				return;
			}
			// Check to see if there are any riot queens next to us. If so, attack them
			if (!_attackedThisRound) { 
				_maybeTargets = targetsNearby(currentGrid);
				if (_maybeTargets.length > 0) {
					// Attack all of the targets
					for each(var target:GridPiece in _maybeTargets) {
						target.beAttacked(this);
						if (target.x < this.x) 
							_sprite.facing = FlxObject.LEFT;
						else
							_sprite.facing = FlxObject.RIGHT;
						_sprite.play("attacking", true);
					}
					_attackedThisRound = true;
				}
			}
			
			super.performTurn(currentGrid, claimedGrid);
		}
		
		public override function roundStart():void
		{
			_attackedThisRound = false;
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			super.roundStart();
		}
		
		public override function postTurn(currentGrid:Array):void
		{
			if (!_attackedThisRound) 
				_maybeTargets = targetsNearby(currentGrid);
		}
		
		public override function isRoundDone():Boolean
		{
			if (_dying)
				return false;
			
			if (_attackedThisRound) 
				return true;
			else if(_maybeTargets.length > 0) 
				return false;
			else 
				return super.isRoundDone();
		}
		
		protected function targetsNearby(currentGrid:Array):Array
		{
			var targets:Array = [];
			// Go through each of our neighbors
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var upNeighbor:Point = new Point(gridPos.x, gridPos.y-1);
			var rightNeighbor:Point = new Point(gridPos.x+1, gridPos.y);
			var downNeighbor:Point = new Point(gridPos.x, gridPos.y+1);
			var leftNeighbor:Point = new Point(gridPos.x-1, gridPos.y);
			
			if (Globals.inGrid(upNeighbor)) {
				for each (var piece:GridPiece in currentGrid[upNeighbor.x][upNeighbor.y]) {
					if (isTarget(piece))
						targets.push(piece);
				}
			}
			
			if (Globals.inGrid(rightNeighbor)) {
				for each (var piece:GridPiece in currentGrid[rightNeighbor.x][rightNeighbor.y]) {
					if (isTarget(piece))
						targets.push(piece);
				}
			}
			
			if (Globals.inGrid(downNeighbor)) {
				for each (var piece:GridPiece in currentGrid[downNeighbor.x][downNeighbor.y]) {
					if (isTarget(piece))
						targets.push(piece);
				}
			}
			
			if (Globals.inGrid(leftNeighbor)) {
				for each (var piece:GridPiece in currentGrid[leftNeighbor.x][leftNeighbor.y]) {
					if (isTarget(piece))
						targets.push(piece);
				}
			}
			
			return targets;
			
		}
		
		protected function isTarget(piece:GridPiece):Boolean 
		{
			return piece.stopped && (piece.type & GridPiece.PLAYER_TYPE) != 0;
		}
		
		
		public override function beAttacked(attacker:GridPiece):void
		{
			// decrease my health and kill me if I die
			if (_dying)
				return;
			this.health -= attacker.attackPower;
			if (health <= 0) {
				this._dying = true;
				_sprite.flicker(0.3);
			}
		}
		
		public override function update():void
		{
			super.update();
			if (_dying && !_sprite.flickering){
				this.kill();
				PlayState.instance.removeFromGame(this);
			}
		}
		
		public override function canEnterPoint(point:Point, currentOccupiers:Array, claimedOccupiers:Array):Boolean
		{
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
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.ENEMY_TYPE | GridPiece.PLAYER_TYPE)) != 0) {
				if (claimer is Bouncer && (claimer as Bouncer).canEnterBouncer(gridPos)) {
					return true;
				}
				else if (claimer is Jammer && !(claimer is Blocker))
					return true;
				else 
					return false;
			}
			return true;
		}
		
		
	}
}