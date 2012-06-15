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
	import de.popforge.fui.controls.*;
	import de.popforge.fui.controls.Label;
	
	/**
	 * The IFuiSkin interface has to bee implemented by a skin provider for the Fui framework.
	 * 
	 * @author Joa Ebert
	 */
	public interface IFuiSkin
	{
		/**
		 * Width and height of a tile for this skin.
		 * Tiles are always squares.
		 */		
		function get tileSize(): uint;

		function createTriggerButton( parameters: XML ): TriggerButton;
		function createSwitchButton( parameters: XML ): SwitchButton;
		
		function createHSlider( parameters: XML ): HSlider;
		function createVSlider( parameters: XML ): VSlider;
		
		function createLabel( parameters: XML ): Label;
		
		function createKnob( parameters: XML ): Knob;
		
		function createInterpolationDisplay( parameters: XML ): InterpolationDisplay;
	}
}