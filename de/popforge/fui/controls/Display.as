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
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	/**
	 * The Display class is a base for FuiComponents visualizing data.
	 * 
	 * <p><b>Skin developer information:</b> By default a BitmapData object is created and
	 * add to the display list if <code>build()</code> is called.</p>
	 * 
	 * @author Joa Ebert
	 */
	internal class Display extends FuiComponent
	{
		protected var screen: BitmapData;
		
		override protected function build(): void
		{
			screen = new BitmapData( targetWidth, targetHeight, false, 0x333333 );
			addChild( new Bitmap( screen ) );
		}
		
		override public function toString(): String
		{
			return '[Display]';
		}
		
		protected function drawLineV( x: uint, y0: uint, y1: uint, color: uint ): void
		{
			if ( y1 > y0 )
				while ( --y1 >= y0 )
					screen.setPixel( x, y1, color );
			else if ( y1 < y0 )
				while( ++y1 <= y0 )
					screen.setPixel( x, y1, color );
		}
	}
}