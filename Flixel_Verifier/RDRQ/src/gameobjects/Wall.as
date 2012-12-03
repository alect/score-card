package gameobjects
{
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	
	public class Wall extends GridPiece
	{
		
		
		public function Wall(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite = new FlxSprite(0, 0, ResourceManager.wallArt);
			// Walls should always update first
			_type = GridPiece.WALL_TYPE;
			health = 1;
		}
		
		
		
		public override function draw():void
		{
			_sprite.x = this.x;
			_sprite.y = this.y;
			_sprite.draw();
		}
	}
}