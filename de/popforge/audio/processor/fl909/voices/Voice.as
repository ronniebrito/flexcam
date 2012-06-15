package de.popforge.audio.processor.fl909.voices
{
	public class Voice
	{
		protected var start: int;
		protected var volume: Number;
		
		protected var position: int;
		protected var length: int;
		
		protected var stop: int = int.MAX_VALUE;
		
		protected var monophone: Boolean;
		
		public function Voice( start: int, volume: Number = 0 )
		{
			this.start = start;
			this.volume = volume;
			
			position = 0;
			length = int.MAX_VALUE;
		}
		
		public function processAudioAdd( samples: Array ): Boolean
		{
			throw new Error( 'Override processAudioAdd().' );
			
			return true;
		}

		public function isMonophone(): Boolean
		{
			return monophone;
		}
		
		public function getChannel(): int
		{
			throw new Error( 'Override getChannel().' );
			
			return -1;
		}
		
		public function cut( stop: int ): void
		{
			this.stop = stop;
		}
	}
}