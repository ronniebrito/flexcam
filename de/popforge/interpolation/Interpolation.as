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
	
	import flash.net.registerClassAlias;
	
	/**
	 * The Interpolation class represents a interpolation between given control points.
	 * Control points work on a normalized range from <em>0</em> to <em>1</em>.
	 * 
	 * Depending on the given IMapping an Interpolation object
	 * can store different types of values.
	 * 
	 * @author Joa Ebert
	 */	
	public class Interpolation
	{
		{
			registerClassAlias( 'Interpolation', Interpolation );
		}
		
		private var hasAnchorPoints: Boolean;
		private var mapping: IMapping;
		
		private var _mode: uint;
		private var table: Array;
		private var resolution: uint;
		private var changedCallbacks: Array;
		
		/**
		 * An array of control points.
		 * The control points are always sorted on their <em>x</em> value.
		 */		
		protected var points: Array;
		
		/**
		 * The number of control points.
		 */		
		protected var numPoints: uint;
		
		/**
		 * Creates a new Interpolation object.
		 * 
		 * @param mapping The IMapping object used to map the normalized value.
		 */		
		public function Interpolation( mapping: IMapping = null )
		{
			changedCallbacks = new Array;
			
			this.mapping = mapping;
			points = new Array;
			
			mode = InterpolationMode.RUNTIME;
		}
		
		/**
		 * Adds a control point.
		 * 
		 * @param point The control point to add.
		 */		
		public function addControlPoint( point: ControlPoint ): void
		{
			removeAnchors();
			
			points.push( point );
			points.sortOn( 'x', Array.NUMERIC );
			
			numPoints = points.length;
			
			point.addChangedCallbacks( onPointChanged );
			
			addAnchors();
		}
		
		/**
		 * Removes a control point by reference.
		 * This is not done by a value check.
		 * 
		 * @param point The control point to remove.
		 * 
		 */		
		public function removeControlPoint( point: ControlPoint ): void
		{
			removeAnchors();
			
			var index: int = points.indexOf( point );
			
			if ( index != -1 )
			{
				ControlPoint( points[ index ] ).removeChangedCallbacks( onPointChanged );
				
				points.splice( index, 1 );
				numPoints = points.length;
			}
			
			addAnchors();
		}
		
		private function onPointChanged( point: ControlPoint, oldX: Number, oldY: Number, x: Number, y: Number ): void
		{
			removeAnchors();
			
			points.sortOn( 'x' );
			
			addAnchors()
			/*var index: uint = points.indexOf( point );
			var anchorPoint: ControlPoint;
						
			//-- POINT COULD BE IN MIDDLE IF ONLY 1 POINT IS EXISTING
			//-- 0 = ANCHOR LEFT, 1 = POINT, 2 = ANCHOR RIGHT
			
			if ( index == 1 )
			{ // First point (update position of first anchor)
				anchorPoint = points[ int( 0 ) ];
				anchorPoint.x = x;
				anchorPoint.y = y;
			}
			
			if ( index == ( numPoints - 2 ) )
			{ // Last point (update position of last anchor)
				anchorPoint = points[ int( numPoints - 1 ) ];
				anchorPoint.x = x;
				anchorPoint.y = y;
			}*/
			
			valueChanged();
		}
		
		/**
		 * Retrievs the interpolated value at position <em>x</em> and returns the mapped value.
		 * If no control points are added a default value of <em>0</em> is used as the interpolated value.
		 * 
		 * @param x A normalized value from <em>0</em> to <em>1</em>.
		 * @return The mapped value at interpolated position <em>x</em>.
		 * 
		 */		
		public function getValueAt( x: Number ):*
		{
			if ( numPoints == 0 )
				return mapping.map( 0 );
			
			return mapping.map( getInterpolationAt( x ) );
		}
		
		
		public function getInterpolationAt( x: Number ): Number
		{
			if ( numPoints == 0 )
				return 0;
				
			if ( _mode == InterpolationMode.RUNTIME )
			{
				return interpolate( x )
			}
			else
			if ( _mode == InterpolationMode.BAKED )
			{
				return fromTable( x );
			}
			else
			if ( _mode == InterpolationMode.BAKED_LINEAR )
			{
				return fromTableLinear( x );
			}
			
			return 0;
		}
		
		/**
		 * Searches for a point that is prior to <em>x</em>.
		 * 
		 * @param x The position on the <em>x</em>-axis to search for.
		 * @return The index of the point that has been found.
		 * 
		 */		
		protected function findPointBefore( x: Number ): uint
		{
			var p0: ControlPoint;
			var p1: ControlPoint;
			
			var p0x: Number;
			var p1x: Number;
			
			var index: uint = numPoints >> 1;
			
			while ( true )
			{
				p0 = points[ index ];
				p0x = p0.x;
				
				if ( int( index + 1 ) != numPoints )
				{
					p1 = points[ int( index + 1 ) ];
					p1x = p1.x;
				}
				else // Precheck: There is no next point. We reached the end but x is still greater than p0. So we found the last point before x.
					return index;
				
				if ( p0x == x )
				{ // x is on a point. Return point before x if possible.
					if ( index > 1 )
						return ( index - 1 );
					return 1;
				}
				else if ( ( p0x <= x ) && ( x <= p1x ) )
				{ // We have a perfect match (p0 <= x <= p1)
					return index;
				}
				else if ( p0x > x )
				{ // We have to walk backwards because p0 > x
					index--;
				}
				else if ( p0x < x && p1x < x )
				{ // We have to walk forwards because both p0 and p1 are < x
					index++;
				}
			}
			
			return 0;
		}
		
		/**
		 * Calculates the interpolated value <em>y</em> for <em>x</em> based on the control points.
		 * 
		 * This function has to be overriden.
		 * 
		 * @param x Normalized position on the <em>x</em>-axis.
		 * @return The <em>y</em> value at given position <em>x</em>.
		 * 
		 */		
		protected function interpolate( x: Number ): Number
		{
			return x;
		}
		
		/**
		 * Creates the string representation of the current object.
		 * @return The string representation of the current object.
		 * 
		 */		
		public function toString(): String
		{
			return '[Interpolation]';
		}
		
		/**
		 * Adds anchor points at (0|y0) and (1|yN).
		 */		
		private function addAnchors(): void
		{
			points.push( new ControlPoint( 1, ControlPoint( points[ numPoints - 1 ] ).y ) );
			points.unshift( new ControlPoint( 0, ControlPoint( points[ 0 ] ).y ) );
				
			numPoints += 2;
		}
		
		/**
		 * Removes anchor points.
		 */		
		private function removeAnchors(): void
		{
			points.pop();
			points.shift();
			numPoints -= 2;
		}

		/**
		 * Clamps a value so that <code>0 &lt;= value &lt;= 1</code> is true.
		 * 
		 * @param value The value to clamp.
		 * @return The value in the range of <code>0..1</code>.
		 * 
		 */		
		protected function clamp( value: Number ): Number
		{
			if ( value > 1 )
				return 1;
			else if ( value < 0 )
				return 0;
			else
				return value;
		}
		
		/**
		 * Retrievs value <em>x</em> from private look-up table.
		 * 
		 * @param x Position on the <em>x</em>-axis.
		 * @return Precalculated value on <em>y</em>-axis.
		 * 
		 */		
		private function fromTable( x: Number ): Number
		{
			return table[ int( x * resolution + .5 ) ];
		}
		
		/**
		 * Retrievs value <em>y</em> from private look-up table.
		 * If <em>x</em> is in between two values a linear interpolation is used.
		 * 
		 * @param x Position on the <em>x</em>-axis.
		 * @return Linear interpolated value on <em>y</em>-axis.
		 * 
		 */		
		private function fromTableLinear( x: Number ): Number
		{
			var xrf: Number = x * resolution;
			var xri: int = int( xrf );
				
			var dx: Number = xrf - xri
			
			if ( dx == 0 )
				return table[ xri ];
				
			var p0: Number = table[ xri ];
			var p1: Number = table[ int( xri + 1 ) ];
			
			return ( p0 + ( p1 - p0 ) * dx );
		}
		
		/**
		 * Bakes the current interpolation.
		 * 
		 * This way your interpolation will act much faster but changes to the
		 * interpolation by adding points or chainging their position will not
		 * affect the output unless you call bake() again or set the <code>mode</code>
		 * back to InterpolationMode.RUNTIME.
		 * 
		 * Do not forget to set the <code>mode</code> of the interpolation to InterpolationMode.BAKED
		 * or InterpolationMode.BAKED_LINEAR in order to use the baked values.
		 * 
		 * @param resolution The resolution of the baked interpolation. The higher the resolution the more accurate results you will get.
		 * 
		 */		
		public function bake( resolution: uint = 0xff ): void
		{
			this.resolution = resolution;
			
			var i: int = 0;
			var n: int = resolution + 1;
			
			table = new Array( n );
			
			for (;i<n;++i)
			{
				table[ i ] = interpolate( i / resolution );
			}
		}
		
		/**
		 * The mode of the current Interpolation object.
		 * Can be any value of InterpolationMode.
		 */		
		public function set mode( interpolationMode: uint ): void
		{
			_mode = interpolationMode;
		}
		
		public function get mode(): uint
		{
			return _mode;
		}
		
		public function addChangedCallbacks( callback: Function ): void
		{
			changedCallbacks.push( callback );
		}

		public function removeChangedCallbacks( callback: Function ): void
		{
			var index: int = changedCallbacks.indexOf( callback );
			
			if( index > -1 )
				changedCallbacks.splice( index, 1 );
		}
		
		private function valueChanged(): void
		{
			try
			{
				for each( var callback: Function in changedCallbacks )
					callback( this );
			}
			catch( e: ArgumentError )
			{
				throw new ArgumentError( 'Make sure callbacks have the following signature: (interpolation: Interpolation)' );
			}
		}
	}
}