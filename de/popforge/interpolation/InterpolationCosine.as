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
package de.popforge.interpolation
{
	import de.popforge.parameter.IMapping;
	
	public final class InterpolationCosine extends Interpolation
	{
		/**
		 * Creates a new InterpolationLinear object.
		 * 
		 * @param mapping The IMapping object used to map the normalized value.
		 */			
		public function InterpolationCosine( mapping: IMapping = null )
		{
			super( mapping );
		}
		
		/**
		 * Calculates the cosine interpolated value <em>y</em> for <em>x</em> based on the control points.
		 * 
		 * @param x Normalized position on the <em>x</em>-axis.
		 * @return The <em>y</em> value at given position <em>x</em>.
		 * 
		 */	
		override protected function interpolate( x: Number ): Number
		{
			var index: uint = findPointBefore( x );
			
			var p0: ControlPoint = points[ index ];
			var p1: ControlPoint;
			
			if ( ( index + 1 ) == numPoints )
			{
				p1 = p0;
			}
			else
			{
				p1 = points[ index + 1 ];
			}
			
			var y: Number;
			var t: Number = ( x - p0.x ) / ( p1.x - p0.x );
			
			if ( index == 0 || index >= ( numPoints - 2 ) )
			{
				// Interpolate linear between first two and last two points.
				y = p0.y + ( p1.y - p0.y ) * t;
			}
			else
			{
				// Cosine interpolation between the rest
				var g: Number = ( 1 + Math.cos( t * Math.PI ) ) * .5;
				y = g * p0.y + ( 1 - g ) * p1.y;
			}
			
			return clamp( y );
		}
		
		/**
		 * Creates the string representation of the current object.
		 * @return The string representation of the current object.
		 * 
		 */	
		override public function toString(): String
		{
			return '[InterpolationCosine]';
		}		
	}
}