package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSound;
	
	import utils.*;
	
	public class KeyMaster extends Jammer
	{
		protected var _lockSound:FlxSound;
		
		public function KeyMaster(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite.color = 0xffffff00;
			
			health = 2;
			_maxHealth = 2;
			_name = "Kiera";
			_sprite.loadGraphic(ResourceManager.keymasterArt, true, true);
			_portrait = ResourceManager.keymasterPortraitArt;
			_uiPortrait = ResourceManager.keymasterUIPortraitArt;
			_queenIndex = 3;
			_lockSound = new FlxSound();
			_lockSound.loadEmbedded(ResourceManager.lockSound);
			_loseText = "I'm done, guys! Let my cat know I never loved her!";
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var onCurrentTile:Array = currentGrid[gridPos.x][gridPos.y] as Array;
			for each (var tileItem:GridPiece in onCurrentTile) {
				if ((tileItem.type & GridPiece.ENEMY_TYPE) != 0 && !_stopped && tileItem.health > 0) {
					tileItem.beAttacked(this);
					if (!(tileItem is EnemyJammer))
						this.beAttacked(tileItem);
					_whipSmack.play(true);
				}
				if (tileItem is Lock && !_stopped) {
					tileItem.beAttacked(this);
					_lockSound.play();
				}
			}
			
			if (_stopped) {
				this.stop(claimedGrid);
				return;
			}
			// First grab out current grid position
			
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
		
		protected override function canEnter(claimer:GridPiece):Boolean
		{
			if (claimer == this)
				return true;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			if ((claimer.type & (GridPiece.WALL_TYPE | GridPiece.PLAYER_TYPE)) != 0) {
				if ((claimer is Bouncer) && (claimer as Bouncer).canEnterBouncer(gridPos))
					return true;
				else if(claimer is Lock)
					return true;
				else 
					return false;
			}
			else if ((claimer.type & (GridPiece.ENEMY_TYPE)) != 0 && _stopped)
				return false;
			return true;
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
	}
}