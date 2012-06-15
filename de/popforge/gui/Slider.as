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
package de.popforge.gui
{
	import de.popforge.parameter.Parameter;
	
	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	/**
	 * Slider is a default design gui element
	 * to change the value of a Parameter
	 * 
	 * Click knob while holding the ALT-key to reset the parameter value
	 */
	public class Slider extends Sprite
	{
		private var parameter: Parameter;
		private var length: uint;
		
		private var knob: Sprite;
		private var dragOffset: int;
		
		/**
		 * Creates a Slider instance
		 * 
		 * @param parameter The parameter instance, that value should be changable
		 * @param length The length of the knobs freedom of movement
		 */
		public function Slider( parameter: Parameter, length: uint = 100 )
		{
			this.parameter = parameter;
			this.length = length;
			
			init();
		}
		
		private function init(): void
		{
			graphics.lineStyle( 2, 0x555555 );
			graphics.beginFill( 0x333333 );
			graphics.drawRoundRect( 0, 0, length + 16, 16, 16, 16 );
			graphics.endFill();

			knob = new Sprite();
			knob.x = 8 + parameter.getValueNormalized() * length;
			knob.y = 8;
			knob.graphics.lineStyle( 2, 0x333333 );
			knob.graphics.beginFill( 0x666666 );
			knob.graphics.drawCircle( 0, 0, 8 );
			knob.graphics.endFill();
			addChild( knob );

			parameter.addChangedCallbacks( onParameterChanged );
			
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}
		
		private function onParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			knob.x = 8 + parameter.getValueNormalized() * length;
		}
		
		private function onMouseDown( event: MouseEvent ): void
		{
			if( event.altKey )
			{
				parameter.reset();
				return;
			}
			
			if( event.target == knob )
				dragOffset = knob.mouseX;
			else
				dragOffset = 0;
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			onStageMouseMove( null );
		}
		
		private function onStageMouseMove( event: MouseEvent ): void
		{
			var ratio: Number = ( mouseX - dragOffset - 8 ) / length;
			
			if( ratio < 0 ) ratio = 0;
			else if( ratio > 1 ) ratio = 1;
			
			parameter.setValueNormalized( ratio );
		}
		
		private function onStageMouseUp( event: MouseEvent ): void
		{
			var dispatcher: IEventDispatcher = IEventDispatcher( event.currentTarget );
			
			dispatcher.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			dispatcher.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}
	}
}