package de.popforge.audio.processor.effects
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	/**
	 * TEST DRIVE
	 */
	
	public class CCCompressor
		implements IAudioProcessor
	{
		public const parameterThreshold: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .25 );
		public const parameterRatio: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .5 );
		public const parameterAttack: Parameter = new Parameter( new MappingNumberLinear( .001, 1 ), .001 );
		public const parameterRelease: Parameter = new Parameter( new MappingNumberLinear( .001, 1 ), .002 );
		
		private var gain: Number;
		
		public function CCCompressor()
		{
			gain = 1;
		}
		
		public function reset(): void
		{
		}
		
		public function processAudio( samples: Array ): void
		{
			var n: int = samples.length;
			
			var threshold: Number = parameterThreshold.getValue();
			var attack: Number = parameterAttack.getValue();
			var release: Number = parameterRelease.getValue();
			var ratio: Number = 1/4;
			
			var attackValue: Number = .997;
			var releaseValue: Number = 1.004;
			
			var level: Number;
			
			var sample: Sample;
			
			for( var i: int = 0 ; i < n ; ++i )
			{
				sample = samples[i];
				
				level = ( sample.left + sample.right ) * .5;
				level *= level;
				
				if( level > threshold )
				{
					gain *= attackValue;
				}
				else if( gain < 1 )
				{
					gain *= releaseValue;
					
					if( gain > 1 )
						gain = 1;
				}
				
				sample.left *= gain;
				sample.right *= gain;
			}
		}
	}
}