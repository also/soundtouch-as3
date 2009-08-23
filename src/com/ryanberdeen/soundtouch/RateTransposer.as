/*
* SoundTouch AS3 audio processing library
* Copyright (c) Olli Parviainen
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

package com.ryanberdeen.soundtouch {
    public class RateTransposer extends AbstractFifoSamplePipe implements IFifoSamplePipe {
        private var _rate:Number;
        private var slopeCount:Number;
        private var prevSampleL:Number;
        private var prevSampleR:Number;

        public function RateTransposer(createBuffers:Boolean = false) {
            super(createBuffers);
            reset();
            rate = 1;
        }

        public function set rate(rate:Number):void {
            _rate = rate;
            // TODO aa filter
        }

        private function reset():void {
            slopeCount = 0;
            prevSampleL = 0;
            prevSampleR = 0;
        }

        public function process():void {
            // TODO aa filter
            var numFrames:int = _inputBuffer.frameCount;
            _outputBuffer.ensureAdditionalCapacity(numFrames / _rate + 1);
            var numFramesOutput:int = transpose(numFrames);
            _inputBuffer.receive();
            _outputBuffer.put(numFramesOutput);
        }

        private function transpose(numFrames:int):int {
            if (numFrames == 0) {
                // no work
                return 0;
            }

            var src:Vector.<Number> = _inputBuffer.vector;
            var srcOffset:int = _inputBuffer.startIndex;

            var dest:Vector.<Number> = _outputBuffer.vector;
            var destOffset:int = _outputBuffer.endIndex;

            var used:int = 0;
            var i:int = 0;

            while(slopeCount < 1.0) {
                dest[destOffset + 2 * i] = (1.0 - slopeCount) * prevSampleL + slopeCount * src[srcOffset];
                dest[destOffset + 2 * i + 1] = (1.0 - slopeCount) * prevSampleR + slopeCount * src[srcOffset + 1];
                i++;
                slopeCount += _rate;
            }

            slopeCount -= 1.0;

            if (numFrames != 1) {
                out: while (true) {
                    while (slopeCount > 1.0) {
                        slopeCount -= 1.0;
                        used++;
                        if (used >= numFrames - 1) {
                            break out;
                        }
                    }

                    var srcIndex:int = srcOffset + 2 * used;
                    dest[destOffset + 2 * i] = (1.0 - slopeCount) * src[srcIndex] + slopeCount * src[srcIndex + 2];
                    dest[destOffset + 2 * i + 1] = (1.0 - slopeCount) * src[srcIndex + 1] + slopeCount * src[srcIndex + 3];

                    i++;
                    slopeCount += _rate;
                }
            }

            prevSampleL = src[srcOffset + 2 * numFrames - 2];
            prevSampleR = src[srcOffset + 2 * numFrames - 1];

            return i;
        }
    }
}
