package gameobjects
{
	import flash.geom.Point;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	import gamestates.PlayState;
	
	public class Bouncer extends GridPiece
	{
		public static const SOUTHEAST:uint = 0;
		public static const SOUTHWEST:uint = 1;
		public static const NORTHWEST:uint = 2;
		public static const NORTHEAST:uint = 3;
		
		public static const NOBOUNCE:uint = 22;
		
		private var _dir:uint;
		public function Bouncer(X:Number=0, Y:Number=0, direction:uint=SOUTHEAST)
		{
			super(X, Y);
			
			_sprite = new FlxSprite();
			//_sprite.loadRotatedGraphic(ResourceManager.bouncerArt, 4);
			_sprite.loadGraphic(ResourceManager.bouncerArt, true);
			_sprite.addAnimation("shine", [0, 1, 2, 3, 0], 12, false);
			
			_dir = direction;
			_type = GridPiece.WALL_TYPE;
		}
		
		public override function draw():void
		{
			_sprite.x = x;
			_sprite.y = y;
			_sprite.angle = 90*_dir;
			_sprite.draw();
		}
		
		public function canBounce(otherDir:uint):Boolean
		{
			switch(_dir) { 
				case SOUTHEAST:
					return (otherDir == FlxObject.LEFT) || (otherDir == FlxObject.UP);
				case SOUTHWEST:
					return otherDir == FlxObject.RIGHT || otherDir == FlxObject.UP;
				case NORTHWEST:
					return otherDir == FlxObject.RIGHT || otherDir == FlxObject.DOWN;
				case NORTHEAST:
					return otherDir == FlxObject.LEFT || otherDir == FlxObject.DOWN;
			}
			return false;
		}
		
		public function canEnterBouncer(fromPoint:Point):Boolean
		{
			// Figures out whether we can enter a bouncer from a certain direction
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			switch(_dir) {
				case SOUTHEAST:
					return (fromPoint.x == gridPos.x+1 && fromPoint.y == gridPos.y) || (fromPoint.x == gridPos.x && fromPoint.y == gridPos.y+1);
				case SOUTHWEST:
					return (fromPoint.x == gridPos.x-1 && fromPoint.y == gridPos.y) || (fromPoint.x == gridPos.x && fromPoint.y == gridPos.y+1);
				case NORTHWEST:
					return (fromPoint.x == gridPos.x-1 && fromPoint.y == gridPos.y) || (fromPoint.x == gridPos.x && fromPoint.y == gridPos.y-1);
				case NORTHEAST:
					return (fromPoint.x == gridPos.x+1 && fromPoint.y == gridPos.y) || (fromPoint.x == gridPos.x && fromPoint.y == gridPos.y-1);		
			}
			return false;
		}
		
		public function bounce():void
		{
			_sprite.play("shine");
		}
		
		public function getBounceDirection(otherDir:uint):uint
		{
			switch(_dir) {
				case SOUTHEAST:
					if(otherDir == FlxObject.LEFT)
						return FlxObject.DOWN;
					else if(otherDir == FlxObject.UP)
						return FlxObject.RIGHT;
					break;
				case SOUTHWEST:
					if(otherDir == FlxObject.RIGHT) 
						return FlxObject.DOWN;
					else if(otherDir == FlxObject.UP)
						return FlxObject.LEFT;
					break;
				case NORTHWEST:
					if(otherDir == FlxObject.RIGHT)
						return FlxObject.UP;
					else if(otherDir == FlxObject.DOWN)
						return FlxObject.LEFT;
					break;
				case NORTHEAST:
					if(otherDir == FlxObject.LEFT) 
						return FlxObject.UP;
					else if(otherDir == FlxObject.DOWN)
						return FlxObject.RIGHT;
					break;
			}
			return NOBOUNCE;
		}
	}
}