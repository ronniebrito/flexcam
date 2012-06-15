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
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	public class StereoDelay
		implements IAudioProcessor
	{
		static public const parameterMix: Parameter = new Parameter( new MappingNumberLinear(), .2 );
		static public const parameterFeedback: Parameter = new Parameter( new MappingNumberLinear(), .4 );
		static public const parameterOffset: Parameter = new Parameter( new MappingNumberLinear( 1024, 8196 ), 5800 );
		
		private const line: Array = new Array();
		
		private var writeIndex: int;
		
		public function StereoDelay()
		{
			init();
		}
		
		public function reset(): void
		{
			for each( var sample: Sample in line )
				sample.left = sample.right = 0.0;
		}
		
		public function processAudio( samples: Array ): void
		{
			var n: int = samples.length;
			
			var output: Sample;
			var write: Sample;
			
			var read: Sample;
			var readIndex: int;
			
			var mix: Number = parameterMix.getValue();
			var feedback: Number = parameterFeedback.getValue();
			var offset: int = parameterOffset.getValue();
			
			for( var i: int = 0 ; i < n ; i++ )
			{
				output = samples[i];
				write = line[ writeIndex ];
				
				//-- write into delay line
				write.left = output.left;
				write.right = output.right;
				
				//-- read time displaced
				readIndex = writeIndex - offset;
				
				if( readIndex < 0 )
					readIndex += 0x10000;
				
				read = line[ readIndex ];
				
				//-- mix (dry=0,wet=1)
				output.left = read.left * mix + output.left * ( 1 - mix );
				output.right = read.right * mix + output.right * ( 1 - mix );
				
				//-- feedback
				write.left += read.left * feedback;
				write.right += read.right * feedback;
				
				if( ++writeIndex == 0x10000 )
					writeIndex = 0;
			}
		}

		private function init(): void
		{
			for( var i: int = 0 ; i < 0x10000 ; i++ )
				line.push( new Sample() );
			
			writeIndex = 0;
		}
	}
}