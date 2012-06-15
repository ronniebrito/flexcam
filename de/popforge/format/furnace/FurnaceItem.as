package de.popforge.format.furnace
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	/**
	 * The FurnaceItem class represents an item in the furnace format.
	 * 
	 * This class holds informations about a file. For instance it stores the
	 * filename or the index where to start reading the file from.
	 *
	 * @author Joa Ebert
	 */
	internal class FurnaceItem implements IExternalizable
	{
		/**
		* The filename.
		*/		
		internal var _fileName: String;
		
		/**
		* Position of file data in the stream.
		*/		
		internal var _index: uint;
		
		/**
		* Length of file data in bytes.
		*/		
		internal var _size: uint;
	
		/**
		 * Creates a new FurnaceItem object.
		 */	
		public function FurnaceItem() {}
		
		/**
		 * Name of the file.
		 */		
		public function get fileName(): String
		{
			return _fileName;
		}
		
		/**
		 * Position of the file in the stream.
		 * 
		 * The <em>0</em>-position is the beginning of the header.
		 * If your furnace file is in a stream that is containing
		 * other data you can jump manually to a file by using the
		 * index of the furnace file plus the index position of the
		 * item.
		 * 
		 * However this is not needed since all positions are handled
		 * relative.
		 */		
		public function get index(): uint
		{
			return _index;
		}
		
		/**
		 * The filesize in bytes for current item.
		 */		
		public function get fileSize(): uint
		{
			return _size;
		}
		
		/**
		 * Writes a furnace item to a given <code>IDataOutput</code> stream.
		 * 
		 * @param output The stream to write to.
		 */	
		public function writeExternal( output: IDataOutput ): void
		{
			//-- get correct length of utf bytes
			var name: ByteArray = new ByteArray;
			name.writeUTFBytes( _fileName );
			name.position = 0;
			
			output.writeShort( name.length );
			
			output.writeBytes( name, 0, name.length );
			
			output.writeUnsignedInt( _index );
			
			output.writeUnsignedInt( _size );
		}
		
		/**
		 * Reads a furnace item from a given <code>IDataInput</code> stream.
		 * 
		 * @param input The stream to read from.
		 */	
		public function readExternal( input: IDataInput ): void
		{
			_fileName = input.readUTFBytes( input.readUnsignedShort() );
			
			_index = input.readUnsignedInt();
			
			_size = input.readUnsignedInt();
		}
		
		/**
		 * Computes the length of an item in bytes.
		 * 
		 * @return Length of item in bytes.
		 */	
		public function computeLength(): uint
		{
			//-- get correct length of utf bytes
			var name: ByteArray = new ByteArray;
			name.writeUTFBytes( _fileName );
			
			return	2 +  		   // length of name
					name.length +  // name
					4 + 		   // index
					4;   		   // file size
		}
		
		/**
		 * Creates and returns a string representation of the object.
		 * 
		 * @return The string representation of the object.
		 */	
		public function toString(): String
		{
			return '[FurnaceItem fileName: ' + fileName + ', index: 0x' + index.toString(0x10) + ', size:' + fileSize + ']';
		}
	}
}