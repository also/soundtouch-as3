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
    public class AbstractFifoSamplePipe {
        protected var _inputBuffer:FifoSampleBuffer;
        protected var _outputBuffer:FifoSampleBuffer;

        public function AbstractFifoSamplePipe(createBuffers:Boolean = false) {
            if (createBuffers) {
                inputBuffer = new FifoSampleBuffer();
                outputBuffer = new FifoSampleBuffer();
            }
        }

        public function get inputBuffer():FifoSampleBuffer {
            return _inputBuffer;
        }

        public function set inputBuffer(inputBuffer:FifoSampleBuffer):void {
          _inputBuffer = inputBuffer;
        }

        public function get outputBuffer():FifoSampleBuffer {
            return _outputBuffer;
        }

        public function set outputBuffer(outputBuffer:FifoSampleBuffer):void {
          _outputBuffer = outputBuffer;
        }

        public function clear():void {
            _inputBuffer.clear();
            _outputBuffer.clear();
        }
    }
}
