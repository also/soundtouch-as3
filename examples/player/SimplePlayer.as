// `SimplePlayer` is an example of how to use the SoundTouch AS3 library to play
// a `Sound` object. It implements play, pause and seek, while allowing the
// SoundTouch filter parameters to be manipulated during playback.

//### License
// The SoundTouch AS3 library, like the original SoundTouch C++ library, is
// released under the LGPL.
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

    //### Events
    // SimplePlayer dispatches two events: `play` and `pause`. There is no
    // equivalent to the `progress` event; use a timer if you need to monitor
    // the position.
    /** Dispatched when the sound is played. */
    [Event(type="flash.events.Event", name="play")]

    /** Dispatched whent the sound is paused. */
    [Event(type="flash.events.Event", name="pause")]

    //
    /**
    * Example of an audio player using Soundtouch. It supports manipulating the
    * tempo, rate, and pitch during playback.
    */
    public class SimplePlayer extends EventDispatcher {
        //### Private variables

        // The `outputPosition` when the current `soundChannel` started playing.
        // This value is used to calculate the `outputPosition`, as the
        // `position` of the `soundChannel` only gives us the position since the
        // most recent invocation of `play()`.
        private var channelOffset:Number;

        // The `outputPosition` and `position` when a filter parameter was
        // changed. These two values are used to calculate the `position` in the
        // source `sound`.
        private var filterChangedOutputPosition:Number;
        private var filterChangedPosition:Number;

        // The `SoundTouch` object is a wrapper around two others: a `Stretch`
        // and a `RateTransposer`. It takes care of wiring them all together in
        // the correct order. If you only need to change the tempo, you can use
        // a `Stretch` object by itself. If you only need to change the rate,
        // you could use `RateTransposer`, but in that case, SoundTouch AS3 is
        // probably much more than you need.
        private var soundTouch:SoundTouch;

        // The `SimpleFilter` handles the input and output buffering to use
        // `SoundTouch` with a `sound` as input.
        private var sound:Sound;
        private var filter:SimpleFilter;

        // Flash's source of audio. The `soundChannel` will control the
        // `outputSound`, which `extract`s data from the `filter`.
        private var outputSound:Sound;
        private var soundChannel:SoundChannel;

        //
        public function SimplePlayer(sound:Sound):void {
            this.sound = sound;

            soundTouch = new SoundTouch();
            filter = new SimpleFilter(sound, soundTouch);

            outputSound = new Sound();
            outputSound.addEventListener(
                SampleDataEvent.SAMPLE_DATA, filter.handleSampleData);

            channelOffset = 0;
            filterChangedOutputPosition = 0;
            filterChangedPosition = 0;
        }

        //### Parameters

        // Expose the interesting `SoundTouch` parameters, and keep track of the
        // `position` and `outputPosition` when they change.
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

        private function beforeUpdateFilter():void {
            filterChangedPosition = position;
            filterChangedOutputPosition = outputPosition;
        }

        //### Position
        // We expose positions in terms of the source `sound`.

        // The current position is calculated based on the `position` and
        // `outputPosition` when the filter was last changed. Since it last
        // changed, we've played `outputPosition - filterChangedOutputPosition`
        // milliseconds of audio. This was played at a rate of
        // `soundTouch.tempo * soundTouch.rate` compared to the source--if we
        // played one second of audio at with a `rate` of `2`, we moved two
        // seconds through the source. If we had previously been at `position`
        // `5`, we are now at `7`.
        /**
        * The position of the source, in milliseconds. The value returned is an
        * approximation which can become less accurate if the filter parameters
        * are changed.
        */
        public function get position():Number {
            var outputDelta:Number =
                outputPosition - filterChangedOutputPosition;
            var positionDelta:Number =
                outputDelta * soundTouch.tempo * soundTouch.rate;
            return filterChangedPosition + positionDelta;
        }

        // Seeks to a given position in the source. This will also eliminate any
        // error that has accumulated in the calculated `position`.
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

        //
        /** The number of milliseconds of audio played. */
        private function get outputPosition():Number {
            return channelOffset +
                (soundChannel != null ? soundChannel.position : 0);
        }

        //### Control

        // Are we playing audio? If we are, the `soundChannel` will not be null.
        // Otherwise, we haven't started, or `pause()` has cleared it.
        /** Indicates whether the player is currently playing. */
        public function get playing():Boolean {
            return soundChannel != null;
        }

        // Start playback, but only if we aren't currently playing.
        /** Starts playback. */
        public function play():void {
            if (!playing) {
                soundChannel = outputSound.play();
                soundChannel.addEventListener(
                    Event.SOUND_COMPLETE, soundCompleteHandler);
                dispatchEvent(new Event('play'));
            }
        }

        // When we reach the end, clean up and let everyone know.
        private function soundCompleteHandler(e:Event):void {
            pause();
        }


        // Pause playback, but only if we are currently playing.
        /** Pauses playback. */
        public function pause():void {
            if (playing) {
                // When a `SoundChannel` is stopped, all unplayed data in its
                // buffer is lost. Without correction, this would lead to a few
                // milliseconds of audio skipped every time the player was
                // paused.
                //
                // `SimpleFilter` buffers the last few milliseconds of audio,
                // and lets us seek back to the exact position we were at when
                // we paused.
                filter.position = outputPosition * 44.1;

                // Stop the `soundChannel`, and keep track of how long we've
                // played so far.
                channelOffset += soundChannel.position;
                soundChannel.stop();
                soundChannel = null;
                dispatchEvent(new Event('pause'));
            }
        }

        //
        /** Toggles between play and pause. */
        public function togglePlayPause():void {
            !playing ? play() : pause();
        }
    }
}
