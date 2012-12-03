package utils
{
	import flash.utils.ByteArray;

	public class Level
	{
		// The Tile coordinates for our level editor tilemap 
		private static const WALL_X:uint = 0;
		
		private static const WALL_Y:uint = 0;
		private static const SOUTHEAST_BOUNCER_Y:uint = Globals.CELL_SIZE;
		private static const SOUTHWEST_BOUNCER_Y:uint = Globals.CELL_SIZE*2;
		private static const NORTHWEST_BOUNCER_Y:uint = Globals.CELL_SIZE*3;
		private static const NORTHEAST_BOUNCER_Y:uint = Globals.CELL_SIZE*4;
		private static const LOCK_Y:uint = Globals.CELL_SIZE*5;
		private static const PUSH_WALL_Y:uint = Globals.CELL_SIZE*6;
		
		private static const QUEEN_X:uint = Globals.CELL_SIZE;
		private static const JAMMER_Y:uint = 0;
		private static const BLOCKER_Y:uint = Globals.CELL_SIZE;
		private static const KEYMASTER_Y:uint = Globals.CELL_SIZE*2;
		private static const THROWER_Y:uint = Globals.CELL_SIZE*3;
		
		private static const MONSTER_X:uint = Globals.CELL_SIZE*2;
		private static const MONSTER_Y:uint = 0;
		private static const BOSS_Y:uint = Globals.CELL_SIZE;
		private static const SKATE_MONSTER_Y:uint = Globals.CELL_SIZE*2;
		
		// Levels are really simple, they only need a floor layer which is a tilemap csv ultimately
		// a mid-floor layer for stuff like accelerator strips or bouncers
		// and a top layer for players and walls and such 
		private var _floorLayer:Array;
		private var _midFloorLayer:Array;
		private var _topLayer:Array;
		private var _dialogueIndex:String = null;
		
		public function get tilemapCSV():String
		{
			return arrayToCSV(_floorLayer);
		}
		
		public function get midLayer():Array
		{
			return _midFloorLayer;
		}
		
		public function get topLayer():Array
		{
			return _topLayer;
		}
		
		public function get dialogueIndex():String
		{
			return _dialogueIndex;
		}
		
		public function Level(xml:Class)
		{
			if (null == xml)
				return;
			
			var rawData:ByteArray = new xml;
			var dataString:String = rawData.readUTFBytes(rawData.length);
			var xmlData:XML = new XML(dataString);
			
			var dataList:XMLList;
			var dataElement:XML;
			
			
			
			// We already know what the width and height are, so we're just going to 
			// plug 'em in 
			
			_floorLayer = [];
			_midFloorLayer = [];
			_topLayer = [];
			
			var i:int, j:int;
			for (i = 0; i < Globals.GRID_WIDTH; i++) { 
				var floorColumn:Array = [];	
				var midFloorColumn:Array = [];
				var topColumn:Array = [];
				for (j = 0; j < Globals.GRID_HEIGHT; j++) { 
					floorColumn.push(Globals.EMPTY_TYPE);
					midFloorColumn.push(Globals.EMPTY_TYPE);
					topColumn.push(Globals.EMPTY_TYPE);
				}
				_floorLayer.push(floorColumn);
				_midFloorLayer.push(midFloorColumn);
				_topLayer.push(topColumn);
			}
			
			// Let's make the floor tilemap now
			dataList = xmlData.floor.tile;
			for each(dataElement in dataList) {
				var tileX:int = dataElement.@x / Globals.CELL_SIZE;
				var tileY:int = dataElement.@y / Globals.CELL_SIZE;
				
				var tileIndex:int = dataElement.@tx / Globals.CELL_SIZE;
				if (tileX >= 0 && tileX < Globals.GRID_WIDTH && tileY >= 0 && tileY < Globals.GRID_HEIGHT)
					_floorLayer[tileX][tileY] = tileIndex;
			}
			
			// now let's make the mid layer
			dataList = xmlData.mid.tile;
			for each(dataElement in dataList) { 
				var tileX:int = dataElement.@x / Globals.CELL_SIZE;
				var tileY:int = dataElement.@y / Globals.CELL_SIZE;
				
				var type:uint = Globals.EMPTY_TYPE;
				if (dataElement.@tx == WALL_X) {
					if (dataElement.@ty == WALL_Y)
						type = Globals.WALL_TYPE;
					else if (dataElement.@ty == LOCK_Y)
						type = Globals.LOCK_TYPE;
					else if (dataElement.@ty == PUSH_WALL_Y)
						type = Globals.PUSH_WALL_TYPE;
					else if (dataElement.@ty == SOUTHEAST_BOUNCER_Y) 
						type = Globals.SOUTHEAST_BOUNCER_TYPE;
					else if (dataElement.@ty == SOUTHWEST_BOUNCER_Y)
						type = Globals.SOUTHWEST_BOUNCER_TYPE;
					else if (dataElement.@ty == NORTHWEST_BOUNCER_Y)
						type = Globals.NORTHWEST_BOUNCER_TYPE;
					else if (dataElement.@ty == NORTHEAST_BOUNCER_Y)
						type = Globals.NORTHEAST_BOUNCER_TYPE;
					
				}
				if (tileX >= 0 && tileX < Globals.GRID_WIDTH && tileY >= 0 && tileY < Globals.GRID_HEIGHT)
					_midFloorLayer[tileX][tileY] = type;
			}
			
			
			// Finally, make the top layer 
			dataList = xmlData.top.tile;
			for each(dataElement in dataList) {
				var tileX:int = dataElement.@x / Globals.CELL_SIZE;
				var tileY:int = dataElement.@y / Globals.CELL_SIZE;
				
				var type:uint = Globals.EMPTY_TYPE;
				if (dataElement.@tx == WALL_X) { 
					if (dataElement.@ty == WALL_Y)
						type = Globals.WALL_TYPE;
					else if (dataElement.@ty == LOCK_Y)
						type = Globals.LOCK_TYPE;
					else if (dataElement.@ty == PUSH_WALL_Y)
						type = Globals.PUSH_WALL_TYPE;
					else if (dataElement.@ty == SOUTHEAST_BOUNCER_Y) 
						type = Globals.SOUTHEAST_BOUNCER_TYPE;
					else if (dataElement.@ty == SOUTHWEST_BOUNCER_Y)
						type = Globals.SOUTHWEST_BOUNCER_TYPE;
					else if (dataElement.@ty == NORTHWEST_BOUNCER_Y)
						type = Globals.NORTHWEST_BOUNCER_TYPE;
					else if (dataElement.@ty == NORTHEAST_BOUNCER_Y)
						type = Globals.NORTHEAST_BOUNCER_TYPE;
				}
				else if(dataElement.@tx == QUEEN_X) {
					if (dataElement.@ty == JAMMER_Y) 
						type = Globals.JAMMER_TYPE;
					else if (dataElement.@ty == BLOCKER_Y)
						type = Globals.BLOCKER_TYPE;
					else if (dataElement.@ty == KEYMASTER_Y)
						type = Globals.KEYMASTER_TYPE;
					else if (dataElement.@ty == THROWER_Y) 
						type = Globals.THROWER_TYPE;
				}
				else if(dataElement.@tx == MONSTER_X) {
					if (dataElement.@ty == MONSTER_Y)
						type = Globals.MONSTER_TYPE;
					else if (dataElement.@ty == BOSS_Y) 
						type = Globals.BOSS_TYPE;
					else if (dataElement.@ty == SKATE_MONSTER_Y)
						type = Globals.SKATE_MONSTER_TYPE;
				}
				
				if (tileX >= 0 && tileX < Globals.GRID_WIDTH && tileY >= 0 && tileY < Globals.GRID_HEIGHT)
					_topLayer[tileX][tileY] = type;
			}
			
			dataList = xmlData.objects.intro;
			for each(dataElement in dataList) {
				_dialogueIndex = dataElement.@index;
			}
			
			
			
		}
		
		private static function arrayToCSV(array:Array):String 
		{
			var csv:String = "";
			// Scan through row by row
			for(var j:int = 0; j < array[0].length; j++) {
				for(var i:int = 0; i < array.length; i++) {
					csv += (array[i][j] as int).toString() + ((i < array.length-1) ? ",":"\n");
				}
			}
			return csv;
		}
	}
}