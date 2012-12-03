package utils
{
	import flash.geom.Point;
	
	import org.flixel.FlxSave;

	public class Globals
	{
		// The max level index we've unlocked.
		public static var unlockLevelIndex:int = 0;
		public static function updateUnlockIndex(currentLevelIndex:int):void
		{
			if (currentLevelIndex+1 > unlockLevelIndex) {
				unlockLevelIndex = currentLevelIndex+1;
				if (isSaving) {
					saveGame.data.levels = unlockLevelIndex;
					saveGame.flush();
				}
			}	
		}
		
		private static var saveGame:FlxSave;
		private static var isSaving:Boolean = false;
		public static function createOrRetrieveSave():void
		{
			saveGame = new FlxSave();
			if (saveGame.bind("RDRQ_Save")) {
				if (saveGame.data.levels == null)
					saveGame.data.levels = 0;
				else 
					unlockLevelIndex = saveGame.data.levels;
				isSaving = true;
			}
		}
		
		public static const CELL_SIZE:int = 32;
		
		public static const GRID_WIDTH:int = 12;
		public static const GRID_HEIGHT:int = 10;
		
		public static const UI_START_X:Number = Globals.CELL_SIZE*Globals.GRID_WIDTH;
		public static const PORTRAIT_HEIGHT:Number = 48;
		public static const PORTRAIT_WIDTH:Number = 48;
		
		public static const JAMMER_NORMAL_SPEED:Number = 200;
		// Things that are stopped should be the first to go as they need to claim their spot first
		public static const STOPPED_SPEED:Number = Number.MAX_VALUE;
		
		
		// Types used for the type arrays defined by levels 
		private static var nextType:uint = 0;
		public static const EMPTY_TYPE:uint = nextType++;
		public static const WALL_TYPE:uint = nextType++;
		public static const PUSH_WALL_TYPE:uint = nextType++;
		public static const JAMMER_TYPE:uint = nextType++;
		public static const BLOCKER_TYPE:uint = nextType++;
		public static const KEYMASTER_TYPE:uint = nextType++;
		public static const THROWER_TYPE:uint = nextType++;
		public static const MONSTER_TYPE:uint = nextType++;
		public static const BOSS_TYPE:uint = nextType++;
		public static const SKATE_MONSTER_TYPE:uint = nextType++;
		
		public static const SOUTHEAST_BOUNCER_TYPE:uint = nextType++;
		public static const SOUTHWEST_BOUNCER_TYPE:uint = nextType++;
		public static const NORTHWEST_BOUNCER_TYPE:uint = nextType++;
		public static const NORTHEAST_BOUNCER_TYPE:uint = nextType++;
		public static const LOCK_TYPE:uint = nextType++;
		
		public static const BG_TINT:uint = 0x80eba65c;
		
		public static const LEVEL_END_TINT:uint = 0xb4eba65c;
		
		public static function inGrid(point:Point):Boolean 
		{
			return (point.x >= 0 && point.x < GRID_WIDTH && point.y >= 0 && point.y < GRID_HEIGHT);
		}
		
	}
}