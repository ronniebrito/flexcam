package de.popforge.audio.processor.effects
{
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.interpolation.Interpolation;
	import de.popforge.audio.output.Sample;

	public class Distort implements IAudioProcessor
	{
		private var interpolation: Interpolation;
		
		public function Distort( interpolation: Interpolation )
		{
			this.interpolation = interpolation;
		}
		
		public function processAudio( samples: Array ): void
		{
			var i: int = 0;
			var n: int = samples.length;
			
			var sample: Sample;
			var value: Number;
			
			for (;i<n;++i)
			{
				sample = samples[ i ];
				
				if ( sample.left < 0 )
				{
					sample.left = -interpolation.getValueAt( -sample.left );
				}
				else
				{
					sample.left = interpolation.getValueAt( sample.left );
				}
				
				if ( sample.right < 0 )
				{
					sample.right = -interpolation.getValueAt( -sample.right );
				}
				else
				{
					sample.right = interpolation.getValueAt( sample.right );
				}
			}
		}
		
		public function reset(): void {}
	}
}