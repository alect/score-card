package gameobjects
{
	
	import utils.*;
	import flash.geom.Point;
	import gamestates.PlayState;
	
	public class PushWall extends Wall
	{
		public function PushWall(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			
			_sprite.loadGraphic(ResourceManager.pushwallArt);
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
				else
					return false;
			}
			return true;
		}
	}
}