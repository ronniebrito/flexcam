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
	import flash.display.Sprite;
	
	/**
	 * The SwitchButton class represents a button that keeps is value once pressed.
	 * 
	 * @author Joa Ebert
	 */	
	public class SwitchButton extends Button
	{
		override protected function build(): void
		{
			super.build();
			
			graphics.lineStyle( 2, 0x333333 );
			graphics.beginFill( 0x555555 );
			graphics.drawRoundRect( 0, 0, tileSize, tileSize, tileSize * .25, tileSize * .25 );
			graphics.endFill();

			var trigger: Sprite = new Sprite;
			
			addChild( trigger );
			
			this.trigger = trigger;
		}
		
		override protected function updateButtonGraphics(): void
		{
			with ( Sprite( trigger ).graphics )
			{
				clear();
				beginFill( ( parameter.getValueNormalized() == 1 ) ? 0xbbbbbb : 0x999999 );
				drawRoundRect( 4, 4, tileSize - 8, tileSize - 8, ( tileSize - 8 ) * .25, ( tileSize - 8 ) * .25 );
				endFill();
			}
		}
		
		override protected function mouseDown():void
		{
			invertParameter();
		}
		
		override public function toString(): String
		{
			return '[SwitchButton]';
		}
	}
}