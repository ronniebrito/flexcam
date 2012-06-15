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
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * The Slider class is a base for sliders in the Fui framework.
	 * 
	 * @author Joa Ebert
	 */	
	internal class Slider extends FuiComponent implements IParameterBindable
	{
		protected var parameter: Parameter;
		
		protected var knob: InteractiveObject;
		
		protected var knobOffsetX: Number;
		protected var knobOffsetY: Number;
		
		protected var length: Number;
		protected var dragOffset: Number;
		
		public function connect( parameter: Parameter ): void
		{
			releaseParameter();
			
			this.parameter = parameter;

			updateKnobPosition();
						 
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
			updateKnobPosition();
		}

		protected function updateKnobPosition(): void { /* OVERRIDE ME */ }
		
		override protected function build():void
		{	
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}
		
		protected function onMouseDown( event: MouseEvent ): void
		{
			if( event.altKey )
			{
				parameter.reset();
				return;
			}
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			onStageMouseMove( null );
		}
		
		protected function onStageMouseMove( event: MouseEvent ): void { /* OVERRIDE ME */ }
		
		protected function onStageMouseUp( event: MouseEvent ): void
		{
			var dispatcher: IEventDispatcher = IEventDispatcher( event.currentTarget );
			
			dispatcher.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			dispatcher.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}
		
		override public function dispose(): void
		{
			releaseParameter();
			
			removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			
			if ( contains( knob ) )
				removeChild( knob );
			
			knob = null;
			
			super.dispose();
		}

		override public function toString(): String
		{
			return '[Slider]';
		}
	}
}