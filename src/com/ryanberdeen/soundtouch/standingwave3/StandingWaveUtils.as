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
    import com.noteflight.standingwave3.elements.Sample;
    import com.ryanberdeen.soundtouch.FifoSampleBuffer;

    public class StandingWaveUtils {
        public static const AUDIO_DESCRIPTOR:AudioDescriptor = new AudioDescriptor();

        public static function putSample(buffer:FifoSampleBuffer, sample:Sample):void {
            var numFrames:uint = sample.frameCount;
            buffer.ensureCapacity(numFrames);

            var dest:Vector.<Number> = buffer.vector;
            var destOffset:uint = buffer.endIndex;

            var l:Vector.<Number> = sample.channelData[0];
            var r:Vector.<Number> = sample.channelData[1];

            for (var i:uint = 0; i < numFrames; i++) {
                var destIndex:uint = i * 2 + destOffset;
                dest[destIndex] = l[i];
                dest[destIndex + 1] = r[i];
            }

            buffer.put(numFrames);
        }

        public static function createSample(buffer:FifoSampleBuffer, maxNumFrames:uint):Sample {
            var numFrames:uint = Math.min(maxNumFrames, buffer.frameCount);

            var sample:Sample = new Sample(AUDIO_DESCRIPTOR, numFrames);

            var source:Vector.<Number> = buffer.vector;
            var sourceOffset:uint = buffer.startIndex;

            var l:Vector.<Number> = sample.channelData[0];
            var r:Vector.<Number> = sample.channelData[1];

            for (var i:uint = 0; i < numFrames; i++) {
                var sourceIndex:uint = i * 2 + sourceOffset;
                l[i] = source[sourceIndex];
                r[i] = source[sourceIndex + 1];
            }

            buffer.receive(numFrames);

            return sample;
        }
    }
}
