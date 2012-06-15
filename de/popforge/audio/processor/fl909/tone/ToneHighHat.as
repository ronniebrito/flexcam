package de.popforge.audio.processor.fl909.tone
{
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public class ToneHighHat extends ToneBase
		implements IExternalizable
	{
		public const tune: Parameter = new Parameter( new MappingNumberExponential( .75, 1.3 ), 1 );
		public const decayCL: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .2 );
		public const decayOP: Parameter = new Parameter( new MappingNumberLinear( .1, 1 ), .4 );
		
		public override function writeExternal( output: IDataOutput ): void
		{
			super.writeExternal( output );
			tune.writeExternal( output );
			decayCL.writeExternal( output );
			tune.writeExternal( output );
		}
		
		public override function readExternal( input: IDataInput ): void
		{
			super.readExternal( input );
			tune.readExternal( input );
			decayCL.readExternal( input );
			decayOP.readExternal( input );
		}
		
		public override function reset(): void
		{
			super.reset();
			tune.reset();
			decayCL.reset();
			decayOP.reset();
		}
	}
}