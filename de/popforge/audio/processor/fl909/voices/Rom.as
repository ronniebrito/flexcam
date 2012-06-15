package de.popforge.audio.processor.fl909.voices
{
	import de.popforge.format.furnace.FurnaceFormat;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class Rom
	{
		static internal function getAmplitudesByName( name: String ): Array
		{
			switch( name )
			{
				case '909.bd.noise.raw':
				case '909.bd.grain.raw':
				case '909.clap.raw':
				case '909.rim.raw':
				case '909.sd.raw':
				case '909.tl.raw':
				case '909.tm.raw':
				case '909.th.raw':
				case '909.ch.raw':
					return convert16Bit( furnace.fileByName( name ) );

				case '909.cr.raw':
				case '909.oh.raw':
				case '909.ri.raw':
					return convert8Bit( furnace.fileByName( name ) );
			}
			
			return null;
		}
		
		[Embed(source="sm.rom", mimeType="application/octet-stream")] static private const Furnace: Class;
		
		static private const furnace: FurnaceFormat = new FurnaceFormat();
		
		{ furnace.readExternal( new Furnace() ); }

		static private function convert8Bit( data: ByteArray ): Array
		{
			var amplitudes: Array = new Array();
			
			var n: int = data.length;
			
			for( var i: int = 0 ; i < n ; i++ )
			{
				//-- RAW is encoded in Unsigned8Bit Mono
				amplitudes.push( ( 127 - data[i] ) / 127 );
			}
			
			return amplitudes;
		}
		
		static private function convert16Bit( data: ByteArray ): Array
		{
			data.endian = Endian.LITTLE_ENDIAN;
			
			var amplitudes: Array = new Array();
			
			var n: int = data.length >> 1;
			
			for( var i: int = 0 ; i < n ; i++ )
			{
				//-- RAW is encoded in signed16Bit Mono
				amplitudes.push( data.readShort() / 0x7fff );
			}
			
			return amplitudes;
		}
	}
}