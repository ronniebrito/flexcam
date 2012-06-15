package de.popforge.audio.processor.fl909.memory
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.net.registerClassAlias;
	
	public final class Pattern
		implements IExternalizable
	{
		public var steps: Array;
		public var length: uint;
		
		public function Pattern( length: uint = 16 )
		{
			this.length = length;
			this.steps = new Array();
		}
		
		public function writeExternal( output: IDataOutput ): void
		{
			output.writeObject( steps );
			output.writeByte( length );
		}
		
		public function readExternal( input: IDataInput ): void
		{
			steps = input.readObject();
			length = input.readByte();
		}
		
		public function clone(): Pattern
		{
			var copy: Pattern = new Pattern( length );
			
			var trigger: Trigger;
			var triggers: Array;
			
			for( var i: int = 0 ; i < length ; i++ )
			{
				triggers = copy.steps[i] = new Array();
				
				for each( trigger in steps[i] )
				{
					triggers.push( trigger.clone() );
				}
			}
			
			return copy;
		}
	}
}