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

package com.ryanberdeen.soundtouch {
    public class FilterSupport {
        private var _pipe:IFifoSamplePipe;

        public function FilterSupport(pipe:IFifoSamplePipe) {
            _pipe = pipe;
        }

        public function get pipe():IFifoSamplePipe {
            return _pipe;
        }

        protected function get inputBuffer():FifoSampleBuffer {
            return _pipe.inputBuffer;
        }

        protected function get outputBuffer():FifoSampleBuffer {
            return _pipe.outputBuffer;
        }

        protected function fillInputBuffer(numFrames:int):void {
            throw new Error("fillInputBuffer() not overridden");
        }

        protected function fillOutputBuffer(numFrames:int):void {
            while (outputBuffer.frameCount < numFrames) {
                var numInputFrames:uint = 8192 - inputBuffer.frameCount;

                fillInputBuffer(numInputFrames);

                if (inputBuffer.frameCount < 8192) {
                    break;
                    // TODO flush pipe
                }

                _pipe.process();
            }
        }
    }
}
