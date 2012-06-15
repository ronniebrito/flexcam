package de.popforge.audio.processor.effects
{
	import de.popforge.audio.output.Sample;
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	/**
	 * @author Andre Michelle
	 * 
	 * based on http://epubl.ltu.se/1402-1773/2003/044/LTU-CUPP-03044-SE.pdf
	 */

	public final class ParametricEQ	
		implements IAudioProcessor
	{
		public const parameterFrequency: Parameter = new Parameter( new MappingNumberExponential( 31, 16000 ), 900 );
		public const parameterGain: Parameter = new Parameter( new MappingNumberLinear( -12, 12 ), 0 );
		public const parameterQ: Parameter = new Parameter( new MappingNumberExponential( .1, 12 ), .5 );

		//-- cooef
		private var a0: Number;
		private var a1: Number;
		private var a2: Number;
		private var a3: Number;
		private var a4: Number;

		//-- history
		private var lxnm1: Number = 0;
		private var lxnm2: Number = 0;
		private var lynm1: Number = 0;
		private var lynm2: Number = 0;
		private var rxnm1: Number = 0;
		private var rxnm2: Number = 0;
		private var rynm1: Number = 0;
		private var rynm2: Number = 0;
		
		public function ParametricEQ()
		{
		}
		
		public function processAudio( samples: Array ): void
		{
			calcCoeffs();
			
			var sample: Sample;
			
			var lxn: Number;
			var lyn: Number;
			var rxn: Number;
			var ryn: Number;
			
			var n: int = samples.length;
			
			for( var i: int = 0 ; i < n ; i++ )
			{
				sample = samples[i];
				
				lxn = sample.left;
				rxn = sample.right;
				
				lyn = ( a3 * lxn + a1 * lxnm1 + a4 * lxnm2 - a1 * lynm1 - a2 * lynm2 ) * a0;
				ryn = ( a3 * rxn + a1 * rxnm1 + a4 * rxnm2 - a1 * rynm1 - a2 * rynm2 ) * a0;
				
				lxnm2 = lxnm1;
				lxnm1 = lxn;
				lynm2 = lynm1;
				rxnm2 = rxnm1;
				rxnm1 = rxn;
				rynm2 = rynm1;
				
				sample.left = lynm1 = lyn;
				sample.right = rynm1 = ryn;
			}
		}
		
		public function reset(): void
		{
			lxnm1 = 0;
			lxnm2 = 0;
			lynm1 = 0;
			lynm2 = 0;
			rxnm1 = 0;
			rxnm2 = 0;
			rynm1 = 0;
			rynm2 = 0;
		}
		
		private function calcCoeffs(): void
		{
			const samplingRate: Number = 44100;
			
			var A: Number = Math.pow( 10, parameterGain.getValue() / 40 );
			var omega: Number = ( 2 * Math.PI * parameterFrequency.getValue() ) / samplingRate;
			var sn: Number = Math.sin( omega );
			var cs: Number = Math.cos( omega );
			
			var alpha: Number = sn / ( 2.0 * parameterQ.getValue() );
			
			a0 = 1 / ( 1 + alpha / A );
			a1 = -2 * cs;
			a2 = 1 - alpha / A;
			a3 = 1 + alpha * A;
			a4 = 1 - alpha * A;
		}
	}
}