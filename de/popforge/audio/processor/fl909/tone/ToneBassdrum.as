package de.popforge.audio.processor.fl909.tone
{
	import de.popforge.parameter.MappingNumberExponential;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public class ToneBassdrum extends ToneBase
		implements IExternalizable
	{
		public const tune: Parameter = new Parameter( new MappingNumberLinear( 1, 6 ), 3 );
		public const attack: Parameter = new Parameter( new MappingNumberLinear( 1, 0 ), 1 );
		public const decay: Parameter = new Parameter( new MappingNumberExponential( 512, 8192 ), 4096 );
		
		public override function writeExternal( output: IDataOutput ): void
		{
			super.writeExternal( output );
			tune.writeExternal( output );
			attack.writeExternal( output );
			decay.writeExternal( output );
		}
		
		public override function readExternal( input: IDataInput ): void
		{
			super.readExternal( input );
			tune.readExternal( input );
			attack.readExternal( input );
			decay.readExternal( input );
		}
		
		public override function reset(): void
		{
			super.reset();
			tune.reset();
			attack.reset();
			decay.reset();
		}
	}
}