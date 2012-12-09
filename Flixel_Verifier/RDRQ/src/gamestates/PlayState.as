package gamestates
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import gameobjects.Blocker;
	import gameobjects.Bouncer;
	import gameobjects.EnemyJammer;
	import gameobjects.GridPiece;
	import gameobjects.Jammer;
	import gameobjects.KeyMaster;
	import gameobjects.Lock;
	import gameobjects.Monster;
	import gameobjects.MonsterJammer;
	import gameobjects.PushWall;
	import gameobjects.RiotQueen;
	import gameobjects.Thrower;
	import gameobjects.UIPortrait;
	import gameobjects.Wall;
	
	import mx.core.UIComponentDescriptor;
	
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPath;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSound;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxTilemap;
	
	import utils.*;
	import utils.DialogueWindow;
	
	public class PlayState extends FlxState
	{
		private static const MOVE_STATE:uint = 0;
		private static const RUN_STATE:uint = 1;
		private static const DIALOGUE_STATE:uint = 2;
		private static const PAUSE_STATE:uint = 3;
		private static const WIN_STATE:uint = 4;
		private static const LOSE_STATE:uint = 5;
		private static const MENU_STATE:uint = 6;
		private static const WIN_END_STATE:uint = 7;
		
		private var _currentState:uint = MOVE_STATE;
		private var _lastState:uint = MOVE_STATE;
		
		
		private var _dialogue:DialogueWindow;
		
		// The background
		private var _floorBG:FlxSprite;
		
		
		private var _inanimates:FlxGroup;
		private var _enemies:FlxGroup;
		private var _players:FlxGroup;
		private var _abovePlayers:FlxGroup;
		
		// The portraits used to keep track of the riot queens
		// stats like health and such
		private var _portraits:FlxGroup;
		private var _portraitList:Array = [];
		
		
		// The current make-up of the board. Can be used for a topological sort
		private var _currentGrid:Array = [];
		// When we're adding objects, they have to go in an appropriate render group as well as the
		// grid pieces array	
		// The all important list of grid pieces 
		private var _gridPieces:Array = [];
		// Also keep an array of riot queens just for safety
		private var _riotQueens:Array = [];
		
		// The pieces to be removed at the end of the update
		private var _piecesToRemove:Array = [];
		
		
		// Relevant for how we move
		private var _currentQueenIndex:int = 0;
			
		
		
		private var _roundsUsed:int = 0;
		private var _roundsIndicator:FlxText;
		
		// The tint used in the background for the win lose text
		private var _winLoseTint:FlxSprite;
		
		private var _winText:FlxText;
		private var _winStats:FlxText;
		private var _winNext:FlxText;
		
		private var _loseText:FlxText;
		private var _loseNext:FlxText;
		
		private var _undoButton:FlxButton;
		private var _resetButton:FlxButton;
		private var _menuButton:FlxButton;
		
		
		// The level variable that we can reload from whenever
		private var _currentLevel:Level;
		// An index into the array of levels in resourceManager
		public var _currentLevelIndex:int = 0;
		private var _currentMusicIndex:int = -1;
		
		
		// The victory sound
		private var _winSound:FlxSound;
		// The sad loss sound
		private var _loseSound:FlxSound;
		// The sound played when the round stops
		private var _roundStopSound:FlxSound;
		
		private var _playedIntroYet:Boolean = false;
		
		private static var _instance:PlayState;
		public static function get instance():PlayState
		{
			return _instance;
		}
		
		
		public function addInanimate(piece:GridPiece):void
		{
			_inanimates.add(piece);
			_gridPieces.push(piece);
		}
		
		public function addEnemy(piece:GridPiece):void
		{
			_enemies.add(piece);
			_gridPieces.push(piece);
		}
		
		public function addPlayer(piece:GridPiece):void
		{
			_players.add(piece);
			_gridPieces.push(piece);
			_riotQueens.push(piece);
		}
		
		public function addAbove(piece:GridPiece):void
		{
			_abovePlayers.add(piece);
			_gridPieces.push(piece);
		}
		
		public override function create():void
		{
			FlxScoreVerifier.initAtState("_currentLevelIndex", _currentLevelIndex.toString());
			
			FlxG.mouse.show();
			// At the very start, define our instance so the other classes have access to our public functions
			_instance = this;
			
			_floorBG = new FlxSprite(0, 0, ResourceManager.bgArt);
			this.add(_floorBG);
		
			
			// Make sure the inanimates are drawn first
			_inanimates = new FlxGroup();
			
			this.add(_inanimates);
			
			// Next draw the enemies
			_enemies = new FlxGroup();
			this.add(_enemies);
			
			// Finally, draw the players on top
			_players = new FlxGroup();
			this.add(_players);
			
			// Actually, draw stuff like the molotov cocktails on top
			_abovePlayers = new FlxGroup();
			this.add(_abovePlayers);
			
			var sidebarBG:FlxSprite = new FlxSprite(Globals.UI_START_X, 0, ResourceManager.sideBarArt);
			this.add(sidebarBG);
			
			_portraits = new FlxGroup();
			this.add(_portraits);
			
			
			
			// Initiate the UI
			initUI();
			
			_dialogue = new DialogueWindow(0, FlxG.height-96);
			_dialogue.x = 0;
			_dialogue.y = FlxG.height-_dialogue.height;
			_dialogue.visible = false;
			// Let's just insert the dialogue window right in here 
			this.add(_dialogue);
			
			// Now load the level 
			getCurrentLevel();
			loadFromLevel(_currentLevel);
			
		}
		
		private function initUI():void
		{
			_roundsUsed = 0;
			_roundsIndicator = new FlxText(Globals.CELL_SIZE*Globals.GRID_WIDTH, 5, FlxG.width-Globals.CELL_SIZE*Globals.GRID_WIDTH, "Rounds: " + _roundsUsed.toString());
			_roundsIndicator.setFormat("Graph35", 8, 0xffffffff, "center");
			this.add(_roundsIndicator);
			
			_winLoseTint = new FlxSprite();
			_winLoseTint.makeGraphic(Globals.CELL_SIZE*7, Globals.CELL_SIZE*4, Globals.LEVEL_END_TINT);
			_winLoseTint.x = Globals.GRID_WIDTH*Globals.CELL_SIZE/2 - _winLoseTint.width/2;
			_winLoseTint.y = FlxG.height/2 - _winLoseTint.height/2;
			_winLoseTint.visible = false;
			this.add(_winLoseTint);
			
			_winText = new FlxText(0, FlxG.height/3 + 15, Globals.CELL_SIZE*Globals.GRID_WIDTH, "RIOTOUS!");
			_winText.setFormat("Matchbox", 32, 0xffffffff, "center");
			_winText.visible = false;
			this.add(_winText);
			
			_winStats = new FlxText(0, _winText.y+_winText.height+10, Globals.CELL_SIZE*Globals.GRID_WIDTH, "Rounds: " + _roundsUsed.toString());
			_winStats.setFormat("Graph35", 8, 0xffffffff, "center");
			_winStats.visible = false;
			this.add(_winStats);
			
			_winNext = new FlxText(0, _winStats.y+_winStats.height+10, Globals.CELL_SIZE*Globals.GRID_WIDTH, "click or press enter for the next level");
			_winNext.setFormat("Graph35", 8, 0xffffffff, "center");
			_winNext.visible = false;
			this.add(_winNext);
			
			_loseText = new FlxText(0, FlxG.height/3 + 25, Globals.CELL_SIZE*Globals.GRID_WIDTH, "RINK RASH!");
			_loseText.setFormat("Matchbox", 32, 0xffffffff, "center");
			_loseText.visible = false;
			this.add(_loseText);
			
			_loseNext = new FlxText(0, _loseText.y+_loseText.height+10, Globals.CELL_SIZE*Globals.GRID_WIDTH, "click or press enter to restart level");
			_loseNext.setFormat("Graph35", 8, 0xffffffff, "center");
			_loseNext.visible = false;
			this.add(_loseNext);
			
			_undoButton = new FlxButton(Globals.UI_START_X, FlxG.height-50, null, function():void {undoMove();});
			_undoButton.loadGraphic(ResourceManager.undoButtonArt, true, false, 32, 32);
			_undoButton.x = Globals.UI_START_X;
			_undoButton.y = FlxG.height - _undoButton.height -5;
			_undoButton.visible = false;
			this.add(_undoButton);
			
			_resetButton = new FlxButton(0, 0, null, function():void {ResourceManager.playClick(); loadFromLevel(_currentLevel);});
			_resetButton.loadGraphic(ResourceManager.resetButtonArt, true, false, 32, 32);
			_resetButton.x = _undoButton.x+_undoButton.width;
			_resetButton.y = FlxG.height - _resetButton.height - 5;
			this.add(_resetButton);
			
			_menuButton = new FlxButton(0, 0, null, function():void {returnToMenu();});
			_menuButton.loadGraphic(ResourceManager.menuButtonArt, true, false, 32, 32);
			_menuButton.x = _resetButton.x+_resetButton.width;
			_menuButton.y = FlxG.height - _menuButton.height - 5;
			this.add(_menuButton);
			
			
			_winSound = new FlxSound();
			_winSound.loadEmbedded(ResourceManager.winRiff);
			
			_loseSound = new FlxSound();
			_loseSound.loadEmbedded(ResourceManager.loseRiff);
			
			_roundStopSound = new FlxSound();
			_roundStopSound.loadEmbedded(ResourceManager.stopSound);
			
		}
		
		public function initPortraits():void
		{
			// Now load the portraits
			var portraitY:Number = _roundsIndicator.y+_roundsIndicator.height+5;
			for each (var queen:RiotQueen in _riotQueens) {
				var portrait:UIPortrait = new UIPortrait(portraitY, queen);
				_portraits.add(portrait);
				_portraitList.push(portrait);
				portraitY += portrait.height;
			}
		
		}
		
		public function getCurrentLevel():void
		{
			_currentLevel = new Level(ResourceManager.levelList[_currentLevelIndex]);
		}
		
		public function loadFromLevel(level:Level):void
		{
			clearLevel();
			// First load the floor map
			//_floorBG = new FlxTilemap();
			//_floorBG.loadMap(level.tilemapCSV, ResourceManager.floorMap, 0, 0, FlxTilemap.OFF, 0, 0, 5);
			//this.add(_floorBG);
			// Now load up the top layer 
			var i:int, j:int;
			for (i = 0; i < Globals.GRID_WIDTH; i++) { 
				for (j = 0; j < Globals.GRID_HEIGHT; j++) {
					switch(level.topLayer[i][j]) {
						case Globals.WALL_TYPE:
							this.addInanimate(new Wall(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.LOCK_TYPE:
							this.addInanimate(new Lock(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.PUSH_WALL_TYPE:
							this.addInanimate(new PushWall(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.JAMMER_TYPE:
							this.addPlayer(new Jammer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.BLOCKER_TYPE:
							this.addPlayer(new Blocker(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.KEYMASTER_TYPE:
							this.addPlayer(new KeyMaster(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.THROWER_TYPE:
							this.addPlayer(new Thrower(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.MONSTER_TYPE:
							this.addEnemy(new Monster(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.BOSS_TYPE:
							this.addEnemy(new EnemyJammer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.SKATE_MONSTER_TYPE:
							this.addEnemy(new MonsterJammer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.SOUTHEAST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.SOUTHEAST));
							break;
						case Globals.SOUTHWEST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.SOUTHWEST));
							break;
						case Globals.NORTHWEST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.NORTHWEST));
							break;
						case Globals.NORTHEAST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.NORTHEAST));
							break;
					}
					switch(level.midLayer[i][j]) {
						case Globals.WALL_TYPE:
							this.addInanimate(new Wall(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.LOCK_TYPE:
							this.addInanimate(new Lock(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.PUSH_WALL_TYPE:
							this.addInanimate(new PushWall(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.JAMMER_TYPE:
							this.addPlayer(new Jammer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.BLOCKER_TYPE:
							this.addPlayer(new Blocker(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.KEYMASTER_TYPE:
							this.addPlayer(new KeyMaster(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.THROWER_TYPE:
							this.addPlayer(new Thrower(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.MONSTER_TYPE:
							this.addEnemy(new Monster(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE));
							break;
						case Globals.SOUTHEAST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.SOUTHEAST));
							break;
						case Globals.SOUTHWEST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.SOUTHWEST));
							break;
						case Globals.NORTHWEST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.NORTHWEST));
							break;
						case Globals.NORTHEAST_BOUNCER_TYPE:
							this.addInanimate(new Bouncer(_floorBG.x+i*Globals.CELL_SIZE, _floorBG.y+j*Globals.CELL_SIZE, Bouncer.NORTHEAST));
							break;
					}
				}
			}
			
			// Make sure the queens are sorted properly
			function queenSort(a:RiotQueen, b:RiotQueen):int
			{
				if(a.queenIndex < b.queenIndex)
					return -1;
				else if(a.queenIndex > b.queenIndex)
					return 1;
				else
					return 0;
			}
			_riotQueens.sort(queenSort);
			
			initPortraits();
			
			startMoves();
			
			if (level.dialogueIndex != null && !_playedIntroYet) {
				this.dialoguePause(DialogueSequences.dialogueMap[level.dialogueIndex].slice());
				_playedIntroYet = true;
			}
			
			var _musicIndex:int = (ResourceManager.bgMusic.length*_currentLevelIndex)/ResourceManager.levelList.length;
			if (_musicIndex != _currentMusicIndex)
				FlxG.playMusic(ResourceManager.bgMusic[_musicIndex]);
			else 
				FlxG.music.play();
			_currentMusicIndex = _musicIndex;
			
		}
		
		// Clears this level 
		private function clearLevel():void
		{
			_winSound.stop();
			_loseSound.stop();
			
			_inanimates.clear();
			_enemies.clear();
			_players.clear();
			_abovePlayers.clear();
			
			_portraits.clear();
			// Gotta remove our floor map too 
			//this.remove(_floorBG);
			
			_riotQueens = [];
			_portraitList = [];
			_gridPieces = [];
			
			
			// Resetting the score
			_roundsUsed = 0;
			_roundsIndicator.text = "Rounds Used: " + _roundsUsed.toString();
			
			_winLoseTint.visible = false;
			_winText.visible = false;
			_winStats.visible = false;
			_winNext.visible = false;
			_loseText.visible = false;
			_loseNext.visible = false;
		}
		
		private function returnToMenu():void
		{
			FlxG.music.stop();
			FlxG.music = null;
			ResourceManager.playClick();
			_currentState = MENU_STATE;
			FlxG.switchState(new LevelSelectState());
		}
		
		private function undoMove():void
		{
			
			if (_currentState != MOVE_STATE || _currentQueenIndex <= 0)
				return;
			ResourceManager.playClick();
			var currentQueen:RiotQueen = _riotQueens[_currentQueenIndex] as RiotQueen;
			currentQueen.inControl = false;
			currentQueen.chosenMove = false;
			_currentQueenIndex--;
			currentQueen = _riotQueens[_currentQueenIndex] as RiotQueen;
			currentQueen.inControl = true;
			if (_currentQueenIndex == 0)
				_undoButton.visible = false;
		}
		
		private function startMoves():void
		{
			this.constructCurrentGrid();
			_currentQueenIndex = 0; 
			var currentQueen:RiotQueen = _riotQueens[_currentQueenIndex] as RiotQueen;
			currentQueen.inControl = true;
			_currentState = MOVE_STATE;
		}
		
		private function startRun():void
		{
			for each (var piece:GridPiece in _gridPieces) {
				piece.roundStart();
			}
			_undoButton.visible = false;
			_roundsUsed++;
			_roundsIndicator.text = "Rounds: " + _roundsUsed.toString();
			_currentState = RUN_STATE;
		}
		
		private function winLevel():void
		{
			FlxG.music.pause();
			// Send the win stats to Kongregate
			//FlxKongregate.submitStats("LevelCompleted-" + _currentLevelIndex.toString(), _roundsUsed);
			//FlxScoreVerifier.postScore("LevelCompleted-" + _currentLevelIndex.toString(), _roundsUsed);
			FlxScoreVerifier.appendScore("LevelCompleted-" + _currentLevelIndex.toString(), _roundsUsed);
			FlxScoreVerifier.appendScore("LevelScore-" + _currentLevelIndex.toString(), _roundsUsed);
			FlxScoreVerifier.flushScores();
			
			
			// Should play a victory sound and reveal the win text along with some stats
			_winSound.play(true);
			_winLoseTint.visible = true;
			_winText.visible = true;
			_winStats.text = "Rounds Used: " + _roundsUsed.toString();
			_winStats.visible = true;
			_winNext.visible = true;
		
			// Finally, switch to the win state
			_currentState = WIN_STATE;
			// And save if we can.
			Globals.updateUnlockIndex(_currentLevelIndex);
		}
		
		private function loseLevel():void
		{
			FlxG.music.pause();
			// TODO: Lose Sound
			_loseSound.play(true);
			_winLoseTint.visible = true;
			_loseText.visible = true;
			_loseNext.visible = true;
			
		}
		
		// The function used to sort the grid pieces for their turn order
		// First uses movement speed, then uses their type
		private function compareGridPieces(a:GridPiece, b:GridPiece):int 
		{
			if (a.moveSpeed > b.moveSpeed)
				return -1;
			else if (a.moveSpeed < b.moveSpeed) 
				return 1;
			else if (a.type < b.type) 
				return -1;
			else if (a.type > b.type) 
				return 1;
			else 
				return 0;
		}
		
		public override function draw():void
		{
			super.draw();
			// Now render the arrows for the riot queens
			if (_currentState != DIALOGUE_STATE) {
				for each (var queen:RiotQueen in _riotQueens) {
					queen.drawArrows();
				}
			}
		}
		
		// Here's where the fun begins
		public override function update():void
		{
			_resetButton.update();
			_menuButton.preUpdate();
			_menuButton.update();
			// A state exclusively for the dialogue box while the rest of the game is paused
			if (_currentState == DIALOGUE_STATE) {
				
				_dialogue.update();
			}
			else if (_currentState == WIN_END_STATE) {
				FlxG.switchState(new WinState());
			}
			else if (_currentState == MENU_STATE) {
				super.update();
			}
			else if (_currentState == WIN_STATE) {
				if(_currentState != WIN_STATE)
					return;
				
				if (FlxG.keys.justPressed("ENTER") || FlxG.mouse.justReleased()) {
					if (_currentLevelIndex+1 < ResourceManager.levelList.length) {
						_winSound.stop();
						_playedIntroYet = false;
						_currentLevelIndex++;
						this.getCurrentLevel();
						this.loadFromLevel(_currentLevel);
					}
					else
						trace("OUT OF LEVELS!");
				}
			}
			else if(_currentState == LOSE_STATE) { 
				if(_currentState != LOSE_STATE)
					return;
				
				if(FlxG.keys.justPressed("ENTER") || FlxG.mouse.justReleased()) {
					_loseSound.stop();
					this.loadFromLevel(_currentLevel);
				}
				
			}
			
			// The state where the player is making their moves 
			else if (_currentState == MOVE_STATE) {
				this.constructCurrentGrid();
				super.update();	
				// Get our current mover
				var currentQueen:RiotQueen = _riotQueens[_currentQueenIndex] as RiotQueen;
				if (!currentQueen.inControl) {
					_currentQueenIndex++;
					if (_currentQueenIndex >= 1) 
						_undoButton.visible = true;
					if (_currentQueenIndex >= _players.length)
						startRun();
					else {
						currentQueen = _riotQueens[_currentQueenIndex] as RiotQueen;
						currentQueen.inControl = true;
					}
						
				}
				
			}
			// The state where the round is being run
			else if (_currentState == RUN_STATE) {
				super.update();
				
				// Construct a new grid containing info about cells that have been "claimed"
				// by certain cells 
				_currentGrid = [];
				var claimedGrid:Array = [];
				// First, set up the grid with the appropriate dimensions
				var i:int;
				var j:int;
				for (i = 0; i < Globals.GRID_WIDTH; i++) {
					var column1:Array = [];
					var column2:Array = [];
					for (j = 0; j < Globals.GRID_HEIGHT; j++) {
						// Make it contain no objects for now
						column1.push([]);
						column2.push([]);
					}
					_currentGrid.push(column1);
					claimedGrid.push(column2);
				}
				
				// Now update the current grid while figuring out who is ready for a new turn 
				
				
				// Now that we've done that, let's see which of the pieces are ready for a new turn	
				var turnReady:Boolean = true;
				for each (var piece:GridPiece in _gridPieces) {
					if (!piece.isTurnReady()) {
						turnReady = false;
					}
					var gridPos:Point = this.toGridCoordinates(piece.x, piece.y);
					if (Globals.inGrid(gridPos))
						_currentGrid[gridPos.x][gridPos.y].push(piece);
				}
				
				
				
				if (turnReady) {
					// first do a pre turn 
					for each (var piece:GridPiece in _gridPieces) {
						piece.preTurn(_currentGrid);
					}
					
					// Sort the grid pieces using our special method. 
					this.topologicallySortPieces();
					// First, update all the info about them being stopped
					
					
					for each (var piece:GridPiece in _gridPieces) { 
						piece.performTurn(_currentGrid, claimedGrid);
					}
					for each (var piece:GridPiece in _gridPieces) {
						// Start moving them if necessary 
						performTurnMovement(piece);
					}
					// Now do a post turn so things like the monsters can figure out if they 
					// are ready for another turn
					for each (var piece:GridPiece in _gridPieces) {
						piece.postTurn(_currentGrid);
					}
				}	
					
				// Either way, at the very end of each update, let's check to see if the round is over
				var runningRound:Boolean = false;
				for each (var piece:GridPiece in _gridPieces) { 
					if (!piece.isRoundDone())
						runningRound = true;
				}
				if (!runningRound && _currentState == RUN_STATE) {	
					// Check if we won first 
					if (checkIfWon()) 
						this.winLevel();
					else {
						_roundStopSound.play(true);
						
						this.startMoves();
					}
				}
				
			}
			
			// Remove anything that needs removin'
			for each (var piece:GridPiece in _piecesToRemove) {
				var pieceIndex:int = _gridPieces.indexOf(piece);
				if (pieceIndex != -1) 
					_gridPieces.splice(pieceIndex, 1);
			}
			_piecesToRemove = [];
			
		}
		
		private function performTurnMovement(piece:GridPiece):void
		{
			var nextGridTarget:Point = piece.nextTarget;
			if (!nextGridTarget.equals(toGridCoordinates(piece.x, piece.y))) {
				var nextTarget:FlxPoint = new FlxPoint(_floorBG.x+nextGridTarget.x*Globals.CELL_SIZE + Globals.CELL_SIZE/2, _floorBG.y+nextGridTarget.y*Globals.CELL_SIZE + Globals.CELL_SIZE/2);
				piece.followPath(new FlxPath([nextTarget]), piece.moveSpeed);
			}
		}
		
		private function checkIfWon():Boolean
		{
			// Basically if we don't have any monsters on the field anymore, then we won. 
			var won:Boolean = true;
			for each (var piece:GridPiece in _gridPieces) {
				if ((piece.type & GridPiece.ENEMY_TYPE) != 0) 
					won = false;
			}
			return won;
		}
		
		public function riotQueenDefeated(queen:RiotQueen):void
		{
			_currentState = LOSE_STATE;
			
			
			// But start up a dialogue first
			var loseEvents:Array = [ DialogueUtils.changeLeftPortrait(new FlxSprite(0, 0, queen.portrait))
				, DialogueUtils.waitForAnimations
				, DialogueUtils.changeName(queen.name)
				, DialogueUtils.text(queen.loseText)
				, DialogueUtils.leftExit(500)
				, DialogueUtils.waitForAnimations];
			
			this.dialoguePause(loseEvents);
			
		}
		
		public function wonGame():void
		{
			// For when we beat the final boss. 
			_currentState = WIN_END_STATE;
			FlxG.music.stop();
			
			// Tell Kongregate we won the game. 
			//FlxKongregate.submitStats("GameCompleted", 1);
			//FlxKongregate.submitStats("LevelCompleted-20", _roundsUsed);
			
			// Start up the final dialogue. 
			this.dialoguePause(DialogueSequences.bossOutroEvents);
			
		}
		
		public function removeFromGame(item:GridPiece):void
		{
			_piecesToRemove.push(item);
		}
		
		public function toGridCoordinates(x:Number, y:Number):Point
		{
			var retPoint:Point = new Point(Math.floor((x+Globals.CELL_SIZE/2-_floorBG.x)/Globals.CELL_SIZE), Math.floor((y+Globals.CELL_SIZE/2-_floorBG.y)/Globals.CELL_SIZE));
			return retPoint;
		}
		
		public function toActualCoordinates(gridPos:Point):Point
		{
			return new Point(_floorBG.x+gridPos.x*Globals.CELL_SIZE, _floorBG.y + gridPos.y*Globals.CELL_SIZE);
		}
		
		public function constructCurrentGrid():void
		{
			_currentGrid = [];
			var i:int, j:int;
			for (i = 0; i < Globals.GRID_WIDTH; i++) {
				var column:Array = [];
				for (j = 0; j < Globals.GRID_HEIGHT; j++) {
					column.push([]);
				}
				_currentGrid.push(column);
			}
			
			for each (var piece:GridPiece in _gridPieces) {
				var gridPos:Point = this.toGridCoordinates(piece.x, piece.y);
				if (Globals.inGrid(gridPos))
					_currentGrid[gridPos.x][gridPos.y].push(piece);
			}
		}
		
		// A short hacky utility function that tells us whether a given riot queen can enter a certain 
		// point for her move. 
		public function queenCanMoveHere(point:Point, queen:RiotQueen, desiredDir:uint):Boolean
		{
			if (queen is Thrower)
				return true;
			var queenPos:Point = toGridCoordinates(queen.x, queen.y);
			if (!Globals.inGrid(point))
				return false;
			var itemsHere:Array = _currentGrid[point.x][point.y] as Array;
			for each (var piece:GridPiece in itemsHere) {
				if ((piece.type & GridPiece.WALL_TYPE) != 0) {
					if ((piece is Bouncer) && (piece as Bouncer).canBounce(desiredDir))
						continue;
					else if((piece is Lock) && (queen is KeyMaster))
						continue;
					else if((piece is PushWall) && (queen is Blocker))
						continue;
					else
						return false;
				}
				if ((piece.type & GridPiece.PLAYER_TYPE) != 0) {
					if (piece == queen || !(piece as RiotQueen).chosenMove) 
						continue;
					else if (piece.nextTarget.equals(point))
						return false;
				}
			}
			// Now go through each riot queen and see if they're trying to move into this spot
			for each (var otherQueen:RiotQueen in _riotQueens) {
				if (queen == otherQueen || !otherQueen.chosenMove) 
					continue;
				else if (otherQueen.nextTarget.equals(point))
					return false;
			}
			return true;
		}
		
		public function bossCanMoveHere(point:Point, boss:EnemyJammer, dir:uint, checkBouncer:Boolean = true):Boolean
		{
			// Check to see if the boss can enter a given point in the grid
			var gridPos:Point = toGridCoordinates(boss.x, boss.y);
			
			
			
			if (!Globals.inGrid(point))
				return false;
			var itemsHere:Array = _currentGrid[point.x][point.y] as Array;
			for each(var piece:GridPiece in itemsHere) {
				if (!boss.canEnterHere(piece)) 
					return false;
			}
			
			
			// Check to see if the boss is on a bouncer
			if (checkBouncer) {
				var underBoss:Array = _currentGrid[gridPos.x][gridPos.y] as Array;
				for each (var piece:GridPiece in underBoss) {
					if (piece is Bouncer) {
						var bounceDir:uint = (piece as Bouncer).getBounceDirection(dir);
						var bouncePoint:Point = boss.getNextPoint(gridPos, bounceDir);
						if (!bossCanMoveHere(bouncePoint, boss, bounceDir, false))
								return false;
					}
				}	
			}
			
			return true;
		}
		
		
		private function dialoguePause(dialogueEvents:Array):void
		{
			_lastState = _currentState;
			if (_lastState == RUN_STATE || LOSE_STATE) {
				for each (var piece:GridPiece in _gridPieces) {
					piece.pauseSounds();
				}
			}
			
			_currentState = DIALOGUE_STATE;
			_dialogue.visible = true;
			_dialogue.runEvents(dialogueEvents, afterText);
		}
		
		private function afterText():void
		{
			_dialogue.visible = false;
			_currentState = _lastState;
			if (_currentState == RUN_STATE) {
				for each (var piece:GridPiece in _gridPieces) {
					piece.resumeSounds();
				}
			}
			else if(_currentState == LOSE_STATE) { 
				loseLevel();
			}
		}
		public function topologicallySortPieces():void
		{
			/* Function that attempts to topologically sort all of the grid pieces so only the 
			pieces that have no dependencies go first 
			
			L ← Empty list that will contain the sorted nodes
			S ← Set of all nodes with no outgoing edges
			for each node n in S do
			visit(n) 
			function visit(node n)
			if n has not been visited yet then
			mark n as visited
			for each node m with an edge from m to n do
			visit(m)
			add n to L
			
			*/
			
			var graph:Dictionary = new Dictionary();
			var reverseGraph:Dictionary = new Dictionary();
			for each (var piece1:GridPiece in _gridPieces) {
				// Find the dependencies 
				for each (var piece2:GridPiece in _gridPieces) {
					if (piece1.dependsOnPiece(piece2, _currentGrid)) {
						if (graph[piece2] == null) {
							graph[piece2] = [piece1];
						} 
						else 
							graph[piece2].push(piece1)
						if (reverseGraph[piece1] == null) {
							reverseGraph[piece1] = [piece2];
						}
						else reverseGraph[piece1].push(piece2);
					}
				}
			}
			// now that we have a graph, let's continue 
			var _sortedPieces:Array = [];
			var noOutgoingEdges:Array = [];
			for each(var piece:GridPiece in _gridPieces) {
				if (graph[piece] == null)
					noOutgoingEdges.push(piece);
			}
			// Sort by our parameters
			noOutgoingEdges.sort(compareGridPieces);
			var visitedNodes:Dictionary = new Dictionary();
			function visit(n:GridPiece) {
				if (visitedNodes[n] == null) {
					visitedNodes[n] = true;
					// find the nodes with an edge to n 
					var nodes:Array;
					if (reverseGraph[n] == null)
						nodes = [];
					else 
						nodes = reverseGraph[n] as Array;
					nodes.sort(compareGridPieces);
					for each (var m:GridPiece in nodes) {
						visit(m);
					}
					_sortedPieces.push(n);
				}
			}
			for each(var n:GridPiece in noOutgoingEdges) { 
				visit(n);
			}
			
			// Now check to see if we miss any. If so, should totally scream about it
			for each (var piece:GridPiece in _gridPieces) {
				if (_sortedPieces.indexOf(piece) == -1)
					_sortedPieces.push(piece);
					//throw new Error("Missed a piece to put in the sorted list!");
			}
			_gridPieces = _sortedPieces;
			
		}
	}
	
	
}