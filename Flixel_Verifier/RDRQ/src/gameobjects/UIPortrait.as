package gameobjects
{
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	
	import utils.*;
	
	public class UIPortrait extends FlxGroup
	{
		private var _height:Number;
		
		private var _portrait:FlxSprite;
		private var _portraitFrame:FlxSprite;
		private var _portraitBack:FlxSprite;
		
		// Some sprites for our health representation
		private var _healthFrame:FlxSprite;
		private var _healthBack:FlxSprite;
		private var _healthBar:FlxSprite;
		
		private var _selected:Boolean = false;
		private var _health:Number;
		
		private var _queen:RiotQueen;
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if (value == _selected)
				return;
			
			if (value)
				_portraitFrame.makeGraphic(_portraitFrame.width, _portraitFrame.height, 0xffffffff);
			else
				_portraitFrame.makeGraphic(_portraitFrame.width, _portraitFrame.height, 0xff000000);
			_selected = value;
		}
		
		public function updateHealth():void
		{
			if (_queen.health == _health)
				return;
			
			var healthPercentage:Number = _queen.health/_queen.maxHealth;
			if (_queen.health > 0) {
				_healthBar.makeGraphic(_healthBack.width*healthPercentage, _healthBack.height, 0xffff0000);
				_healthBar.visible = true;
			}
			else {
				_healthBar.visible = false;
			}
			_health = _queen.health;
		}
		
		public function get height():Number
		{
			return _height;
		}
		
		public function UIPortrait(portraitY:Number, queen:RiotQueen)
		{
			super();	
			_queen = queen;	
			
			_portrait = new FlxSprite(0, portraitY, queen.uiPortrait);
			// scale the portrait so it's the correct size
			var scaleX:Number = Globals.PORTRAIT_WIDTH/_portrait.width;
			var scaleY:Number = Globals.PORTRAIT_HEIGHT/_portrait.height;
			_portrait.origin = new FlxPoint();
			_portrait.scale = new FlxPoint(scaleX, scaleY);
			
			_portrait.x = (Globals.UI_START_X + FlxG.width)/2 - (_portrait.width*scaleX)/2;
			
			_portraitFrame = new FlxSprite(_portrait.x-2, _portrait.y-2);
			_portraitFrame.makeGraphic(Globals.PORTRAIT_WIDTH+4, Globals.PORTRAIT_HEIGHT+4, 0xff000000);
			
			_portraitBack = new FlxSprite(_portrait.x, _portrait.y);
			_portraitBack.makeGraphic(_portrait.width*scaleX, _portrait.height*scaleY, 0xff000000);
			
			_healthFrame = new FlxSprite(_portraitFrame.x, _portraitFrame.y+_portraitFrame.height);
			_healthFrame.makeGraphic(_portraitFrame.width, 10, 0xffffffff);
			
			_healthBack = new FlxSprite(_healthFrame.x+2, _healthFrame.y+2);
			_healthBack.makeGraphic(_healthFrame.width-4, _healthFrame.height-4, 0xff000000);
			
			_healthBar = new FlxSprite(_healthBack.x, _healthBack.y);
			_healthBar.makeGraphic(_healthBack.width, _healthBack.height, 0xffff0000);
			
			_health = _queen.health;
			
			
			_height = _portraitFrame.height + _healthFrame.height;
			
			this.add(_portraitFrame);
			this.add(_portraitBack);
			this.add(_portrait);
			this.add(_healthFrame);
			this.add(_healthBack);
			this.add(_healthBar);
		}
		
		public override function draw():void
		{
			this.selected = _queen.inControl;
			this.updateHealth();
			super.draw();
		}
	}
}