/**
 * Copyright(C) 2007 Andre Michelle and Joa Ebert
 *
 * PopForge is an ActionScript3 code sandbox developed by Andre Michelle and Joa Ebert
 * http://sandbox.popforge.de
 * 
 * This file is part of PopforgeAS3Audio.
 * 
 * PopforgeAS3Audio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * PopforgeAS3Audio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
package de.popforge.fui.controls
{
	import de.popforge.fui.core.FuiComponent;
	import de.popforge.fui.core.IFormatterBindable;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import de.popforge.utils.Formatter;
	import de.popforge.utils.Formatter;

	/**
	 * The Label class is a simple text rendering component.
	 * 
	 * @author Joa Ebert
	 */
	public class Label extends FuiComponent implements IFormatterBindable
	{
		protected var textField: TextField;
		protected var formatter: Formatter;
		
		public function connect( formatter: Formatter ): void
		{
			releaseFormatter();
			
			this.formatter = formatter;
			
			textField.text = formatter.getValue();
			 
			formatter.addChangedCallbacks( onFormatterChanged );
		}
		
		public function disconnect(): void
		{
			releaseFormatter();
		}
		
		protected function releaseFormatter(): void
		{
			if ( formatter != null )
			{
				formatter.removeChangedCallbacks( onFormatterChanged );
			}
			
			formatter = null;
		}
		
		protected function onFormatterChanged( formatter: Formatter, oldValue: String, newValue: String ): void
		{
			textField.text = newValue;
		}
		
		override protected function build(): void
		{
			graphics.beginFill( 0x555555 );
			graphics.drawRect( 0, 0, targetWidth, targetHeight );
			graphics.endFill();
			
			textField = new TextField();
			
			textField.selectable = false;
			textField.wordWrap = true;
			textField.multiline = true;
			
			textField.x = 4;
			textField.width = targetWidth - 8;
			textField.height = targetHeight;
			
			var align: String = String( _tag.@align );
			
			if ( align == null || align == '' )
				align = TextFormatAlign.CENTER;
				
			var format: TextFormat = new TextFormat( 'verdana', 9, 0x999999, true );
			format.align = align;
			
			textField.defaultTextFormat = format;

			addChild( textField );
					
			maskComponent();
		}
		
		override public function dispose(): void
		{
			super.dispose();
			
			if ( contains( textField ) )
				removeChild( textField );
			
			textField = null;
		}

		override public function toString(): String
		{
			return '[Label]';
		}
	}
}