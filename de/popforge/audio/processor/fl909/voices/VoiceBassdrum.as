package de.popforge.audio.processor.fl909.voices
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.fl909.tone.ToneBassdrum;
	
	public final class VoiceBassdrum extends Voice
	{
		static private const sndNoise: Array = Rom.getAmplitudesByName( '909.bd.noise.raw' );
		static private const sndBody: Array = Rom.getAmplitudesByName( '909.bd.grain.raw' );
		
		{ sndBody.push( sndBody[0] ); }
		
		static private var sndBodyNum: int = sndBody.length;
		
		private var tone: ToneBassdrum;
		
		private var tuneValue: Number;
		private var attackValue: Number;
		
		private var cutEnv: Number;
		private var bodyEnv: Number;
		private var posBody: Number;
		
		public function VoiceBassdrum( start: int, volume: Number, tone: ToneBassdrum )
		{
			super( start, volume );
			
			this.tone = tone;
			
			monophone = true;
			
			cutEnv = 1;
			bodyEnv = 1;
			posBody = 0;
			
			//-- static for one cycle
			tuneValue = tone.tune.getValue();
			attackValue = tone.attack.getValue() * volume;
		}
		
		public override function processAudioAdd( samples: Array ): Boolean
		{
			var n: int = samples.length;
			
			var sample: Sample;
			var amplitude: Number;
			
			var alpha: Number;
			var posBodyInt: int;
			
			var levelValue: Number = tone.level.getValue() * volume;
			var decayValue: int = tone.decay.getValue();

			for( var i: int = start ; i < n ; i++ )
			{
				if( i >= stop )
					return true;
					
				sample = samples[i];
				
				//-- BODY GRAIN (INTERPOLATED)
				posBodyInt = posBody;
				alpha = posBody - posBodyInt;
				amplitude = sndBody[ posBodyInt ] * ( 1 - alpha );
				amplitude += sndBody[ int( posBodyInt + 1 ) ] * alpha;
				amplitude *= bodyEnv * levelValue * cutEnv;
				
				//-- CLICK NOISE
				if( position < sndNoise.length )
					amplitude += sndNoise[ position ] * attackValue * levelValue;
				
				//-- DECAY
				if( position++ > decayValue )
				{
					//-- observed value
					bodyEnv *= .9994;

					if( bodyEnv < .001 )
						return true;
				}
				
				//-- ADD AMPLITUDE (MONO)
				sample.left += amplitude;
				sample.right += amplitude;
				
				//-- ADVANCE WAVEFORMS
				posBody += tuneValue;
				while( posBody >= sndBodyNum )
					posBody -= sndBodyNum;

				//-- observed value
				tuneValue += ( 1 - tuneValue ) * .0011;
			}
			
			start = 0;
			
			return false;
		}
		
		public override function getChannel(): int
		{
			return 0;
		}
	}
}