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
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;

	/**
	 * The Knob class represents a simple knob.
	 * 
	 * @author Joa Ebert
	 */
	public class Knob extends FuiComponent implements IParameterBindable
	{
		protected var parameter: Parameter;
		
		protected var grip: DisplayObject;
		
		protected var mouseOrigin: Number;
		protected var valueOrigin: Number;
		
		public function connect( parameter: Parameter ): void
		{
			releaseParameter();
			
			this.parameter = parameter;
			
			grip.rotation = valueToRotation( parameter.getValueNormalized() ); 
			 
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
			grip.rotation = valueToRotation( parameter.getValueNormalized() );
		}
		
		protected function valueToRotation( normalizedValue: Number ): Number
		{
			return -225 + normalizedValue * 270;
		}
		
		override protected function build(): void
		{
			graphics.lineStyle( 2, 0x333333 );
			graphics.beginFill( 0x555555 );
			graphics.drawEllipse( 0, 0, targetWidth, targetHeight );
			graphics.endFill();
			
			var grip: Shape = new Shape;
			
			grip.graphics.lineStyle( 3, 0x999999 );
			grip.graphics.moveTo( targetWidth * .5 - 6, 0 );
			grip.graphics.lineTo( targetHeight * .5 - 2, 0 );

			grip.x = targetWidth * .5;
			grip.y = targetHeight * .5;
			
			addChild( grip );
			
			this.grip = grip;
			
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}
		
		protected function onMouseDown( event: MouseEvent ): void
		{
			if( event.altKey )
			{
				parameter.reset();
				return;
			}
			
			mouseOrigin = event.stageY;
			valueOrigin = parameter.getValueNormalized();
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			onStageMouseMove( event );
		}
		
		protected function onStageMouseMove( event: MouseEvent ): void
		{
			var ratio: Number = valueOrigin + ( mouseOrigin - event.stageY ) / ( event.shiftKey ? 1000 : 75 );
			
			if( ratio < 0 ) ratio = 0;
			else if( ratio > 1 ) ratio = 1;
			
			if ( parameter != null )
			{
				parameter.setValueNormalized( ratio );
			}
		}
		
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
			
			removeChild( grip );
			
			grip = null;
			
			super.dispose();
		}

		override public function toString(): String
		{
			return '[Knob]';
		}
	}
}