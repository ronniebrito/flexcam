package de.popforge.audio.processor.fl909.memory
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.net.registerClassAlias;
	
	public final class Trigger
		implements IExternalizable
	{
		public var voiceIndex: int;
		public var accent: Boolean;
		
		public function Trigger( voiceIndex: int = -1, accent: Boolean = false )
		{
			this.voiceIndex = voiceIndex;
			this.accent = accent;
		}
		
		public function writeExternal( output: IDataOutput ): void
		{
			output.writeByte( voiceIndex );
			output.writeBoolean( accent );
		}
		
		public function readExternal( input: IDataInput ): void
		{
			voiceIndex = input.readByte();
			accent = input.readBoolean();
		}
		
		public function clone(): Trigger
		{
			return new Trigger( voiceIndex, accent );
		}
	}
}