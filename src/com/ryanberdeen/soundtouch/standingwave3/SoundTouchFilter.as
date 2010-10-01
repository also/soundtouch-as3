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

package com.ryanberdeen.soundtouch.standingwave3 {
    import com.noteflight.standingwave3.elements.AudioDescriptor;
    import com.noteflight.standingwave3.elements.IAudioFilter;
    import com.noteflight.standingwave3.elements.IAudioSource;
    import com.noteflight.standingwave3.elements.Sample;

    import com.ryanberdeen.soundtouch.FilterSupport;
    import com.ryanberdeen.soundtouch.IFifoSamplePipe;

    public class SoundTouchFilter extends FilterSupport implements IAudioFilter {
        private var _source:IAudioSource;
        private var _position:Number;

        public function SoundTouchFilter(pipe:IFifoSamplePipe) {
            super(pipe);
        }

        public function get descriptor():AudioDescriptor {
            return StandingWaveUtils.AUDIO_DESCRIPTOR;
        }

        public function get source():IAudioSource {
            return _source;
        }

        public function set source(source:IAudioSource):void {
            // TODO can actually handle other rates
            if (source.descriptor.channels != AudioDescriptor.CHANNELS_STEREO || source.descriptor.rate != AudioDescriptor.RATE_44100) {
                throw new ArgumentError('SoundTouchFilter requires a stereo source at 44100 Hz');
            }
            _source = source;
        }

        public function get frameCount():Number {
            return Number.MAX_VALUE;
        }

        public function get position():Number {
            return _position;
        }

        public function resetPosition():void {
            _position = 0;
            _source.resetPosition();
            resetBuffers();
        }

        private function resetBuffers():void {
            clear();
        }

        override protected function fillInputBuffer(numFrames:int):void {
            var framesAvailable:uint = _source.frameCount - _source.position;
            var inputSample:Sample = _source.getSample(Math.min(numFrames, framesAvailable));

            StandingWaveUtils.putSample(inputBuffer, inputSample);
        }

        public function getSample(numFrames:Number):Sample {
            fillOutputBuffer(numFrames);
            var result:Sample = StandingWaveUtils.createSample(outputBuffer, numFrames);
            _position += result.frameCount;

            return result;
        }

        public function clone():IAudioSource {
            var result:SoundTouchFilter = new SoundTouchFilter(pipe.clone());
            return result;
        }
    }
}
