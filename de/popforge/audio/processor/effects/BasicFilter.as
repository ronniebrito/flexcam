/*
Copyright(C) 2007 Andre Michelle and Joa Ebert

PopForge is an ActionScript3 code sandbox developed by Andre Michelle and Joa Ebert
http://sandbox.popforge.de

This file is part of PopforgeAS3Audio.

PopforgeAS3Audio is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

PopforgeAS3Audio is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
*/
package de.popforge.audio.processor.effects
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.Parameter;
	
	public class BasicFilter
		implements IAudioProcessor
	{
		public const parameterCutoff: Parameter = new Parameter( new MappingNumberExponential( 0, 1 ), .1 );
		public const parameterResonance: Parameter = new Parameter( new MappingNumberExponential( 0, .9 ), .4 );
		
		private var velL: Number;
		private var velR: Number;
		private var outL: Number;
		private var outR: Number;
		
		public function BasicFilter()
		{
			reset();
		}
		
		public function reset(): void
		{
			velL = velR = 0;
			outL = outR = 0;
		}

		public function processAudio( samples: Array ): void
		{
			var n: int = samples.length;
			
			var input: Sample;
			
			var cutoff: Number = parameterCutoff.getValue();
			var resonance: Number = parameterResonance.getValue();
			
			for( var i: int = 0 ; i < n ; i++ )
			{
				input = samples[i];
				
				velL *= resonance;
				velR *= resonance;
				
				velL += ( input.left - outL ) * cutoff;
				velR += ( input.right - outR ) * cutoff;

				outL += velL;
				outR += velR;

				input.left = outL;
				input.right = outR;
			}
		}
	}
}