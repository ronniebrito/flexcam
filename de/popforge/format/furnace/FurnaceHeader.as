package de.popforge.format.furnace
{
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	/**
	 * The FurnaceHeader class represents the header of the furnace format.
	 * 
	 * @author Joa Ebert
	 */	
	internal class FurnaceHeader implements IExternalizable
	{
		/**
		* The furnace format identifier (FUR).
		*/		
		public static const IDENTIFIER: String = 'FUR';
		
		/**
		* The identifier that has been read.
		*/		
		internal var _id: String;
		
		/**
		* The filesize of the whole file in bytes.
		*/		
		internal var _size: uint;
		
		/**
		* The version of the format.
		*/		
		internal var _version: Number;
		
		/**
		* Number of files that the current package is containing.
		*/		
		internal var _numFiles: uint;
		
		/**
		 * Creates a new FurnaceHeader object.
		 */		
		public function FurnaceHeader() {}
		
		/**
		 * The identifier of the furnace format.
		 */		
		public function get id(): String
		{
			 return _id;
		}
		
		/**
		 * Filesize in bytes.
		 */		
		public function get size(): uint
		{
			return _size;
		}
		
		/**
		 * Version number.
		 */		
		public function get version(): Number
		{
			return _version;
		}
		
		/**
		 * Number of items in current package.
		 */		
		public function get numFiles(): uint
		{
			return _numFiles;
		}
		
		/**
		 * Writes the furnace header to a given <code>IDataOutput</code> stream.
		 * 
		 * @param output The stream to write to.
		 */		
		public function writeExternal( output: IDataOutput ): void
		{
			output.writeUTFBytes( IDENTIFIER  );
			
			output.writeUnsignedInt( _size );
			
			output.writeFloat( FurnaceFormat.VERSION );
			
			output.writeUnsignedInt( _numFiles );
		}
		
		/**
		 * Reads the furnace header from a given <code>IDataInput</code> stream.
		 * 
		 * @param input The stream to read from.
		 */	
		public function readExternal( input: IDataInput ): void
		{
			if ( ( _id = input.readUTFBytes( 3 ) ) != IDENTIFIER )
				throw new Error( 'Can not parse FurnaceHeader (identifier "' + _id + '" invalid)' );
				
			_size = input.readUnsignedInt();
			
			if ( ( _version = input.readFloat() ) > FurnaceFormat.VERSION )
				throw new Error( 'Can not parse FurnaceHeader (unsupported version)' );
			
			_numFiles = input.readUnsignedInt();
		}
		
		/**
		 * Computes the length of the header in bytes.
		 * 
		 * @return Length of header in bytes.
		 */		
		public function computeLength(): uint
		{
			return	3 + // id
					4 + // size
					4 + // version
					4;  // numFiles
		}
		
		/**
		 * Creates and returns a string representation of the object.
		 * 
		 * @return The string representation of the object.
		 */	
		public function toString(): String
		{
			return '[FurnaceHeader id:' + id + ', size: ' + size + ', numFiles: ' + numFiles + ']';
		}
	}
}