package de.popforge.ui
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	
	public class KeyboardShortcut
	{
		static public function createInstance( stage: Stage ): void
		{
			instance = new KeyboardShortcut( stage );
		}
		
		static public function getInstance(): KeyboardShortcut
		{
			return instance;
		}
		
		static private var instance: KeyboardShortcut;
		
		private var stage: Stage;
		
		private const shortcuts: Array = new Array();
		private const table: Dictionary = new Dictionary();
		
		public function KeyboardShortcut( stage: Stage )
		{
			this.stage = stage;
			
			init();
		}
		
		public function addShortcut( callback: Function, keys: Array, ...args ): void
		{
			shortcuts.push( new Shortcut( callback, keys, args ) );
		}
		
		private function init(): void
		{
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onStageKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onStageKeyUp );
		}
		
		private function onStageKeyDown( event: KeyboardEvent ): void
		{
			var code: uint = event.keyCode;
			
			table[ code ] = true;
			
			check();
		}
		
		private function onStageKeyUp( event: KeyboardEvent ): void
		{
			var code: uint = event.keyCode;
			
			table[ code ] = false;
		}
		
		private function check(): void
		{
			var found: Boolean;
			
			for each( var shortcut: Shortcut in shortcuts )
			{
				found = true;
				
				for each( var code: uint in shortcut.keys )
				{
					if( !table[ code ] )
					{
						found = false;
						break;
					}
				}
				if( found )
				{
					shortcut.callback.apply( null, shortcut.args );
				}
			}
		}
	}
}

class Shortcut
{
	public var callback: Function;
	public var keys: Array;
	public var args: Array;
	
	public function Shortcut( callback: Function, keys: Array, args: Array )
	{
		this.callback = callback;
		this.keys = keys;
		this.args = args;
	}
}