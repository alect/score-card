package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	public class MonsterJammer extends EnemyJammer
	{
		
		protected var _maybeTargets:Array = [];
		
		public function MonsterJammer(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite = new FlxSprite();
			_sprite.loadGraphic(ResourceManager.monsterSkate, true, true);
			_sprite.addAnimation("move-down", [0, 1], 2, true);
			_sprite.addAnimation("move-up", [0, 1], 2, true);
			_sprite.addAnimation("move-side", [0, 1], 2, true);
			_sprite.frame = 0;
			_type = GridPiece.ENEMY_TYPE;
			health = 1;
			_maxHealth = 1;
			
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			_attackPower = 1;
			
		}
		
		public override function beAttacked(attacker:GridPiece):void
		{
			// decrease my health and kill me if I die
			if (_dying)
				return;
			this.health -= attacker.attackPower;
			if (health <= 0) {
				_rollSound.stop();
				this._dying = true;
				_sprite.flicker(0.3);
			}
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if (_dying) {
				this.stop(claimedGrid);
				return;
			}
			
			
			if (!_stopped) {
				_maybeTargets = targetsNearby(currentGrid);
				if (_maybeTargets.length > 0) {
					// Attack all of the targets
					for each(var target:GridPiece in _maybeTargets) {
						target.beAttacked(this);
						if (target.x < this.x) 
							_sprite.facing = FlxObject.RIGHT;
						else
							_sprite.facing = FlxObject.LEFT;
					}
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
		
		public override function isRoundDone():Boolean
		{
			if (_dying) 
				return false;
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
		
		protected override function canEnter(claimer:GridPiece):Boolean
		{
			if (claimer == this)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.PLAYER_TYPE | GridPiece.ENEMY_TYPE)) != 0) {
				if ((claimer is Bouncer) && (claimer as Bouncer).canEnterBouncer(gridPos))
					return true;
				else 
					return false;
			}
			
			return true;
		}
		
		public override function canEnterHere(claimer:GridPiece):Boolean
		{
			if (claimer == this)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.PLAYER_TYPE | GridPiece.ENEMY_TYPE)) != 0) {
				if ((claimer is Bouncer) && (claimer as Bouncer).canEnterBouncer(gridPos))
					return true;
				else 
					return false;
			}
			
			return true;
		}
		
		public override function update():void
		{
			super.update();
			if (_dying && !_sprite.flickering){
				this.kill();
				PlayState.instance.removeFromGame(this);
			}
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
						_sprite.facing = FlxObject.RIGHT;
						break;
					case FlxObject.DOWN:
						_sprite.play("move-down");
						break;
					case FlxObject.LEFT:
						_sprite.play("move-side");
						_sprite.facing = FlxObject.LEFT;
						break;
					
				}
			}
			else {
				switch(_rollDir) {
					case FlxObject.UP:
						_sprite.frame = 0;
						break;
					case FlxObject.RIGHT:
						_sprite.frame = 0;
						_sprite.facing = FlxObject.RIGHT;
						break;
					case FlxObject.DOWN:
						_sprite.frame = 0;
						break;
					case FlxObject.LEFT:
						_sprite.frame = 0;
						_sprite.facing = FlxObject.LEFT;
						break;
					
				}
			}
			
			_sprite.x = this.x;
			_sprite.y = this.y;
			_sprite.draw();
			
		}
	}
}