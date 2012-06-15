/**
 * Copyright(C) 2007 Andre Michelle and Joa Ebert
 *
 * PopForge is an ActionScript3 code sandbox developed by Andre Michelle and Joa Ebert
 * http://sandbox.popforge.de
 * 
 * This file is part of PopforgeAS3Audio.
 * 
 * PopforgeAS3Audio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 * 
 * PopforgeAS3Audio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
package de.popforge.fui
{
	import de.popforge.format.furnace.FurnaceFormat;
	import de.popforge.fui.core.FuiComponent;
	import de.popforge.fui.core.IFormatterBindable;
	import de.popforge.fui.core.IFuiSkin;
	import de.popforge.fui.core.IInterpolationBindable;
	import de.popforge.fui.core.IParameterBindable;
	import de.popforge.fui.core.IStringBindable;
	import de.popforge.interpolation.Interpolation;
	import de.popforge.parameter.Parameter;
	import de.popforge.utils.Formatter;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	/**
	 * The Fui class is able to read and parse special Furnace files that contain
	 * a skin plus configuration. Such a file is basically generated in an external
	 * editor.
	 * 
	 * The rendering of all components may not be done synchronous since there is an
	 * asynchronous call involved in this process. However the delay should be max one
	 * frame.
	 * 
	 * @author Joa Ebert
	 */	
	final public class Fui extends Sprite
	{
		/**
		 * Builds and returns a Fui object.
		 * 
		 * @param furnaceFile A ByteArray object containing a Furnace file.
		 * @return A Fui object containing all components.
		 */		
		public static function build( furnaceFile: ByteArray ): Fui
		{
			var fui: Fui = new Fui;
			
			var assets: FurnaceFormat = new FurnaceFormat;
			assets.readExternal( furnaceFile );
			
			if ( assets.numFiles != 2 )
			{
				throw new Error( 'Invalid Furnace file.' );
			}
		
			fui.xml = XML( assets.fileByName( 'config' ) );
			fui.swf = assets.fileByName( 'factory' );
			
			fui.buildInternal();
			
			return fui;
		}
		
		/**
		 * Builds and returns a Fui object.
		 * This function is used mainly for debugging purposes.
		 * 
		 * On the other hand this call is absolute synchronous without
		 * any queus in between.
		 * 
		 * @param xml The Fui XML file.
		 * @param skin An instance of a skin object implementing 
		 * @return A Fui object containing all components. 
		 * 
		 */		
		public static function buildManual( xml: XML, skin: IFuiSkin ): Fui
		{
			var fui: Fui = new Fui;
			
			fui.xml = xml;
			fui.skin = skin;
			
			fui.buildInternal();
			
			return fui;
		}
		
		private var xml: XML;
		private var swf: ByteArray;
		
		private var skin: IFuiSkin;
		
		private var components: Array;
		private var numComponents: uint;
		
		private var debugGraphics: Graphics;
		
		private var initialized: Boolean;
		private var connectQueue: Array;
		
		/**
		 * Creates a new Fui object.
		 * The constructor should never be called. Use <code>Fui.build()</code> instead.
		 */		
		public function Fui()
		{
			initialized = false;
			components = new Array;
			connectQueue = new Array;
		}
		
		/**
		 * Returns a component for the given name.
		 * 
		 * @param name The name of the component.
		 * @return The component corresponding to the given name
		 * @throws TypeError If no component with given name exists.
		 * 
		 */		
		public function getElementById( name: String ): FuiComponent
		{
			return FuiComponent( getChildByName( name ) );
		}
		
		/**
		 * Connects a Fui component with a given value.
		 * 
		 * There are different Fui components that can connect with
		 * different values. Depending on the interfaces a component
		 * implements it can be connected with a different value.
		 * 
		 * Components that implement IParameterBindable can be connected
		 * to Paramter objects.
		 * 
		 * Components that implement IStringBindable can be connected to
		 * String primitives.
		 * 
		 * Connects are called after the skin has been initialized. They will
		 * be hold in a queue until the components are ready.
		 * 
		 * @param name The name of the component.
		 * @param value The value to connect with that component.
		 * 
		 * @throws TypeError If no component with given name exists.
		 * @throws Error If component can not be connected with given value.
		 * @throws Error If component is from unknown type or unsupported.
		 */		
		public function connect( name: String, value: * ): void
		{
			if ( !initialized )
			{
				connectQueue.push( new QueueItem( name, value ) );
				return;
			}
			
			var component: FuiComponent = getElementById( name );
			
			if ( component is IParameterBindable )
			{
				IParameterBindable( component ).connect( Parameter( value ) );
			}
			else
			if ( component is IStringBindable )
			{
				IStringBindable( component ).connect( String( value ) );
			}
			else
			if ( component is IFormatterBindable )
			{
				if ( value is String )
				{
					IFormatterBindable( component ).connect( new Formatter( String( value ) ) );
				}
				else
				{
					IFormatterBindable( component ).connect( Formatter( value ) );
				}
			}
			else
			if ( component is IInterpolationBindable )
			{
				IInterpolationBindable( component ).connect( Interpolation( value ) );
			}
			else
			{
				throw new Error( 'Unknown FuiComponent type. Can not bind.' );
			}
		}
		
		/**
		 * Removes all references recursive. This way a Fui object should be
		 * collected by the garbage collection if it is no longer needed.
		 */		
		public function dispose(): void
		{
			var i: int = 0;
			var n: int = numComponents;
			
			var component: FuiComponent;
			
			for (;i<n;++i)
			{
				component = components[ i ];
				
				component.dispose();
				
				removeChild( component );
				
				components[ i ] = null;
			}
			
			component = null;
			components[ i ] = null;
		}
		
		/**
		 * Initializes parsing of the config and loading of the assets.
		 */		
		private function buildInternal(): void
		{
			if ( skin != null )
			{
				buildComponents();
			}
			
			if ( swf != null )
			{
				var factoryLoader: Loader = new Loader();
			
				factoryLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, onFactoryComplete );
				factoryLoader.loadBytes( swf, new LoaderContext( false, ApplicationDomain.currentDomain ) );
			}
		}
		
		/**
		 * Builds all components based on their entry in the config.
		 */		
		private function buildComponents(): void
		{
			var list: XMLList = xml.component;
			var params: XML;
			var component: FuiComponent;
			var clazz: Class;
			
			for each ( params in list )
			{
				switch ( String( params.@type ).toLowerCase() )
				{
					case 'hslider':
						component = skin.createHSlider( params );
						break;

					case 'vslider':
						component = skin.createVSlider( params );
						break;
											
					case 'knob':
						component = skin.createKnob( params );
						break;
						
					case 'label':
						component = skin.createLabel( params );
						break;
					
					case 'switchbutton':
						component = skin.createSwitchButton( params );
						break;
					
					case 'triggerbutton':
						component = skin.createTriggerButton( params );
						break;
					
					case 'interpolationdisplay':
						component = skin.createInterpolationDisplay( params );
						break;
							
					default:
						throw new Error( 'Unknown component type "' + String( params.@type ) + '"' );
				}
				
				component.x = uint( params.@x );
				component.y = uint( params.@y );
				
				component.rows = uint( params.@rows );
				component.cols = uint( params.@cols );
				
				component.name = String( params.@name );
				
				component.tag = params;
				
				addChild( component );
				components.push( component );
			}
			
			numComponents = components.length;
			
			var debugShape: Shape = new Shape;
			debugShape.name = '__FUI__DEBUG__SHAPE__';
			addChild( debugShape );
			
			debugGraphics = debugShape.graphics;
			
			// Free some memory here. We will never use the XML again.
			xml = null;
			
			renderComponents();
		}
		
		/**
		 * Renders all components.
		 */		
		private function renderComponents(): void
		{
			var i: int = 0;
			var n: int = numComponents;
			
			var component: FuiComponent;
			
			for (;i<n;++i)
			{
				component = components[ i ];
				
				component.x *= skin.tileSize; 
				component.y *= skin.tileSize;

				component.skin = skin;
			}
			
			initialized = true;
			
			for each ( var queueItem: QueueItem in connectQueue )
			{
				connect( queueItem.name, queueItem.value )
			}
			
			connectQueue = null;
		}
		
		/**
		 * Draws the bounding box of every <code>DisplayObject</code> object and its registration point
		 * that belongs to the current <code>Fui</code> object.
		 */		
		public function debugComponents(): void
		{
			var i: int = 0;
			var n: int = numComponents;
			
			var component: FuiComponent;
			
			for (;i<n;++i)
			{
				component = components[ i ];
				debugInternal( component );
			}
		}
		
		private function debugInternal( displayObject: DisplayObject ): void
		{
			var rect: Rectangle = displayObject.getRect( this );
			var regPoint: Point = globalToLocal( displayObject.localToGlobal( new Point( 0, 0 ) ) );
			
			debugGraphics.lineStyle( 1, 0xff00ff );
			debugGraphics.drawRect( rect.x, rect.y, rect.width, rect.height );
			
			debugGraphics.lineStyle( 1, 0xff0000 );
			debugGraphics.moveTo( regPoint.x - 2, regPoint.y );
			debugGraphics.lineTo( regPoint.x + 3, regPoint.y );
			debugGraphics.moveTo( regPoint.x, regPoint.y - 2 );
			debugGraphics.lineTo( regPoint.x, regPoint.y + 3 );
			
			if ( displayObject is DisplayObjectContainer )
			{
				var container: DisplayObjectContainer = DisplayObjectContainer( displayObject );
				
				for ( var i: int = 0; i < container.numChildren; ++i )
				{
					debugInternal( container.getChildAt( i ) );
				}
			}
		}
		
		/**
		 * A listener for the completion of the asset factory.
		 * Once this listener gets executed the <code>Manifest</code> definition
		 * is pulled from the loaded SWF and a new object of a factory
		 * will be created using <code>Manifest.FACTORY_CLASS</code>.
		 * 
		 * @param event An <code>Event</code> object dispatched by the Adobe Flash Player.
		 */		
		private function onFactoryComplete( event: Event ): void
		{
			var factoryLoader: Loader = LoaderInfo( event.target ).loader;
			factoryLoader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onFactoryComplete );
			
			var manifest: Class = Class( factoryLoader.contentLoaderInfo.applicationDomain.getDefinition( 'Manifest' ) );

			skin = IFuiSkin( new manifest[ 'FACTORY_CLASS' ] );
			
			// Free some memory. We do not need that ByteArray again.
			swf = null;
			
			// Skin should not be null any longer. Try to build again.
			buildInternal();
		}
	}
}

class QueueItem
{
	public var name: String;
	public var value:*;
	
	public function QueueItem( name: String, value:* )
	{
		this.name = name;
		this.value = value;
	}
}