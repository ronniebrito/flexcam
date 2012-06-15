package de.popforge.audio.processor.fl909.tone
{
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public class ToneSnaredrum extends ToneBase
		implements IExternalizable
	{
		public const tune: Parameter = new Parameter( new MappingNumberExponential( .75, 1.3 ), 1 );
		public const tone: Parameter = new Parameter( new MappingNumberLinear( .999, .9996 ), .9996 );
		public const snappy: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), 1 );
		
		public override function writeExternal( output: IDataOutput ): void
		{
			super.writeExternal( output );
			tune.writeExternal( output );
			tone.writeExternal( output );
			snappy.writeExternal( output );
		}
		
		public override function readExternal( input: IDataInput ): void
		{
			super.readExternal( input );
			tune.readExternal( input );
			tone.readExternal( input );
			snappy.readExternal( input );
		}
		
		public override function reset(): void
		{
			super.reset();
			tune.reset();
			tone.reset();
			snappy.reset();
		}
	}
}