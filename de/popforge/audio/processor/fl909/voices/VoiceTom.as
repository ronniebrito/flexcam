package de.popforge.audio.processor.fl909.voices
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.fl909.tone.ToneTom;
	
	public final class VoiceTom extends Voice
	{
		static public const SIZE_LOW: int = 0;
		static public const SIZE_MED: int = 1;
		static public const SIZE_HIGH: int = 2;
		
		static private const snd0: Array = Rom.getAmplitudesByName( '909.tl.raw' );
		static private const snd1: Array = Rom.getAmplitudesByName( '909.tm.raw' );
		static private const snd2: Array = Rom.getAmplitudesByName( '909.th.raw' );
		
		{ snd0.push( snd0[0] ); snd1.push( snd1[0] ); snd2.push( snd2[0] ); }
		
		private var snd: Array;
		
		private var size: int;
		
		private var cutEnv: Number;
		private var tone: ToneTom;
		private var volEnv: Number;
		
		private var posFloat: Number;
		
		private var tuneValue: Number;
		
		public function VoiceTom( start: int, volume: Number, tone: ToneTom, size: int )
		{
			super( start, volume );
			
			this.tone = tone;
			
			switch( size )
			{
				case SIZE_LOW: snd = snd0; break;
				case SIZE_MED: snd = snd1; break;
				case SIZE_HIGH: snd = snd2; break;
			}
			
			this.size = size;
			
			length = snd.length - 1;
			
			monophone = true;
			
			tuneValue = tone.tune.getValue();
			
			volEnv = 1;
			cutEnv = 1;
			
			posFloat = 0;
		}
		
		public override function processAudioAdd( samples: Array ): Boolean
		{
			var n: int = samples.length;
			
			var sample: Sample;
			var amplitude: Number;
			
			var tunePos: Number;
			var tunePosInt: int;
			var alpha: Number;
			
			var levelValue: Number = tone.level.getValue() * volume;
			var tuneValue: Number = tone.tune.getValue();
			var decayValue: int = length * tone.decay.getValue();
			
			for( var i: int = start ; i < n ; i++ )
			{
				sample = samples[i];
				
				//-- LINEAR INTERPOLATION
				tunePosInt = posFloat;
				
				if( tunePosInt >= length - 1 )
					return true;
					
				if( i >= stop )
					return true;
				
				alpha = posFloat - tunePosInt;
				
				amplitude = snd[ tunePosInt ] * ( 1 - alpha );
				amplitude += snd[ int( tunePosInt + 1 ) ] * alpha;
				amplitude *= levelValue * volEnv * cutEnv;
				
				//-- DECAY
				if( position++ >= decayValue )
				{
					//-- observed value
					volEnv *= .9988;

					if( volEnv < .001 )
						return true;
				}
				
				//-- ADD AMPLITUDE (MONO)
				sample.left += amplitude;
				sample.right += amplitude;
				
				posFloat += this.tuneValue;
				
				//-- interpolate to avoid clicks
				this.tuneValue += ( tuneValue - this.tuneValue ) * .001;
			}
			
			start = 0;
			
			return false;
		}
		
		public override function getChannel(): int
		{
			return 2 + size;
		}
	}
}