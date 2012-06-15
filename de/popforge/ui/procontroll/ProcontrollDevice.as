package de.popforge.ui.procontroll
{
	import flash.net.Socket;
	
	public class ProcontrollDevice
	{
		private var name: String;
		private var numSliders: uint;
		private var numButtons: uint;
		private var numSticks: uint;
		
		public const sticks: Array = new Array();
		
		private var buttonByte: uint;
		
		public function ProcontrollDevice( name: String, numSliders: uint, numButtons: uint, numSticks: uint )
		{
			this.name = name;
			this.numSliders = numSliders;
			this.numButtons = numButtons;
			this.numSticks = numSticks;
			
			init();
		}
		
		public function isButtonPressed( id: uint ): Boolean
		{
			id = 1 << id;
			
			return ( buttonByte & id ) == id;
		}
		
		internal function update( socket: Socket ): void
		{
			buttonByte = socket.readUnsignedInt();
			
			var i: int;
			
			var stick: ProcontrollStick;
			
			for( i = 0 ; i < numSticks ; i++ )
			{
				stick = sticks[i];
				stick.setX( socket.readUnsignedInt() / 0xffff );
				stick.setY( socket.readUnsignedInt() / 0xffff );
			}
		}
		
		private function init(): void
		{
			var i: int;
			
			for( i = 0 ; i < numSticks ; i++ )
			{
				sticks.push( new ProcontrollStick() );
			}
		}
	}
}