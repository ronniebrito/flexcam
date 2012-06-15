package de.popforge.audio.processor.effects
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;

	public class Flanger
		implements IAudioProcessor
	{
		public const parameterDelay: Parameter = new Parameter( new MappingNumberLinear( 1, 10 ), 1 ); // ms
		public const parameterDepth: Parameter = new Parameter( new MappingNumberLinear( .2, 1 ), .8 );
		public const parameterSpeed: Parameter = new Parameter( new MappingNumberLinear( 24, .5 ), 6 ); // sec
		public const parameterFeedback: Parameter = new Parameter( new MappingNumberLinear( 0, .86 ), .2 );
		public const parameterMix: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .5 );
		
		//-- delay lines
		private const bufferL: Array = new Array();
		private const bufferR: Array = new Array();
		
		//-- write position
		private var write: int;
		
		//-- lfo phase
		private var phase: Number;
		
		//-- constructor
		public function Flanger()
		{
			reset();
		}
		
		//-- compute effect
		public function processAudio( samples: Array ): void
		{
			var n: int = samples.length;
			
			var sample: Sample;
			
			var readL: int;
			var readR: int;
			
			var sl: Number;
			var sr: Number;
			var fl: Number;
			var fr: Number;
			
			var bl: Float;
			var br: Float;
			
			//-- grap parameter values
			var delay: Number = parameterDelay.getValue() * 44100 / 1000;
			var depth: Number = parameterDepth.getValue();
			var phaseShift: Number = 1 / ( 44100 * parameterSpeed.getValue() );
			var feedback: Number = parameterFeedback.getValue();
			var mix: Number = parameterMix.getValue();
			var mixm: Number = 1 - mix;
			
			var a: Number;
			
			for each( sample in samples )
			{
				bl = bufferL[write];
				br = bufferR[write];
				
				//-- write in buffer
				sl = bl.value = sample.left;
				sr = br.value = sample.right;
				
				//-- triangle lfo
				a = ( phase - int( phase ) ) * 4;
				if( a < 2 ) a -= 1;
				else a = 3 - a;
				
				//-- advance lfo
				phase += phaseShift;
				
				//-- apply depth & delay
				a *= depth * delay;
				
				//-- compute read position
				readL = write - ( delay + a );
				readR = write - ( delay - a );
				
				//--clamp position into delay lines
				if( readL < 0 )
					readL += 0xfff;
				if( readR < 0 )
					readR += 0xfff;
				
				//-- get amplitudes at read position
				fl = Float( bufferL[ readL ] ).value;
				fr = Float( bufferR[ readR ] ).value;
				
				//-- feedback
				bl.value += fl * feedback;
				br.value += fr * feedback;
				
				//-- mix into stream (wet/dry)
				sample.left = mixm * sl + fl * mix;
				sample.right = mixm * sr + fr * mix;
				
				//-- cycle delay line
				if( ++write == 0xfff )
					write = 0;
			}
		}
		
		public function reset():void
		{
			for( var i: int = 0 ; i < 0xfff ; i++ )
			{
				bufferL[i] = new Float();
				bufferR[i] = new Float();
			}
			
			write = 0;
			phase = 0.0;
		}
	}
}

/**
 * This boost the performance 5 times!
 */
class Float
{
	public var value: Number = .0;
}