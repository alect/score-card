package gameobjects
{
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSound;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	public class Molotov extends GridPiece
	{
		
		protected var _throwDir:uint = FlxObject.UP;
		protected var _justThrown:Boolean;
		protected var _leavingStart:Boolean;
		private static var _explosionSound:FlxSound = new FlxSound();
		private static var _catSound:FlxSound = new FlxSound();
		protected var _exploding:Boolean = false;
		
		
		_explosionSound.loadEmbedded(ResourceManager.explosionSound);
		_catSound.loadEmbedded(ResourceManager.catSound);
		
		public function Molotov(X:Number=0, Y:Number=0, throwDir:uint=FlxObject.UP)
		{
			super(X, Y);
			
			_throwDir = throwDir;
			
			_sprite = new FlxSprite();
			_sprite.loadGraphic(ResourceManager.molotovArt, true);
			
			_sprite.addAnimation("spin", [0, 1, 2], 22, true);
			_sprite.play("spin");
			_justThrown = true;
			_leavingStart = false;
			_attackPower = 1;
		}
		
		public override function roundStart():void
		{
			super.roundStart();
			_stopped = false;
			_moveSpeed = Globals.JAMMER_NORMAL_SPEED;
			_sprite.play("spin");
		}
		
		public override function draw():void
		{
			_sprite.x = x;
			_sprite.y = y;
			_sprite.draw();
		}
		
		public override function isTurnReady():Boolean
		{
			return this.pathSpeed == 0;
		}
		
		public override function isRoundDone():Boolean
		{
			return false;
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			if (_leavingStart)
				_leavingStart = false;
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			var exploded:Boolean = false;
			if (!Globals.inGrid(gridPos))
				exploded = true;
			else if (_justThrown) {
				_justThrown = false;
				_leavingStart = true;
			}
			else {
				var onCurrentTile:Array = currentGrid[gridPos.x][gridPos.y] as Array;
				for each (var tileItem:GridPiece in onCurrentTile) {
					if (tileItem != this) {
						tileItem.beAttacked(this);
						exploded = true;
					}
				}
			}
			
			if (exploded) {
				_explosionSound.play(true);
				// Play the cat sound if we explode off screen
				if (!Globals.inGrid(gridPos))
					_catSound.play(true);
				
				PlayState.instance.removeFromGame(this);
				_sprite.loadGraphic(ResourceManager.explosionArt, true);
				_exploding = true;
				_sprite.addAnimation("explode", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 15, false );
				_sprite.play("explode");
				this._nextTarget = gridPos;
				if (Globals.inGrid(_nextTarget))
					claimedGrid[_nextTarget.x][_nextTarget.y].push(this);
				return;
			}
			
			// Otherwise just move in our current direction. 
			var nextPoint:Point = gridPos;
			switch(this._throwDir) {
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
			
			_nextTarget = nextPoint;
			if (Globals.inGrid(_nextTarget))
				claimedGrid[nextPoint.x][nextPoint.y].push(this);
		}
		
		public override function canEnterPoint(point:Point, currentOccupiers:Array, claimedOccupiers:Array):Boolean
		{
			return !_exploding && !_justThrown && !_leavingStart;
		}
		
		public override function update():void
		{
			super.update();
			if(_exploding && _sprite.frame == 9)
			{
				this.kill();
			}
		}
	}
}