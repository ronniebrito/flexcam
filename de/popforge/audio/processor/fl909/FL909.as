package de.popforge.audio.processor.fl909
{
	import de.popforge.audio.processor.IAudioProcessor;
	import de.popforge.audio.processor.fl909.memory.Memory;
	import de.popforge.audio.processor.fl909.memory.Trigger;
	import de.popforge.audio.processor.fl909.tone.ToneBase;
	import de.popforge.audio.processor.fl909.tone.ToneBassdrum;
	import de.popforge.audio.processor.fl909.tone.ToneCrash;
	import de.popforge.audio.processor.fl909.tone.ToneHighHat;
	import de.popforge.audio.processor.fl909.tone.ToneRide;
	import de.popforge.audio.processor.fl909.tone.ToneSnaredrum;
	import de.popforge.audio.processor.fl909.tone.ToneTom;
	import de.popforge.audio.processor.fl909.voices.Voice;
	import de.popforge.audio.processor.fl909.voices.VoiceBassdrum;
	import de.popforge.audio.processor.fl909.voices.VoiceClap;
	import de.popforge.audio.processor.fl909.voices.VoiceCrash;
	import de.popforge.audio.processor.fl909.voices.VoiceHiHat;
	import de.popforge.audio.processor.fl909.voices.VoiceRide;
	import de.popforge.audio.processor.fl909.voices.VoiceRimshot;
	import de.popforge.audio.processor.fl909.voices.VoiceSnaredrum;
	import de.popforge.audio.processor.fl909.voices.VoiceTom;
	import de.popforge.parameter.MappingBoolean;
	import de.popforge.parameter.MappingNumberLinear;
	import de.popforge.parameter.Parameter;
	
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.utils.getQualifiedClassName;
	import flash.net.registerClassAlias;
	
	/**
	 * @author Andre Michelle
	 * 
	 * FL909 attempts to simulate the original sound of the Roland TR-909.
	 * This drumcomputer hits the market 1984 and was a long time the state
	 * of art in house and techno productions.
	 */

	public final class FL909
		implements IAudioProcessor, IExternalizable
	{
		/**
		 * FL909 PARAMETER
		 */
		public const volume: Parameter = new Parameter( new MappingNumberLinear( 0, 1 ), .8 );
		public const accent: Parameter = new Parameter( new MappingNumberLinear( .2, .8 ), .5 );
		public const tempo: Parameter = new Parameter( new MappingNumberLinear( 30, 180 ), 127 );
		public const shuffle: Parameter = new Parameter( new MappingNumberLinear( 1, 1.5 ), 1 );
		public const pause: Parameter = new Parameter( new MappingBoolean(), true );

		/**
		 * VOICE TONE COLORS (adjustable parameters each voice)
		 */
		public const toneBassdrum: ToneBassdrum = new ToneBassdrum();
		public const toneSnaredrum: ToneSnaredrum = new ToneSnaredrum();
		public const toneTomLow: ToneTom = new ToneTom();
		public const toneTomMid: ToneTom = new ToneTom();
		public const toneTomHigh: ToneTom = new ToneTom();
		public const toneRimshot: ToneBase = new ToneBase();
		public const toneClap: ToneBase = new ToneBase();
		public const toneHighHat: ToneHighHat = new ToneHighHat();
		public const toneRide: ToneRide = new ToneRide();
		public const toneCrash: ToneCrash = new ToneCrash();

		/**
		 * SEQUENCER
		 */
		public var memory: Memory;
		
		public const stepTimes: Array = new Array();
		private var timeElapsed: Number;
		
		/**
		 * AUDIO
		 */
		private const activeVoices: Array = new Array();
		
		private var sampleOffset: int;
		private var shuffleIndex: int;
		
		public function FL909()
		{
			memory = new Memory( this );
			
			sampleOffset = 0;
			shuffleIndex = 0;
			timeElapsed = .0;
		}
		
		public function isBusy(): Boolean
		{
			return activeVoices.length > 0;
		}
		
		/**
		 * PROCESS AUDIO
		 */
		public function processAudio( samples: Array ): void
		{
			if( !pause.getValue() )
				advancePattern( samples );

			advanceVoices( samples );
		}
		
		/**
		 * RESET MACHINE
		 */
		public function reset(): void
		{
			activeVoices.splice( 0, activeVoices.length );
			
			stepTimes.splice( 0, stepTimes.length );
			
			memory.rewind();
			
			sampleOffset = 0;
			shuffleIndex = 0;
			timeElapsed = .0;
		}
		
		/**
		 * SERIALIZE
		 */
		public function writeExternal( output: IDataOutput ): void
		{
			memory.writeExternal( output );
			
			volume.writeExternal( output );
			accent.writeExternal( output );
			tempo.writeExternal( output );
			shuffle.writeExternal( output );
			
			toneBassdrum.writeExternal( output );
			toneSnaredrum.writeExternal( output );
			toneTomLow.writeExternal( output );
			toneTomMid.writeExternal( output );
			toneTomHigh.writeExternal( output );
			toneRimshot.writeExternal( output );
			toneClap.writeExternal( output );
			toneHighHat.writeExternal( output );
			toneRide.writeExternal( output );
			toneCrash.writeExternal( output );
		}

		/**
		 * DESERIALIZE
		 */
		public function readExternal( input: IDataInput ): void
		{
			memory.readExternal( input );

			volume.readExternal( input );
			accent.readExternal( input );
			tempo.readExternal( input );
			shuffle.readExternal( input );
			
			toneBassdrum.readExternal( input );
			toneSnaredrum.readExternal( input );
			toneTomLow.readExternal( input );
			toneTomMid.readExternal( input );
			toneTomHigh.readExternal( input );
			toneRimshot.readExternal( input );
			toneClap.readExternal( input );
			toneHighHat.readExternal( input );
			toneRide.readExternal( input );
			toneCrash.readExternal( input );
		}
		
		/**
		 * CLEAR
		 */
		public function clear(): void
		{
			memory.clear();
			
			volume.reset();
			accent.reset();
			tempo.reset();
			shuffle.reset();
			
			toneBassdrum.reset();
			toneSnaredrum.reset();
			toneTomLow.reset();
			toneTomMid.reset();
			toneTomHigh.reset();
			toneRimshot.reset();
			toneClap.reset();
			toneHighHat.reset();
			toneRide.reset();
			toneCrash.reset();
		}
		
		/**
		 * ADVANCE IN PATTERN STRUCTURE
		 */
		private function advancePattern( samples: Array ): void
		{
			var samplesNum: int = samples.length;
			
			var stepSampleNum: int = 15 * 44100 / tempo.getValue();
			
			var msEachStep: Number = 15000 / tempo.getValue();
			
			var triggers: Array;
			var trigger: Trigger;
			
			var relVol: Number;
			var absVol: Number = volume.getValue();
			var accentValue: Number = accent.getValue() * absVol;
			
			var shuffleValue: Number = shuffle.getValue();
			
			//-- Collect all triggers within buffer length
			while( sampleOffset < samplesNum )
			{
				triggers = memory.getTriggers();
				
				if( triggers )
				{
					for each( trigger in triggers )
					{
						relVol = trigger.accent ? absVol : accentValue;
						
						switch( trigger.voiceIndex )
						{
							case 0:
								if( !toneBassdrum.mute.getValue() )
									addVoice( new VoiceBassdrum( sampleOffset, relVol, toneBassdrum ) ); break;

							case 1:
								if( !toneSnaredrum.mute.getValue() )
									addVoice( new VoiceSnaredrum( sampleOffset, relVol, toneSnaredrum ) ); break;

							case 2:
								if( !toneTomLow.mute.getValue() )
									addVoice( new VoiceTom( sampleOffset, relVol, toneTomLow, VoiceTom.SIZE_LOW ) ); break;

							case 3:
								if( !toneTomMid.mute.getValue() )
									addVoice( new VoiceTom( sampleOffset, relVol, toneTomMid, VoiceTom.SIZE_MED ) ); break;

							case 4:
								if( !toneTomHigh.mute.getValue() )
									addVoice( new VoiceTom( sampleOffset, relVol, toneTomHigh, VoiceTom.SIZE_HIGH ) ); break;

							case 5:
								if( !toneRimshot.mute.getValue() )
									addVoice( new VoiceRimshot( sampleOffset, relVol, toneRimshot ) ); break;

							case 6:
								if( !toneClap.mute.getValue() )
									addVoice( new VoiceClap( sampleOffset, relVol, toneClap ) ); break;
								
							case 7:
								if( !toneHighHat.mute.getValue() )
									addVoice( new VoiceHiHat( sampleOffset, relVol, toneHighHat, VoiceHiHat.CLOSED ) ); break;

							case 8:
								if( !toneHighHat.mute.getValue() )
									addVoice( new VoiceHiHat( sampleOffset, relVol, toneHighHat, VoiceHiHat.OPEN ) ); break;

							case 9:
								if( !toneCrash.mute.getValue() )
									addVoice( new VoiceCrash( sampleOffset, relVol, toneCrash ) ); break;

							case 10:
								if( !toneRide.mute.getValue() )
									addVoice( new VoiceRide( sampleOffset, relVol, toneRide ) ); break;
						}
					}
				}
				
				timeElapsed += msEachStep;
				stepTimes.push( timeElapsed );
				
				memory.stepComplete();
				
				//-- shuffle
				if( shuffleIndex == 0 )
					sampleOffset += stepSampleNum * shuffleValue;
				else
					sampleOffset += stepSampleNum * ( 2 - shuffleValue );
				
				shuffleIndex = 1 - shuffleIndex;
			}
			
			sampleOffset -= samplesNum;
		}

		/**
		 * PROCESS AUDIO VOICES
		 */
		private function advanceVoices( samples: Array ): void
		{
			var complete: Boolean;
			
			var i: int = activeVoices.length;
			
			while( --i > -1 )
			{
				complete = Voice( activeVoices[i] ).processAudioAdd( samples );

				if( complete )
					activeVoices.splice( i, 1 );
			}
		}
		
		/**
		 * ADD VOICE FOR PROCESS AUDIO > MANAGE MONOPHONE
		 */
		private function addVoice( voice: Voice ): void
		{
			var cutVoice: Voice;
			
			//-- CHECK MONOPHONE
			if( voice.isMonophone() )
			{
				var i: int = activeVoices.length;
				
				while( --i > -1 )
				{
					cutVoice = Voice( activeVoices[i] );
					
					//-- check if channel is active
					if( cutVoice.getChannel() == voice.getChannel() )
					{
						//-- stop current voice, when new voice starts
						cutVoice.cut( sampleOffset );
						break;
					}
				}
			}

			activeVoices.push( voice );
		}
	}
}