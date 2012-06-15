package de.popforge.audio.processor.special
{
	import de.popforge.audio.output.Audio;
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.math.Random;
	import de.popforge.parameter.MappingIntLinear;
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	public class ParticleSynth
		implements IAudioProcessor
	{
		public const parameterFrequency: Parameter = new Parameter( new MappingNumberExponential( .001, 8 ), .001 );
		public const parameterAttraction: Parameter = new Parameter( new MappingNumberLinear( 0.00001, 0.005 ), .001 );
		public const parameterChannelOffset: Parameter = new Parameter( new MappingNumberLinear( 0, .25 ), .125 );
		public const parameterParticlesCount: Parameter = new Parameter( new MappingIntLinear( 3, 64 ), 32 );
		public const parameterSeed: Parameter = new Parameter( new MappingIntLinear( 1, 0xfff ), 1 );
				
		private var particles: Array;
		private var phase: Number;
		
		//-- current parameter values for interpolation
		private var frequency: Number;
		private var attraction: Number;
		private var chOffset: Number;
		
		private var volume: Number;
		private var particleCountChangedFlag: Boolean;
		
		public function ParticleSynth()
		{
			init();
		}
		
		public function reset(): void
		{
		}
		
		public function processAudio( samples: Array ): void
		{
			var i: int;
			var j: int;
			var k: int;
			var n: int = samples.length;
			var p: int = particles.length;
			
			var sample: Sample;
			
			var p0: Particle;
			var p1: Particle;
			var force: Number;
			
			var xn: Number;
			var alpha: Number;
			
			var frequency: Number = parameterFrequency.getValue();
			var attraction: Number = parameterAttraction.getValue();
			var chOffset: Number = parameterChannelOffset.getValue();
			
			for( i = 0 ; i < n ; ++i )
			{
				sample = samples[i];
				
				//-- smooth fadeIn-fadeOut to avoid amplitude jumps (click noises)
				if( particleCountChangedFlag )
				{
					var n2: int = n >> 1;
					
					if( i < n2 )
						volume -= 1 / n2;
					else if( i == n2 )
					{
						updatePoles();
						p = particles.length;
					}
					else
						volume += 1 / n2;
				}
				
				if( p == 0 )
					continue;
				
				//-- process particle movements
				for( j = p - 1, k = 0 ; k < p ; j = k, k++ )
				{
					p0 = particles[j];
					p1 = particles[k];
					
					force = ( p1.amplitude - p0.amplitude ) * this.attraction;
					
					p0.velocity += force;
					p1.velocity -= force;
				}
				
				//-- move particles simultaneously
				for each( p0 in particles )
					p0.amplitude += p0.velocity;
				
				//-- LEFT (OFFSET)
				xn = ( phase - this.chOffset ) * p;
				if( xn < 0 ) xn += p;
				j = xn;
				p0 = particles[j++];
				if( j == p ) p1 = particles[0];
				else p1 = particles[j];
				alpha = xn - int(xn);
				sample.left = ( p0.amplitude * ( 1 - alpha ) + p1.amplitude * alpha ) * volume;
				
				//-- RIGHT (OFFSET)
				xn = ( phase + this.chOffset ) * p;
				if( xn >= p ) xn -= p;
				
				j = xn;
				p0 = particles[j++];
				if( j == p ) p1 = particles[0];
				else p1 = particles[j];
				alpha = xn - int(xn);
				sample.right = ( p0.amplitude * ( 1 - alpha ) + p1.amplitude * alpha ) * volume;
				
				//-- add frequency
				phase += this.frequency / Audio.RATE44100;
				phase -= int( phase );
				
				//-- interpolate parameter values
				this.frequency += ( frequency - this.frequency ) * .0005;
				this.attraction += ( attraction - this.attraction ) * .0005;
				this.chOffset += ( chOffset - this.chOffset ) * .0005;
			}
			
			particleCountChangedFlag = false;
		}
		
		private function init(): void
		{
			frequency = parameterFrequency.getValue();
			attraction = parameterAttraction.getValue();
			chOffset = parameterChannelOffset.getValue();
			
			volume = 1;
			particleCountChangedFlag = true;
			
			particles = new Array();
			
			parameterParticlesCount.addChangedCallbacks( onParameterChanged );
		}
		
		private function onParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			if( parameter == parameterParticlesCount )
			{
				particleCountChangedFlag = true;
			}
		}
		
		private function updatePoles(): void
		{
			particles = new Array();
			
			var random: Random = new Random( parameterSeed.getValue() );
			
			var num: int = parameterParticlesCount.getValue();
			
			var particle: Particle;
			
			for( var i: int = 0 ; i < num ; ++i )
			{
				particle = new Particle();
				particle.amplitude = random.getNumber( -.25, .25 );
				particles[i] = particle;
			}
			
			phase = 0;
		}
	}
}

class Particle
{
	public var amplitude: Number = 0.0;
	public var velocity: Number = 0.0;
}