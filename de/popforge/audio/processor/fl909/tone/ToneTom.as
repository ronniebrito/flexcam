package de.popforge.audio.processor.fl909.tone
{
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public final class ToneTom extends ToneBase
		implements IExternalizable
	{
		public const tune: Parameter = new Parameter( new MappingNumberExponential( .75, 1.3 ), 1 );
		public const decay: Parameter = new Parameter( new MappingNumberLinear( .3, 1 ), .75 );
		
		public override function writeExternal( output: IDataOutput ): void
		{
			super.writeExternal( output );
			tune.writeExternal( output );
			decay.writeExternal( output );
		}
		
		public override function readExternal( input: IDataInput ): void
		{
			super.readExternal( input );
			tune.readExternal( input );
			decay.readExternal( input );
		}
		
		public override function reset(): void
		{
			super.reset();
			tune.reset();
			decay.reset();
		}
	}
}