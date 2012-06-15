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
package de.popforge.fui.core
{
	import de.popforge.fui.Fui;
	import de.popforge.parameter.MappingBoolean;
	import de.popforge.parameter.Parameter;
	
	/**
	 * The Group class is a manager that handles a Parameter object with a MappingValues for multiple components.
	 * 
	 * Since components do not know anything about each other they can not know
	 * what to do if a certai value appears. The Group object is a proxy that will
	 * connect a IParameterBindable object with an internal Parameter object using MappingBoolean
	 * that is set to <code>true</code> when the paramter value of the group is changed to the
	 * asociated value for the IParameterBindable.
	 * 
	 * @author Joa Ebert
	 */	
	public class Group implements IParameterBindable
	{
		/**
		 * The Fui object where the current Group object belongs to.
		 */		
		protected var fui: Fui;
		
		/**
		 * The binded parameter.
		 */		
		protected var parameter: Parameter;
		
		/**
		 * Componets in the group.
		 */		
		protected var components: Array;
		
		/**
		 * Proxy parameters for the components that belong to the group.
		 */		
		protected var parameters: Array;
		
		/**
		 * Values that are asociated with the components.
		 */		
		protected var values: Array;
		
		/**
		 * A helping varibable that makres if a change to a proxy parameter has been made
		 * internally or comes from a different source (e.g. user pressing a SwitchButton).
		 */		
		protected var internalChange: Boolean;
		
		/**
		 * Creates a new Group object.
		 * 
		 * @param fui The Fui object the Group belongs to.
		 */		
		public function Group( fui: Fui )
		{
			this.fui = fui;
			
			components = new Array;
			parameters = new Array;
			values = new Array;
		}
		
		/**
		 * Adds a FuiComponent to the group.
		 * 
		 * The FuiComponent has to be able to bind paramters.
		 * 
		 * @param name The name of the FuiComponent in the belonging Fui object.
		 * @param value The value belonging to the FuiComponent.
		 * 
		 * @return <code>true</code> if the FuiComponent has been added; <code>false</code> otherwise.
		 * 
		 * @throws Error If the FuiComponent does not implement IParameterBindable.
		 */		
		public function addComponent( name: String, value: * ): Boolean
		{
			var component: FuiComponent = fui.getElementById( name );
			var parameter: Parameter = new Parameter( new MappingBoolean, false );
			
			if ( components.indexOf( component ) != -1 )
			{
				return false;
			}
			
			if (!( component is IParameterBindable ))
			{
				throw new Error( 'Groups may only contain objects that implement IParameterBindable.' );
			}
			
			parameter.addChangedCallbacks( onGroupParameterChanged );
			
			components.push( component );
			parameters.push( parameter );
			values.push( value );
			
			IParameterBindable( component ).connect( parameter );
			
			if ( this.parameter != null )
			{
				{ internalChange = true;
					parameter.setValue( value == this.parameter.getValue() );
				internalChange = false; }
			}
			
			return true;
		}
		
		/**
		 * Removes a FuiComponent from the group.
		 * 
		 * @param name The name of the FuiComponent in the belonging Fui object.
		 * @return <code>true</code> if the FuiComponent has been removed; <code>false</code> otherwise.
		 */		
		public function removeComponent( name: String ): Boolean
		{
			var component: FuiComponent = fui.getElementById( name );
			var index: int = components.indexOf( component );
			
			if ( index == -1 )
				return false;
			
			var parameter: Parameter = parameters[ index ];
			
			parameter.removeChangedCallbacks( onGroupParameterChanged );
			
			IParameterBindable( component ).disconnect();
			
			components.splice( index, 1 );
			parameters.splice( index, 1 );
			values.splice( index, 1 );
			
			return true;
		}
		
		/**
		 * @inheritDoc
		 */		
		public function connect( parameter: Parameter ): void
		{
			releaseParameter();
			
			this.parameter = parameter;
			
			parameter.addChangedCallbacks( onParameterChanged );
			
			initGroup();
		}
		
		/**
		 * @inheritDoc
		 */		
		public function disconnect(): void
		{
			releaseParameter();
		}
		
		/**
		 * Releases the paramter and removes the listener.
		 */		
		protected function releaseParameter(): void
		{
			if ( parameter != null )
			{
				parameter.removeChangedCallbacks( onParameterChanged );
			}
			
			parameter = null;
		}
		
		/**
		 * Initializes the group.
		 * Should be called only once when <code>connect()</code> is called.
		 */		
		protected function initGroup(): void
		{
			var index: int = values.indexOf( parameter.getValue() );

			if  ( index == -1 )
				return;
				
			var i: int = 0;
			var n: int = parameters.length;
			
			{ internalChange = true;
				for (;i<n;++i)
				{
					Parameter( parameters[ i ] ).setValue( i == index );
				}
			internalChange = false; }
		}
		
		/**
		 * Listener for changes of proxy parameters.
		 * 
		 * @param parameter The parameter that has been changed.
		 * @param oldValue The old value of the parameter.
		 * @param newValue The new value of the parameter.
		 * 
		 */		
		protected function onGroupParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			var index: int = parameters.indexOf( parameter );

			if ( index == -1 )
				return;
			
			if ( Boolean( newValue ) == true )
			{
				this.parameter.setValue( values[ index ] );
			}
			else
			{
				if ( !internalChange )
				{
					// A proxy parameter has been set to false by the user.
					// We do not allow this in a group since one of the values
					// has to be true.
					parameter.setValue( true );
				}
			}
		}
		
		/**
		 * Listener for changes of the binded parameter.
		 * 
		 * @param parameter The parameter that has been changed.
		 * @param oldValue The old value of the parameter.
		 * @param newValue The new value of the parameter.
		 * 
		 */		
		protected function onParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			var index: int = values.indexOf( newValue );

			if ( index == -1 )
				return;
				
			var i: int = 0;
			var n: int = parameters.length;
			
			{ internalChange = true;
				for (;i<n;++i)
				{
					Parameter( parameters[ i ] ).setValue( i == index );
				}
			internalChange = false; }
		}
		
		/**
		 * Creates and returns the string representation of the current object.
		 * 
		 * @return The string representation of the current object.
		 */		
		public function toString(): String
		{
			return '[Group]';
		}
	}
}