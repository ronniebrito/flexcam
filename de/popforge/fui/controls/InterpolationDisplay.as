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
	import de.popforge.parameter.MappingIntLinear;
	import de.popforge.interpolation.Interpolation;
	import de.popforge.fui.core.IInterpolationBindable;
	
	/**
	 * The InterpolationDisplay class is a utility to render Interpolation objects.
	 * 
	 * @author Joa Ebert
	 */	
	public class InterpolationDisplay extends Display implements IInterpolationBindable
	{
		protected var screenMapping: MappingIntLinear;
		protected var interpolation: Interpolation;
		
		public function connect( interpolation: Interpolation ): void
		{
			releaseInterpolation();
			
			this.interpolation = interpolation;

			resetScreen();
			renderInterpolation();
						 
			interpolation.addChangedCallbacks( onInterpolationChanged );
		}
		
		public function disconnect(): void
		{
			releaseInterpolation();
		}
		
		protected function releaseInterpolation(): void
		{
			if ( interpolation != null )
			{
				interpolation.removeChangedCallbacks( onInterpolationChanged );
			}
			
			interpolation = null;
		}
		
		protected function onInterpolationChanged( interpolation: Interpolation ): void
		{
			resetScreen();
			renderInterpolation();
		}
		
		override protected function build(): void
		{
			super.build();
			
			screenMapping = new MappingIntLinear( targetHeight, 0 );
			
			resetScreen();
		}
		
		protected function resetScreen(): void
		{
			var x: uint = 0;
			var y: uint = 0;
			var maxX: uint = targetWidth - 1;
			var maxY: uint = targetHeight - 1;
			var centerX: uint = targetWidth >> 1;
			var centerY: uint = targetHeight >> 1;
			var leftX: uint = targetWidth >> 2;
			var rightX: uint = centerX + leftX;
			var topY: uint = targetHeight >> 2;
			var bottomY: uint = centerY + topY;
						
			screen.fillRect( screen.rect, 0x333333 );
			
			for (; x < targetWidth; x++ )
			{
				screen.setPixel( x, topY, 0x666666 );
				screen.setPixel( x, bottomY, 0x666666 );
				screen.setPixel( x, 0, 0x666666 );
				screen.setPixel( x, centerY, 0x666666 );
				screen.setPixel( x, maxY, 0x666666 );
			}
			
			for (; y < targetHeight; y++ )
			{
				screen.setPixel( leftX, y, 0x666666 );
				screen.setPixel( rightX, y, 0x666666 );
				screen.setPixel( 0, y, 0x666666 );
				screen.setPixel( centerX, y, 0x666666 );
				screen.setPixel( maxX, y, 0x666666 );
			}
		}
		
		protected function renderInterpolation(): void
		{
			var x: int = 0;
			var y0: int = screenMapping.map( interpolation.getInterpolationAt( 0 ) );
			var y1: int;
			
			var normalizedX: Number;
			
			for (; x < targetWidth; ++x )
			{
				normalizedX = x / targetWidth;
				
				screen.setPixel( x, y1 = screenMapping.map( interpolation.getInterpolationAt( normalizedX ) ), 0xffffff );
				
				drawLineV( x, y1, y0, 0xffffff );
				
				y0 = y1;
			}
		}
		
		override public function toString(): String
		{
			return '[InterpolationDisplay]';
		}
	}
}