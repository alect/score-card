package
{
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import org.flixel.FlxU;
	
	/**
	 * A utility class for using the FlxReplay system to record and verify high score runs. 
	 * Intended to be run locally (as the recorder) and on a remote server (as the verifier).
	 * 
	 * @author Alec Thomson
	 */
	public class FlxScoreVerifier
	{
		
		protected static const SCORE_SERVER_HOST:String = "ec2-23-20-243-120.compute-1.amazonaws.com";
		protected static const SCORE_SERVER_PORT:int = 50000;
		
		// the number of empty frames to append at the end of the recording to allow 
		// the scores to be sent properly before ending the replay
		protected static const FRAME_BUFFER_SIZE:uint = 22; 
		
		protected static var _gameName:String = "TestVerifier";
		protected static var _userName:String = "bitdiddle";
		protected static var _userToken:String = "blah";
		
		protected static var _initialized:Boolean = false;
		protected static var _recording:Boolean = false;
		protected static var _verifying:Boolean = false; 
		
		protected static var _recordedLog:String; 
		protected static var _scoreName:String; 
		protected static var _scoreValue:uint;
		
		protected static var _scorePostSocket:Socket;
		
		protected static var _localScorePort:int;
		
		protected static var _isRecordingState:Boolean = false;
		protected static var _recordState:String; 
		protected static var _recordStateParamName:String;
		protected static var _recordStateParamValue:String;
		
		
		// For pooling multiple scores into a single log 
		protected static var _pooledScores:Array = [];
		
		public static function init(startRecording:Boolean=true):void
		{
			
			// First check to see if we're verifying or not 
			try
			{
				var parameters:Object = FlxG.stage.loaderInfo.parameters;
			}
			catch (e:Error)
			{
				throw new Error("FlxKongregate: No access to FlxG.stage - only call this once your game has access to the display list");
				return;
			}
			
			_initialized = true;
			
			if (!_recording && !_verifying && parameters.verifying && parameters.localScorePort && parameters.replayLog) { 
				// If we're given a specific state to replay, start by switching to that state
				var replayState:FlxState = null;
				if (parameters.replayState)  { 
					replayState = new (FlxU.getClass(parameters.replayState))(); 
					// If we have a specific parameter for the replay state, set that 
					if (parameters.stateParamName && parameters.stateParamValue)
						replayState[parameters.stateParamName] = parameters.stateParamValue;
				}
				
				_localScorePort = int(parameters.localScorePort);
				verifyScore(decodeURIComponent(parameters.replayLog), replayState);
				var socket:Socket = new Socket();
				socket.addEventListener(Event.CONNECT, sayHello);
				socket.connect("localhost", _localScorePort);
			}
			else if (startRecording) { 
				startRecordingScore();	
			}
		}
		
		public static function initAtState(paramName:String=null, paramValue:String=null):void
		{
			if (!_recording && !_verifying) {
				_isRecordingState = true; 
				_recordState = FlxU.getClassName(FlxG.state);
				_recordStateParamName = paramName; 
				_recordStateParamValue = paramValue;
				startRecordingScore(false);
			}
			else if (_recording) {
				FlxG.state[_recordStateParamName] = _recordStateParamValue;
			}
			
		}
		
		protected static function startRecordingScore(standardMode:Boolean=true):void
		{
			if (!_recording && !_verifying) {
				_pooledScores = [];
				FlxG.recordReplay(standardMode);
				_recording = true;
			}
		}
		
		protected static function verifyScore(scoreLog:String, replayState:FlxState):void
		{
			if (!_recording && !_verifying) {
				_pooledScores = [];
				FlxG.loadReplay(scoreLog, replayState, null, 0, replayDone);
				_verifying = true;
			}
		}
		
		/**
		 * Add a score to our batch of scores for this recording or verification
		 * Actually posted or verified when the flushScore function is called. 
		 */
		public static function appendScore(scoreName:String, scoreValue:uint):void
		{
			if (_recording || _verifying)
				_pooledScores.push("<Score name=\"" + scoreName + "\" value=\"" + scoreValue.toString() + "\"/>\n");
		}
		
		public static function flushScores():void
		{
			// This function serves two purposes. When running the score recorder, it 
			// will take a snapshot of the current recording and send that log along with the 
			// pooled scores to the score server. 
			
			// When verifying a score on the server, it will officially post the scores, marking them
			// as verified. 
			if (_recording) { 
				
				var recordedLog:String = FlxG.stopRecording(FRAME_BUFFER_SIZE); 
				
				Security.allowDomain(SCORE_SERVER_HOST + ":" + SCORE_SERVER_PORT.toString());
				var socket:Socket = new Socket();
				socket.addEventListener(Event.CONNECT, postRecordingFn(recordedLog)); 
				socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				socket.connect(SCORE_SERVER_HOST, SCORE_SERVER_PORT);
				
				_recording = false;
			}
			else if (_verifying) {
				var verifySocket:Socket = new Socket();
				verifySocket.addEventListener(Event.CONNECT, postVerificationFn()); 
				verifySocket.connect("localhost", _localScorePort);
			}
		}
		
		
		public static function postScore(scoreName:String, scoreValue:uint):void
		{	
			// Post a single score immediately 
			appendScore(scoreName, scoreValue);
			flushScores();
		}
		
		protected static function replayDone():void	
		{
			var socket:Socket = new Socket();
			socket.addEventListener(Event.CONNECT, postReplayEnd);
			socket.connect("localhost", _localScorePort);
		}
		
		protected static function postRecordingFn(recordedLog:String):Function
		{
			return function(event:Event):void { 
				var message:String = "<ScorePosting>\n"
					+ "<Game id=\"" + _gameName + "\"/>\n"
					+ "<User name=\"" + _userName + "\" token=\"" + _userToken + "\"/>\n";
				if (_isRecordingState) { 
					message += "<State name=\"" + _recordState + "\"";
					if (_recordStateParamName != null && _recordStateParamValue != null) 
						message += " paramName=\"" + _recordStateParamName + "\" paramValue=\"" + _recordStateParamValue + "\"";
					message += "/>\n";
				}
				for each (var claimedScore:String in _pooledScores) {
					message += claimedScore;
				}
				message += "<Log>\n" 
					+ recordedLog
					+ "</Log>\n"
					+ "</ScorePosting>";
				var socket:Socket = event.target as Socket; 
				socket.writeUTFBytes(message);
				socket.flush();
				socket.close();
			};
		}
		
		protected static function postVerificationFn():Function
		{
			return function(event:Event):void {
				var message:String = "<ScoreVerification>\n";
				for each (var verifiedScore:String in _pooledScores) { 
					message += verifiedScore;
				}
				message += "</ScoreVerification>";
				var socket:Socket = event.target as Socket;
				socket.writeUTFBytes(message);
				socket.flush();
				socket.close();
			};
		}
		
		protected static function postReplayEnd(event:Event):void
		{
			var socket:Socket = event.target as Socket;
			socket.writeUTFBytes("<ReplayEnd/>");
			socket.flush();
			socket.close();
		}
		
		protected static function sayHello(event:Event):void
		{
			var socket:Socket = event.target as Socket;
			socket.writeUTFBytes("<Hello/>");
			socket.flush();
			socket.close();
		}
		
		protected static function onSecurityError(event:Event):void
		{
			throw new Error("Security Error: " + event.toString());
		}
		
	}
}