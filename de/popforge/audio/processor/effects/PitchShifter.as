package de.popforge.audio.processor.effects
{
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.audio.output.Sample;
	
	/**
	 * TEST DRIVE
	 */

	public class PitchShifter
		implements IAudioProcessor
	{
		private const lineA: Array = new Array();
		private const lineB: Array = new Array();
		
		private const length: int = 4096;
		
		private var writeIndex: int;
		
		private var position: Number;
		
		public function PitchShifter()
		{
			init();
		}
		
		public function reset(): void
		{
			//-- clear delay lines
		}
			
		public function processAudio( samples: Array ): void
		{
			var n: int = samples.length;
			
			var sample: Sample;
			var mono: Number;
			
			var readIndex: int;
			
			var offset: Number;
			var alpha: Number;
			
			var aA: Number;
			var aB: Number;
			
			for( var i: int = 0 ; i < n ; i++ )
			{
				sample = samples[i];
				
				mono = ( sample.left + sample.right ) / 2;
				
				lineA[ writeIndex ] = mono;
				lineB[ writeIndex ] = mono;
				
				var speed: Number = .2;
				
				offset = writeIndex * speed;
				
				alpha = offset / length / speed;
				
				readIndex = writeIndex - length * .5 + offset;
				if( readIndex < 0 ) readIndex += length;
				aA = lineA[ readIndex ];
				
				readIndex = writeIndex - length * .5 + ( offset - length * speed );
				if( readIndex < 0 ) readIndex += length;
				aB = lineA[ readIndex ];
				
				sample.left = sample.right = aA * ( 1 - alpha ) + aB * alpha;
				
				if( ++writeIndex >= length )
					writeIndex = 0;
			}
		}
		
		private function init(): void
		{
			for( var i: int = 0 ; i < length ; i++ )
			{
				lineA[i] = 0.0;
				lineB[i] = 0.0;
			}
			
			writeIndex = 0;
			
			position = 0;
		}
	}
}