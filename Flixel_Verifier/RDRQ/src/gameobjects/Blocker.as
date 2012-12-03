package gameobjects
{
	
	import flash.geom.Point;
	
	import gamestates.PlayState;
	
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	/**
	 * Most of the blocker class should be 
	 */
	public class Blocker extends Jammer
	{
		
		private var _thingsPushed:Array;
		private var _oldTargets:Array;
		
		
		public function Blocker(X:Number=0, Y:Number=0)
		{
			super(X, Y);
			
			_type = GridPiece.PLAYER_TYPE | GridPiece.BLOCKER_TYPE;
			_sprite = new FlxSprite();
			_sprite.loadGraphic(ResourceManager.blockerArt, true, true);
			_sprite.addAnimation("move-down", [0, 1], 2, true);
			_sprite.addAnimation("move-up", [2, 3], 2, true);
			_sprite.addAnimation("move-side", [4, 5, 6, 7], 3, true);
			_sprite.frame = 0;
			
			
			health = 3;
			_maxHealth = 3;
			
			_name = "Marie";
			_portrait = ResourceManager.blockerPortraitArt;
			_uiPortrait = ResourceManager.blockerUIPortraitArt;
			_queenIndex = 1;
			_loseText = "Applesauce! I think I'm going to have to sit down, guys.";
		}
		
		public override function performTurn(currentGrid:Array, claimedGrid:Array):void
		{
			// Blockers don't kill monsters, so watch out
			var gridPos:Point = PlayState.instance.toGridCoordinates(x, y);
			
			
			if (_stopped) {
				this.stop(claimedGrid);
				return;
			}
			
			// The first thing a blocker should do is see if there is something in front of us
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
			// First, don't do anything if we're at an edge
			if (nextPoint.x < 0 || nextPoint.x >= Globals.GRID_WIDTH || nextPoint.y < 0 || nextPoint.y >= Globals.GRID_HEIGHT) {
				this.stop(claimedGrid);
				return;
			}
			
			// Now that we know our next point, let's find out if there's anything in front of us right 
			// now that we can push 
			// Should be able to push other players or enemies. 
			pushThings(nextPoint, currentGrid, claimedGrid);
			// Now that that's done, see if we can move into our next spot
			
			var currentOccupiers:Array = currentGrid[nextPoint.x][nextPoint.y] as Array;
			var claimedOccupiers:Array = claimedGrid[nextPoint.x][nextPoint.y] as Array;
			if (this.canEnterPoint(nextPoint, currentOccupiers, claimedOccupiers)) {
				_nextTarget = nextPoint;
				claimedGrid[nextPoint.x][nextPoint.y].push(this);
				// register the things as being pushed
				for each(var piece:GridPiece in _thingsPushed) {
					piece.pushed = true;
				}
			}
			else {
				// Going to have to revert the pushed people if we can't move ourselves
				for (var i:int = 0; i < _thingsPushed.length; i++) {
					var thing:GridPiece = _thingsPushed[i] as GridPiece;
					var oldTarget:Point = _oldTargets[i] as Point;
					thing.switchTarget(claimedGrid, oldTarget);
				}
				
				// Also going to have to stop
				this.stop(claimedGrid);
			}
			
			
		}
		
		private function pushThings(nextPoint:Point, currentGrid:Array, claimedGrid:Array):void
		{
			_thingsPushed = [];
			_oldTargets = [];
			if (nextPoint.x < 0 || nextPoint.x >= Globals.GRID_WIDTH || nextPoint.y < 0 || nextPoint.y >= Globals.GRID_HEIGHT)
				return;
			
			var pushDir:uint = _rollDir;
			var pushPoint:Point;
			
			// Now check to see if there are any bouncers on the point we're looking at 
			// since those will affect our push point
			var possibleBouncers:Array = currentGrid[nextPoint.x][nextPoint.y] as Array;
			var bouncer:Bouncer = null;
			for each (var maybeBouncer:GridPiece in possibleBouncers) {
				if (maybeBouncer is Bouncer) {
					bouncer = maybeBouncer as Bouncer;
					break;
				}
			}
			if (bouncer != null) {
				pushDir = bouncer.getBounceDirection(_rollDir);
				if (pushDir == Bouncer.NOBOUNCE)
					return;
				bouncer.bounce();
			}
			
			switch(pushDir) {
				case FlxObject.UP:
					pushPoint = new Point(nextPoint.x, nextPoint.y-1);
					break;
				case FlxObject.RIGHT:
					pushPoint = new Point(nextPoint.x+1, nextPoint.y);
					break;
				case FlxObject.DOWN:
					pushPoint = new Point(nextPoint.x, nextPoint.y+1);
					break;
				case FlxObject.LEFT:
					pushPoint = new Point(nextPoint.x-1, nextPoint.y);
					break;
				default:
					return;
			}
			
			if (pushPoint.x < 0 || pushPoint.x >= Globals.GRID_WIDTH || pushPoint.y < 0 || pushPoint.y >= Globals.GRID_HEIGHT)
				return;
			// Now let's look through our things to push 
			var thingsToPush:Array = currentGrid[nextPoint.x][nextPoint.y] as Array;
			for each (var thing:GridPiece in thingsToPush) {
				var currentOccupiers:Array = currentGrid[pushPoint.x][pushPoint.y] as Array;
				var claimedOccupiers:Array = claimedGrid[pushPoint.x][pushPoint.y] as Array;
				// See if it can be pushed
				if (canBePushed(thing) && thing.canEnterPoint(pushPoint, currentOccupiers, claimedOccupiers)) {
					_thingsPushed.push(thing);
					_oldTargets.push(thing.nextTarget);
					thing.switchTarget(claimedGrid, pushPoint);
				}
				
			}
		}
		
		private function canBePushed(thing:GridPiece):Boolean
		{
			return (thing.type & (GridPiece.PLAYER_TYPE | GridPiece.ENEMY_TYPE)) != 0 || thing is PushWall || thing is Molotov;
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