package de.popforge.ui.procontroll
{
	import de.popforge.parameter.Parameter;
	
	public class ProcontrollStick
	{
		private var parameterX: Parameter;
		private var parameterY: Parameter;
		
		public function ProcontrollStick()
		{
		}
		
		public function setParameterX( parameter: Parameter ): void
		{
			this.parameterX = parameter;
		}
		
		public function setParameterY( parameter: Parameter ): void
		{
			this.parameterY = parameter;
		}
		
		internal function setX( value: Number ): void
		{
			if( parameterX )
				parameterX.setValueNormalized( value );
		}
		
		internal function setY( value: Number ): void
		{
			if( parameterY )
				parameterY.setValueNormalized( value );
		}
	}
}