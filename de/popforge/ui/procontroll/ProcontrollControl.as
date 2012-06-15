package de.popforge.ui.procontroll
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.Endian;
	
	/**
	 * <-+ FIRST IMPLEMENTATION +->
	 * Needs the java application 'AS3ProControll' running as a server
	 */

	public class ProcontrollControl extends Socket
	{
		static public const ACTION_GET_DEVICES: uint = 0x01;
		static public const ACTION_UPDATE_DEVICES: uint = 0x02;
		
		private var host: String;
		private var port: uint;
		
		private var devices: Array;
		private var devicesByName: Object;
		
		public function ProcontrollControl( host: String, port: uint )
		{
			this.host = host;
			this.port = port;
			
			endian = Endian.LITTLE_ENDIAN;
			
			addEventListener( Event.CONNECT, onConnect );
			addEventListener( ProgressEvent.SOCKET_DATA, onData );
			addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			
			connect( host, port );
		}
		
		public function getDeviceById( id: uint ): ProcontrollDevice
		{
			return devices[id];
		}
		
		public function getDeviceByName( name: String ): ProcontrollDevice
		{
			return devicesByName[ name ];
		}
		
		private function onConnect( event: Event ): void
		{
			writeByte( ACTION_GET_DEVICES );
			flush();
		}
		
		private function onData( event: ProgressEvent ): void
		{
			var chunkId: int = readByte();
			
			switch( chunkId )
			{
				case ACTION_GET_DEVICES:
					
					getDevices();
					break;

				case ACTION_UPDATE_DEVICES:
					
					updateDevices();
					break;
			}
			
			//-- loop request
			writeByte( ACTION_UPDATE_DEVICES );
			flush();
		}
		
		private function onIOError( event: IOErrorEvent ): void
		{
			connect( host, port );
		}
		
		private function getDevices(): void
		{
			devices = new Array();
			devicesByName = {};
			
			while( bytesAvailable > 0 )
			{
				var id: int = readByte(); // weird, actually I am sending an int!
				
				var name: String = '';
				var byte: uint;
				
				while( true )
				{
					byte = readByte();
					
					if( byte == 0 )
						break;
	
					name += String.fromCharCode( byte );
				}
				
				var numSliders: uint = readByte();
				var numButtons: uint = readByte();
				var numSticks: uint = readByte();
				
				devices[id] = devicesByName[name] = new ProcontrollDevice( name, numSliders, numButtons, numSticks );
			}
			
			dispatchEvent( new Event( Event.INIT ) );
		}
		
		private function updateDevices(): void
		{
			var device: ProcontrollDevice;
			
			while( bytesAvailable > 0 )
			{
				var id: int = readByte(); // weird, actually I am sending an int!
				
				device = devices[ id ];
				
				device.update( this );
			}
		}
	}
}