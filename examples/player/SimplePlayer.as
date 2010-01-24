/*
* SoundTouch AS3 audio processing library
* Copyright (c) Ryan Berdeen
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

package {
    import com.ryanberdeen.soundtouch.SimpleFilter;
    import com.ryanberdeen.soundtouch.SoundTouch;

    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;

    /** Dispatched when the sound is played. */
    [Event(type="flash.events.Event", name="play")]

    /** Dispatched whent the sound is paused. */
    [Event(type="flash.events.Event", name="pause")]

    /**
    * Example of an audio player using Soundtouch. It supports manipulating the
    * tempo, rate, and pitch during playback.
    */
    public class SimplePlayer extends EventDispatcher {
        private var channelOffset:Number;
        private var filterChangedOutputPosition:Number;
        private var filterChangedPosition:Number;

        private var sound:Sound;
        private var soundTouch:SoundTouch;
        private var filter:SimpleFilter;
        private var outputSound:Sound;
        private var soundChannel:SoundChannel;

        public function SimplePlayer(sound:Sound):void {
            this.sound = sound;

            soundTouch = new SoundTouch();
            filter = new SimpleFilter(sound, soundTouch);

            outputSound = new Sound();
            outputSound.addEventListener(SampleDataEvent.SAMPLE_DATA, filter.handleSampleData);

            channelOffset = 0;
            filterChangedOutputPosition = 0;
            filterChangedPosition = 0;
        }

        /** Indicates whether the player is currently playing. */
        public function get playing():Boolean {
            return soundChannel != null;
        }

        /** The rate of the underlying SoundTouch object. */
        public function get rate():Number {
            return soundTouch.rate;
        }

        /** @private */
        public function set rate(rate:Number):void {
            beforeUpdateFilter();
            soundTouch.rate = rate;
        }

        /** The tempo of the underlying SoundTouch object. */
        public function get tempo():Number {
            return soundTouch.tempo;
        }

        /** @private */
        public function set tempo(tempo:Number):void {
            beforeUpdateFilter();
            soundTouch.tempo = tempo;
        }

        /** The pitchOctaves of the underlying SoundTouch object. */
        public function set pitchOctaves(pitchOctaves:Number):void {
            beforeUpdateFilter();
            soundTouch.pitchOctaves = pitchOctaves;
        }

        /**
        * The position of the source, in milliseconds. The value returned is an
        * approximation which can become less accurate if the filter parameters
        * are changed.
        */
        public function get position():Number {
            var outputDelta:Number = outputPosition - filterChangedOutputPosition;
            var positionDelta:Number = outputDelta * soundTouch.tempo * soundTouch.rate;
            return filterChangedPosition + positionDelta;
        }

        /** @private */
        public function set position(sourcePosition:Number):void {
            var resume:Boolean = playing;
            pause();
            filter.sourcePosition = sourcePosition * 44.1;
            filterChangedPosition = sourcePosition;
            filterChangedOutputPosition = outputPosition;
            if (resume) {
                play();
            }
        }

        /** The number of milliseconds of audio played. */
        private function get outputPosition():Number {
            return channelOffset + (soundChannel != null ? soundChannel.position : 0);
        }

        // keep track of the current calculated and output positions
        private function beforeUpdateFilter():void {
            filterChangedPosition = position;
            filterChangedOutputPosition = outputPosition;
        }

        /** Starts playback. */
        public function play():void {
            if (!playing) {
                soundChannel = outputSound.play();
                soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
                dispatchEvent(new Event('play'));
            }
        }

        private function soundCompleteHandler(e:Event):void {
            pause();
        }

        /** Pauses playback. */
        public function pause():void {
            if (playing) {
                filter.position = outputPosition * 44.1;
                channelOffset += soundChannel.position;
                soundChannel.stop();
                soundChannel = null;
                dispatchEvent(new Event('pause'));
            }
        }

        /** Toggles between play and pause. */
        public function togglePlayPause():void {
            !playing ? play() : pause();
        }
    }
}
