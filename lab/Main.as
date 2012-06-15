package
{
	import de.popforge.imageprocessing.capture.ICaptureDevice;
	import de.popforge.imageprocessing.capture.WebCam;
	import de.popforge.imageprocessing.core.Histogram;
	import de.popforge.imageprocessing.core.Image;
	import de.popforge.imageprocessing.core.ImageFormat;
	import de.popforge.imageprocessing.filters.*;
	import de.popforge.imageprocessing.filters.binarization.*;
	import de.popforge.imageprocessing.filters.color.*;
	import de.popforge.imageprocessing.filters.convolution.*;
	import de.popforge.imageprocessing.filters.noise.*;
	import de.popforge.imageprocessing.utils.FormatTest;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
		
	[SWF(frameRate='120',width='800',height='600',backgroundColor='0x333333')]
	
	public class Main extends Sprite
	{
		//-- test environment
		private const videoWidth: int = 160;
		private const videoHeight: int = 120;
		private const imageFormat: int = ImageFormat.RGB;
		private const showHistograms: Boolean = false;
		private const queue: FilterQueue = new FilterQueue();
		
		//-- display stuff
		private var debugField: TextField;
		private var fpsCount: int;
		private var fpsTime: int;
		private var fpsDisplay: int;
		private var image: Image;
		private var screen: BitmapData;
		private var screenBitmap: Bitmap;
		private var translate: Matrix;	
		private var video: ICaptureDevice;
			
		public function Main()
		{
			initEnvironment();
			initScreen();
			initFilters();
			
			resetFps();
						
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		private function initEnvironment(): void
		{			
			stage.quality = StageQuality.LOW;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			if ( showHistograms )
				screen = new BitmapData( videoWidth + 0x100, videoHeight << 1, false, 0 );
			else
				screen = new BitmapData( videoWidth, videoHeight << 1, false, 0 );
			
			screenBitmap = new Bitmap( screen );
			screenBitmap.x = stage.stageWidth / 2 - screen.width / 2;
			screenBitmap.y = stage.stageHeight / 2 - screen.height / 2;
			
			addChild( screenBitmap );
			
			var title: TextField = new TextField;
			debugField = new TextField();
			var tf: TextFormat = new TextFormat;
			
			title.x = 10;
			title.y = 10;
			title.width = 640;
			title.selectable = false;
			title.textColor = 0xcccccc;
						
			tf.size = 10;
			tf.bold = true;
			tf.font = 'Verdana';
			
			title.defaultTextFormat = tf;
			title.text = 'de.popforge.imageprocessing Laboratory';
				
			debugField.x = title.x;
			debugField.y = title.y + title.textHeight;
			debugField.width = 640;
			debugField.selectable = false;
			debugField.textColor = 0xcccccc;
			
			tf.bold = false;
			
			debugField.defaultTextFormat = tf;
					
			addChild( title );
			addChild( debugField );
		}
		
		private function initScreen(): void
		{		
			image = new Image( videoWidth, videoHeight, imageFormat );
			video = new WebCam( videoWidth, videoHeight );
			translate = new Matrix();
			
			Histogram.DETAIL = 4;
		}
		
		private function initFilters(): void
		{
			queue.enableOutput( debugField );
			
			//-- color
			//queue.addFilter( new BrightnessCorrection( 0x40, true ) );
			//queue.addFilter( new ContrastCorrection( 1.5 ) );
			//queue.addFilter( new Extract( 0xffffff ) );
			//queue.addFilter( new GammaCorrection( 2.2, true ) );
			//queue.addFilter( new Infrared() );
			//queue.addFilter( new Invert() );
			//queue.addFilter( new LevelsCorrection( true ) );
			//queue.addFilter( new Normalize( 0xff ) );
			//queue.addFilter( new QuickSepia() );
			//queue.addFilter( new Sepia() );
			
			//-- convolution											
			//queue.addFilter( new Blur() );
			//queue.addFilter( new ConvolutionBlur( 4 ) );
			//queue.addFilter( new Edges() );
			//queue.addFilter( new Emboss() );
			//queue.addFilter( new Sharpen( .5 ) );
			
			//-- simplify
			//queue.addFilter( new Pixelate( 4 ) );
		}
		
		private function resetFps(): void
		{
			fpsTime = getTimer();
			fpsCount = 0;
			fpsDisplay = 0;
		}
		
		private function updateFps(): void
		{
			if( getTimer() - 1000 > fpsTime )
			{
				fpsTime = getTimer();
				fpsDisplay = fpsCount;
				fpsCount = 0;
			}
			else
				++fpsCount;
		}
		
		private function onEnterFrame( event: Event ): void
		{
			var t0: Number;
			var t1: Number;
			var tmp: BitmapData;
			
			updateFps();
			debugField.text = 'fps: ' + fpsDisplay + '\n';
			

			t0 = getTimer();
			
			image.loadBitmapData( video.getCurrentFrame(), true );
			
			t1 = getTimer();
			debugField.appendText( 'convert: ' + ( t1 - t0 ) + 'ms\n' );
			
			//-- draw original image
			image.render( screen );
							
			//-- draw original histogram
			if ( showHistograms )
			{
				translate.identity();
				translate.translate( videoWidth, 0 );
				
				t0 = getTimer();
				
				image.updateHistogram();
				
				t1 = getTimer();
				debugField.appendText( 'histogram: ' + ( t1 - t0 ) + 'ms\n' );
					
				tmp = image.histogram.getBitmapData( 0x100, videoHeight );
				screen.draw( tmp, translate );
				tmp.dispose();
			}
			
			//-- apply filter queue
			queue.apply( image );
						
			//-- draw filtered histogram
			if ( showHistograms )
			{
				translate.identity();
				translate.translate( videoWidth, videoHeight );
				
				t0 = getTimer();
				
				image.updateHistogram();
				
				t1 = getTimer();
				debugField.appendText( 'histogram: ' + ( t1 - t0 ) + 'ms\n' );
					
				tmp = image.histogram.getBitmapData( 0x100, videoHeight );
				screen.draw( tmp, translate );
				tmp.dispose();
			}
			
			//-- draw resulting image
			translate.identity();
			translate.translate( 0, videoHeight );
			
			tmp = image.bitmapData;
			screen.draw( tmp, translate );
			tmp.dispose();
		}
	}
}
