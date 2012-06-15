package de.popforge.format.furnace
{
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	
	/**
	 * The FurnaceFormat class can read and write the popforge furnace format.
	 * Since the class implements <code>IExternalizable</code> it can be passed
	 * to a class that implements <coce>IDataInput</code> or <code>IDataOutput</code>.
	 * 
	 * <p>Using <code>registerClassAlias</code> makes calls to <code>IDataInput.readObject()</code>
	 * or <code>IDataOutput.writeObject()</code> possible.</p>
	 * 
	 * <p>The furnace file format supports streaming and has been designed for fast and
	 * easy read access.</p>
	 * 
	 * <p>The file structure is like this:
	 * <ul><li>Header</li><li>Item 0</li><li>Item 1</li><li>...</li><li>Item N</li><li>Data 0</li><li>Data 1</li><li>...</li><li>Data N</li></ul>
	 * Data contains the raw GZip compressed bytes of the actual file.
	 * </p>
	 * 
	 * <p>
	 * Header:
	 * <table class="innertable">
	 * <tr><th>Length</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>3b</td><td><code>String</code></td><td>Identifier (should be "FUR")</td></tr>
	 * <tr><td>4b</td><td><code>uint</code></td><td>Total filesize in bytes (including header)</td></tr>
	 * <tr><td>4b</td><td><code>Number</code></td><td>Format version</td></tr>
	 * <tr><td>4b</td><td><code>uint</code></td><td>Number of files</td></tr>
	 * </table>
	 * </p>
	 * 
	 * <p>
	 * Item:
	 * <table class="innertable">
	 * <tr><th>Length</th><th>Type</th><th>Description</th></tr>
	 * <tr><td>2b</td><td><code>uint</code></td><td>Length of UTF encoded name in bytes</td></tr>
	 * <tr><td>LEN bytes</td><td><code>String</code></td><td>Filename</td></tr>
	 * <tr><td>4b</td><td><code>uint</code></td><td>Position of file data</td></tr>
	 * <tr><td>4b</td><td><code>uint</code></td><td>Length of the file in bytes</td></tr>
	 * </table>
	 * </p>
	 * 
	 * <p>
	 * Data:
	 * Raw GZip encoded file data.
	 * </p>
	 * 
	 * @author Joa Ebert
	 */	
	public class FurnaceFormat implements IExternalizable
	{
		/**
		* Actual version of the format.
		*/		
		internal static const VERSION: Number = 1.0;
		
		/**
		* A reference to the file header.
		*/		
		internal var _header: FurnaceHeader;
		
		/**
		* Array of <code>FurnaceItem</code> items.
		*/		
		internal var _items: Array;
		
		/**
		 * Array of file content represented as <code>ByteArray</code> objects.
		 */
		internal var _library: Array;
		
		/**
		 * Creates a new FurnaceFormat object.
		 */		
		public function FurnaceFormat()
		{
			_header = new FurnaceHeader;
			_items = new Array;
			_library = new Array;
		}
		
		/**
		 * The number of items in the package.
		 */		
		public function get numFiles(): uint
		{
			return _header.numFiles;
		}
		
		/**
		 * Returns the file at given item index.
		 *
 		 * @param index The item index.
		 * @return Content of the file.
		 * @throws RangeError If index is out of bounds.
		 */		
		public function fileById( index: uint ): ByteArray
		{
			testBounds( index );
			return _library[ index ];
		}
		
		/**
		 * Returns the file with given name.
		 * 
		 * In order to find the file all items are searched
		 * for the given name and returns the first occurence.
		 * 
		 * If no file is found an error will be thrown.
		 * 
		 * @param fileName A filename.
		 * @throws Error If no file with given name exists.
		 * @return Content of the file.
		 */		
		public function fileByName( fileName: String ): ByteArray
		{
			var i: int, n: uint;

			i = -1;
			n = _items.length;
			
			for (;i<n;++i)
			{
				if( i == -1 ) // added by aM
					continue;
				
				if ( FurnaceItem( _items[ i ] ).fileName == fileName )
				{
					break;
				}
			}
			
			if ( i == -1 )
			{
				throw new Error( 'File does not exist.' );
			}
			
			return _library[ i ];
		}
		
		/**
		 * Returns the filename at given index.
		 * 
		 * @param index The index of the file.
		 * @return Filename at given index.
		 * @throws RangeError If index is out of bounds.
		 */		
		public function fileName( index: uint ): String
		{
			testBounds( index );
			return FurnaceItem( _items[ index ] ).fileName;	
		}
		
		/**
		 * Adds a new file to the format.
		 * 
		 * @param file Contents of the file.
		 * @param name Name of the file.
		 * @return Index of the new file.
		 */		
		public function addFile( file: ByteArray, name: String ): uint
		{
			var item: FurnaceItem = new FurnaceItem;
			item._fileName = name;
			
			for ( var i: uint = 0; i < _items.length; ++i )
			{
				if ( FurnaceItem( _items[ i ] ).fileName == name )
				{
					throw new Error( 'A file with that name already exists.' );
				}
			}
			
			_items.push( item );
			return ( _library.push( file ) - 1 );
		}
		
		/**
		 * Tests if an index is out of bounds.
		 * 
		 * @param index Index to test.
		 * @throws RangeError If index is out of bounds.
		 */		
		protected function testBounds( index: uint ): void
		{
			if ( index < 0 || index >= _library.length )
			{
				throw new RangeError( 'index is out of bounds.' );
			}
		}
		
		/**
		 * Writes the furnace format to a given <code>IDataOutput</code> stream.
		 * 
		 * @param output The stream to write to.
		 */		
		public function writeExternal( output: IDataOutput ): void
		{
			var i: uint, n: uint;
			var totalLength: uint = 0;
			var headerAndItems: uint = 0;
			var item: FurnaceItem;
			var bytes: ByteArray;
			
			if ( _items.length != _library.length )
				throw new Error( 'Items and data must have the same length.' );
				
			compressLibrary();
			
			//-- BEGIN COMPUTE TOTAL LENGTH
			n = _items.length;
			totalLength += _header.computeLength();

			for ( i = 0; i < n; ++i )
			{
				totalLength += FurnaceItem( _items[ i ] ).computeLength();
			}
			
			headerAndItems = totalLength;
			
			for ( i = 0; i < n; ++i )
			{
				totalLength += ByteArray( _library[ i ] ).length;
			}
			//-- END COMPUTE TOTAL LENGTH
			
			_header._size = totalLength;
			_header._numFiles = n;
			
			_header.writeExternal( output );
			
			for ( i = 0; i < n; ++i )
			{
				var index: uint = headerAndItems;
				var j: uint = 0;
				
				for (;j<i;++j)
					index += ByteArray( _library[ j ] ).length;
					
				item = _items[ i ];
				
				item._index = index;
				item._size = ByteArray( _library[ i ] ).length;
				
				item.writeExternal( output );
			}
			
			for ( i = 0; i < n; ++i )
			{
				bytes = _library[ i ];
				bytes.position = 0;
				
				output.writeBytes( bytes, 0, bytes.length );
			}
		}
		
		/**
		 * Reads the furnace format from a given <code>IDataInput</code> stream.
		 * 
		 * @param input The stream to read from.
		 */		
		public function readExternal( input: IDataInput ): void
		{
			var i: uint, n: uint;
			
			if ( input.bytesAvailable < _header.computeLength() )
				throw new Error( 'Can not read header (streaming not implemented yet).' );
				
			_header.readExternal( input );
			
			if ( input.bytesAvailable < ( _header.size - _header.computeLength() ) )
				throw new Error( 'Can not read body (streaming not implemented yet).' );
			
			n = _header.numFiles;
			
			_items = new Array( n );
			_library = new Array( n );
			
			for ( i = 0; i < n; ++i )
			{
				var item: FurnaceItem = new FurnaceItem;
				
				item.readExternal( input );
				
				_items[ i ] = item;
			}
			
			for ( i = 0; i < n; ++i )
			{
				var bytes: ByteArray = new ByteArray;
				
				input.readBytes( bytes, _items[ i ], FurnaceItem( _items[ i ] )._size );
				
				_library[ i ] = bytes;
			}
			
			uncompressLibrary();
		}
		
		/**
		 * Compresses all objects that are in the library.
		 */		
		protected function compressLibrary(): void
		{
			var i: uint, n: uint;
			
			i = 0;
			n = _library.length;
			
			for (;i<n;++i)
			{
				ByteArray( _library[ i ] ).compress();
			}
		}
		
		/**
		 * Uncompresses all objects that are in the library.
		 */		
		protected function uncompressLibrary(): void
		{
			var i: uint, n: uint;
			
			i = 0;
			n = _library.length;
			
			for (;i<n;++i)
			{
				ByteArray( _library[ i ] ).uncompress();
				ByteArray( _library[ i ] ).position = 0;
			}
		}
		
		/**
		 * Creates and returns a string representation of the object.
		 * 
		 * @return The string representation of the object.
		 */		
		public function toString(): String
		{
			return '[FurnaceFormat header: ' + _header.toString() + ']';
		}
	}
}
/*
	==========================
	Furnace File Specification
	==========================

	Version: 1.0

	Description:	Furnace is a container format for ActionScript 3.
			All types are listed as ActionScript 3 types.

	### TYPES ###
	
	File format is built from types. The header occurs only once while
	items and data can appear "Number of files"-times.

	Encoding is LITTLE ENDIAN.


	Index		Length		Type		Description

	=========
	HEADER
	=========

	+ 0x0000	3b		String		Identifier (Should be "FUR")
	+ 0x0003	4b		File size	Total size of the file (including header)
	+ 0x0004	4b		Number		Version
	+ 0x0004	4b		uint		Number of files

	=========
	ITEM
	=========

	+ 0x0000	2b		uint		Length of Name (=LEN)
	+ 0x0002	LEN bytes	String		Filename
	+    LEN	4b		uint		Index of file data
	+  LEN+4	4b		uint 		Length of file

	=========
	DATA
	=========

	+ 0x00000	Length		ByteArray	GZip compressed content
			  of				of file
			 File


	### FILE LAYOUT ###
	
	HEADER
	ITEM 0
	ITEM 1
	  .
	  .
	ITEM N
	DATA 0
	DATA 1
	  .
	  .
	DATA N
*/