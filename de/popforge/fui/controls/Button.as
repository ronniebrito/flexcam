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
	import de.popforge.fui.core.IParameterBindable;
	import de.popforge.parameter.Parameter;
	
	import flash.display.InteractiveObject;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;

	/**
	 * The Button class is a base class for buttons inside the Fui framework.
	 * No visuals are handled in this class.
	 * 
	 * <p><b>Skin developer information:</b> You do not have to extend or overwrite this class
	 * since the visuals are created in classes that extend Button</p>
	 * 
	 * @author Joa Ebert
	 */
	internal class Button extends FuiComponent implements IParameterBindable
	{
		protected var parameter: Parameter;
		
		protected var trigger: InteractiveObject;
		
		public function connect( parameter: Parameter ): void
		{
			releaseParameter();
			
			this.parameter = parameter;

			updateButtonGraphics();
						 
			parameter.addChangedCallbacks( onParameterChanged );
		}
		
		public function disconnect(): void
		{
			releaseParameter();
		}
		
		protected function releaseParameter(): void
		{
			if ( parameter != null )
			{
				parameter.removeChangedCallbacks( onParameterChanged );
			}
			
			parameter = null;
		}
		
		protected function onParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			updateButtonGraphics();
		}
		
		protected function updateButtonGraphics(): void { /* OVERRIDE ME */ }
		protected function mouseDown(): void { /* OVERRIDE ME */ }
		protected function mouseUp(): void { /* OVERRIDE ME */ }

		protected function invertParameter(): void
		{
			if ( parameter.getValueNormalized() == 1 )
			{
				parameter.setValueNormalized( 0 );
			}
			else
			{
				parameter.setValueNormalized( 1 );
			}
		}
		override protected function build():void
		{	
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}
		
		private function onMouseDown( event: MouseEvent ): void
		{
			if( event.altKey )
			{
				parameter.reset();
				return;
			}
			
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			mouseDown();
		}
		
		private function onStageMouseUp( event: MouseEvent ): void
		{
			var dispatcher: IEventDispatcher = IEventDispatcher( event.currentTarget );
			dispatcher.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			mouseUp();
		}
		
		override public function toString(): String
		{
			return '[Button]';
		}
	}
}