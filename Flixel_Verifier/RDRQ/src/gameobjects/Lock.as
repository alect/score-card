package gameobjects
{
	import utils.*;
	import gamestates.PlayState;
	public class Lock extends Wall
	{
		public function Lock(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			_sprite.loadGraphic(ResourceManager.doorArt);
		}
		
		public override function beAttacked(attacker:GridPiece):void
		{
			if (attacker is Molotov)
				return;
			this._dying = true;
			_sprite.flicker(0.3);
		}
		
	}
}