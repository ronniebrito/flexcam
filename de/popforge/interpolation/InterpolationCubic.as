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
	
	public final class InterpolationCubic extends Interpolation
	{
		/**
		 * Creates a new InterpolationLinear object.
		 * 
		 * @param mapping The IMapping object used to map the normalized value.
		 */			
		public function InterpolationCubic( mapping: IMapping = null )
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
			
			var p0: ControlPoint;
			var p1: ControlPoint = points[ index ];
			var p2: ControlPoint;
			var p3: ControlPoint;
			
			if ( ( index - 1 ) < 0 )
			{
				p0 = points[ int( 0 ) ];
			}
			else
			{
				p0 = points[ int( index - 1 ) ];
			}
			
			if ( ( index + 1 ) == numPoints )
			{
				p2 = p1;
				p3 = p1;
			}
			else
			{
				p2 = points[ int( index + 1  )];
				
				if ( ( index + 2 ) == numPoints )
				{
					p3 = p2;
				}
				else
				{
					p3 = points[ int( index + 2 ) ];
				}
			}
			
			var y: Number;
			var t: Number = ( x - p1.x ) / ( p2.x - p1.x );
			
			if ( index == 0 || index >= ( numPoints - 2 ) )
			{
				// Interpolate linear between first two and last two points.
				y = p1.y + ( p2.y - p1.y ) * t;
			}
			else
			{
				// Cubic interpolation between the rest
				var p: Number = ( p3.y - p2.y ) - ( p0.y - p1.y );
				var q: Number = ( p0.y - p1.y ) - p;
				var r: Number = p2.y - p0.y;
				var s: Number = p1.y;
				
				y = p * t * t * t + q * t * t + r * t + s;
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
			return '[InterpolationCubic]';
		}		
	}
}