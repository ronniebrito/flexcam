package de.popforge.audio.processor.fl909.tone
{
	import de.popforge.parameter.MappingBoolean;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	public class ToneBase
		implements IExternalizable
	{
		public const level: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .75 );
		public const mute: Parameter = new Parameter( new MappingBoolean(), false );
		public const pan: Parameter = new Parameter( new MappingNumberLinear( -1, 1 ), 0 );
		
		public function writeExternal( output: IDataOutput ): void
		{
			level.writeExternal( output );
			mute.writeExternal( output );
			pan.writeExternal( output );
		}
		
		public function readExternal( input: IDataInput ): void
		{
			level.readExternal( input );
			mute.readExternal( input );
			pan.readExternal( input );
		}
		
		public function reset(): void
		{
			level.reset();
			mute.reset();
			pan.reset();
		}
	}
}