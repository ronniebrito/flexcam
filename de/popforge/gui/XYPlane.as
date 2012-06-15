package de.popforge.gui
{
	import de.popforge.parameter.Parameter;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;

	public class XYPlane extends Sprite
	{
		private var xParameter: Parameter;
		private var yParameter: Parameter;
		private var cWidth: int;
		private var cHeight: int;
		private var radius: int;
		
		private var point: Sprite;
		private var ox: int;
		private var oy: int;
		
		public function XYPlane( xParameter: Parameter, yParameter: Parameter, cWidth: int = 100, cHeight: int = 100, radius: int = 8 )
		{
			this.xParameter = xParameter;
			this.yParameter = yParameter;
			this.cWidth = cWidth;
			this.cHeight = cHeight;
			this.radius = radius;

			init();
		}
		
		private function init(): void
		{
			graphics.beginFill( 0x333333 );
			graphics.drawRoundRect( 0, 0, cWidth, cHeight, radius * 2, radius * 2 );
			graphics.endFill();

			point = new Sprite();
			point.graphics.beginFill( 0xffcc00 );
			point.graphics.drawCircle( 0, 0, radius );
			point.graphics.endFill();
			addChild( point );
			
			xParameter.addChangedCallbacks( onParameterChanged );
			yParameter.addChangedCallbacks( onParameterChanged );
			
			updatePoint();
			
			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}
		
		private function onMouseDown( event: MouseEvent ): void
		{
			if( event.target == point )
			{
				ox = point.mouseX;
				oy = point.mouseY;
			}
			else
			{
				ox = 0;
				oy = 0;
			}
			
			startDragging();
		}
		
		private function startDragging(): void
		{
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}
		
		private function whileDragging(): void
		{
			var mx: int = mouseX - ox;
			var my: int = mouseY - oy;
			
			var xValue: Number = ( mx - radius ) / ( cWidth - radius * 2 );
			var yValue: Number = 1 - ( my - radius ) / ( cHeight - radius * 2 );
			
			if( xValue < 0 )
				xValue = 0;
			else if( xValue > 1 )
				xValue = 1;
			
			if( yValue < 0 )
				yValue = 0;
			else if( yValue > 1 )
				yValue = 1;
			
			xParameter.setValueNormalized( xValue );
			yParameter.setValueNormalized( yValue );
		}
		
		private function onStageMouseMove( event: MouseEvent ): void
		{
			whileDragging();
		}
		
		private function onStageMouseUp( event: MouseEvent ): void
		{
			var stage: Stage = event.currentTarget as Stage;
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onStageMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
			
			whileDragging();
		}
		
		private function onParameterChanged( parameter: Parameter, oldValue: *, newValue: * ): void
		{
			updatePoint();
		}
		
		private function updatePoint(): void
		{
			point.x = radius + xParameter.getValueNormalized() * ( cWidth - radius * 2 );
			point.y = radius + ( 1 - yParameter.getValueNormalized() ) * ( cHeight - radius * 2 );
		}
	}
}