package de.popforge.audio.processor.fl909.voices
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.fl909.tone.ToneBase;
	
	public final class VoiceClap extends Voice
	{
		static private const snd: Array = Rom.getAmplitudesByName( '909.clap.raw' );
		
		private var tone: ToneBase;
		
		public function VoiceClap( start: int, volume: Number, tone: ToneBase )
		{
			super( start, volume );
			
			this.tone = tone;
			
			length = snd.length;
		}
		
		public override function processAudioAdd( samples: Array ): Boolean
		{
			var n: int = samples.length;
			
			var sample: Sample;
			var amplitude: Number;
			
			var level: Number = tone.level.getValue() * volume;
			
			for( var i: int = start ; i < n ; i++ )
			{
				if( i >= stop )
					return true;

				sample = samples[i];

				amplitude = snd[ position ] * level;

				//-- ADD AMPLITUDE (MONO)
				sample.left += amplitude;
				sample.right += amplitude;
				
				if( ++position >= length )
					return true;
			}

			start = 0;
			
			return false;
		}
		
		public override function getChannel(): int
		{
			return 6;
		}
	}
}