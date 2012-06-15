package de.popforge.gui
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	
	public class Label extends Sprite
	{
		private var length: int;
		
		private var textfield: TextField;
		
		public function Label( text: String, length: int = 0 )
		{
			this.length = length;
			
			init();
			
			this.text = text;
		}
		
		public function set text( value: String ): void
		{
			textfield.text = value;
			
			update();
		}
		
		public function get text(): String
		{
			return textfield.text;
		}
		
		private function init(): void
		{
			textfield = new TextField();
			textfield.x = 4;
			textfield.y = 0;
			textfield.textColor = 0x999999;
			textfield.autoSize = TextFieldAutoSize.LEFT;
			textfield.selectable = false;
			textfield.defaultTextFormat = new TextFormat( 'verdana', 9, 0xcccccc, true );
			addChild( textfield );
		}
		
		private function update(): void
		{
			var w: int;
			
			if( length == 0 )
				w = textfield.textWidth;
			else
				w = length;
			
			graphics.clear();
			graphics.lineStyle( 2, 0x333333 );
			graphics.beginFill( 0x555555 );
			graphics.drawRoundRect( 0, 0, w + 16, 16, 16, 16 );
			graphics.endFill();
		}
	}
}