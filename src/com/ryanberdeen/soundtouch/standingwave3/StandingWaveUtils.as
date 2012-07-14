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

        public static function putSample(inputBuffer:FifoSampleBuffer, inputSample:Sample):void {
            var inputFrames:uint = inputSample.frameCount;
            inputBuffer.ensureCapacity(inputFrames);

            var dest:Vector.<Number> = inputBuffer.vector;
            var destOffset:uint = inputBuffer.endIndex;

            var leftInput:Vector.<Number> = inputSample.channelData[0];
            var rightInput:Vector.<Number> = inputSample.channelData[1];

            for (var inputIndex:uint = 0; inputIndex < inputFrames; inputIndex++) {
                var destIndex:uint = inputIndex * 2 + destOffset;
                dest[destIndex] =  leftInput[inputIndex];
                dest[destIndex + 1] = rightInput[inputIndex];
            }

            inputBuffer.put(inputFrames);
        }

        public static function createSample(outputBuffer:FifoSampleBuffer, numFrames:uint):Sample {
            var outputFrames:uint = Math.min(numFrames, outputBuffer.frameCount);
            var sample:Sample = new Sample(AUDIO_DESCRIPTOR, outputFrames);

            var source:Vector.<Number> = outputBuffer.vector;
            var sourceOffset:uint = outputBuffer.startIndex;

            var leftOutput:Vector.<Number> = sample.channelData[0];
            var rightOutput:Vector.<Number> = sample.channelData[1];

            for (var outputIndex:uint = 0; outputIndex < outputFrames; outputIndex++) {
                var sourceIndex:uint = outputIndex * 2 + sourceOffset;
                leftOutput[outputIndex] = source[sourceIndex];
                rightOutput[outputIndex] = source[sourceIndex + 1];
            }
	        sample.invalidateSampleMemory();
	        sample.commitChannelData();

            outputBuffer.receive(outputFrames);

            return sample;
        }
    }
}
