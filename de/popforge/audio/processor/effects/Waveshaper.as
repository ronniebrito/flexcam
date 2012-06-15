package de.popforge.audio.processor.effects
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;

	public class Waveshaper
		implements IAudioProcessor
	{
		public const parameterAmount: Parameter = new Parameter( new MappingNumberLinear( 0, 10 ), 1 );
		
		public function Waveshaper()
		{
			
		}
		
		public function processAudio( samples: Array ): void
		{
			var n: int = samples.length;
			
			var amount: Number = parameterAmount.getValue();
			
			var x: Number;
			
			for each( var sample: Sample in samples )
			{
				x = sample.left;
				
				if( x > 0 )
					sample.left = x * ( x + amount ) / ( x * x + ( amount - 1 ) * x + 1 );
				else
					sample.left = -x * ( amount - x ) / ( x * x - ( amount - 1 ) * x + 1 );
				
				x = sample.right;
				
				if( x > 0 )
					sample.right = x * ( x + amount ) / ( x * x + ( amount - 1 ) * x + 1 );
				else
					sample.right = -x * ( amount - x ) / ( x * x - ( amount - 1 ) * x + 1 );
			}
		}
		
		public function reset(): void
		{
		}
	}
}