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
package de.popforge.utils
{
	import de.popforge.parameter.Parameter;
	import de.popforge.utils.sprintf;
	
	public class Formatter
	{
		protected var format: String;
		protected var args: Array;
		
		protected var value: String;
		protected var changedCallbacks: Array;
		
		public function Formatter( format: String, ... args )
		{
			this.format = format;
			
			this.args = new Array;
			
			var i: int = 0;
			var n: int = args.length;
			var argument:*;
			
			for (;i<n;++i)
			{
				argument = args[i];
				
				if ( argument is Parameter )
				{
					Parameter( argument ).addChangedCallbacks( onParameterChanged );
				}
				else
				if ( argument is Formatter )
				{
					Formatter( argument ).addChangedCallbacks( onFormatterChanged );
				}
				
				this.args.push( argument );
			}
			
			updateValue();
			
			changedCallbacks = new Array();
		}
		
		public function getValue(): String
		{
			return value;
		}
		
		protected function onParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			var oldValue: String = value;
			
			updateValue();
			
			valueChanged( oldValue );
		}
		
		protected function onFormatterChanged( formatter: Formatter, oldValue: String, newValue: String ): void
		{
			var oldValue: String = value;
			
			updateValue();
			
			valueChanged( oldValue );
		}
		
		protected function updateValue(): void
		{
			var argsBaked: Array = [ format ];
			
			var i: int = 0;
			var n: int = args.length;
			var argument:*;
			
			for (;i<n;++i)
			{
				argument = args[i];
				
				if ( argument is Parameter )
				{
					argsBaked.push( Parameter( argument ).getValue() );
				}
				else
				if ( argument is Formatter )
				{
					argsBaked.push( Formatter( argument ).getValue() );
				}
				else
				{
					argsBaked.push( argument );
				}
			}
			
			value = sprintf.apply( null, argsBaked );
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
		
		private function valueChanged( oldValue: String ): void
		{
			if( oldValue == value )
				return;
			
			try
			{
				for each( var callback: Function in changedCallbacks )
					callback( this, oldValue, value );
			}
			catch( e: ArgumentError )
			{
				throw new ArgumentError( 'Make sure callbacks have the following signature: (formatter: Formatter, oldValue: String, newValue: String)' );
			}
		}
		
		public function toString(): String
		{
			return '[Formatter format: ' + format + ', arguments: ' + args.toString() + ']';
		}
	}
}