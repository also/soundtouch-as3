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
    import flash.utils.ByteArray;

    public class FifoSampleBuffer {
        private var _vector:Vector.<Number>;
        private var _position:uint;
        private var _frameCount:uint;

        public function FifoSampleBuffer() {
            _vector = new Vector.<Number>();
        }

        public function get vector():Vector.<Number> {
            return _vector;
        }

        public function get position():uint {
            return _position;
        }

        public function get startIndex():uint {
            return _position * 2;
        }

        public function get frameCount():uint {
            return _frameCount;
        }

        public function get endIndex():uint {
            return (_position + _frameCount) * 2;
        }

        public function put(numFrames:uint):void {
            _frameCount += numFrames;
        }

        public function putBytes(bytes:ByteArray):void {
            bytes.position = 0;
            var numFrames:uint = bytes.bytesAvailable / 8;

            ensureCapacity(numFrames + _frameCount);

            var newEndIndex:uint = endIndex + numFrames * 2;
            for (var i:int = endIndex; i < newEndIndex; i++) {
                _vector[i] = bytes.readFloat();
            }

            _frameCount += numFrames;
        }

        public function putSamples(samples:Vector.<Number>, position:uint = 0, numFrames:int = -1):void {
            var sourceOffset:uint = position * 2;
            if (numFrames < 0) {
                numFrames = (samples.length - sourceOffset) / 2;
            }
            var numSamples:uint = numFrames * 2;

            ensureCapacity(numFrames + _frameCount);

            var destOffset:uint = endIndex;
            for (var i:int = 0; i < numSamples; i++) {
                _vector[i + destOffset] = samples[i + sourceOffset];
            }

            _frameCount += numFrames;
        }

        public function putBuffer(buffer:FifoSampleBuffer, position:uint = 0, numFrames:int = -1):void {
            if (numFrames < 0) {
                numFrames = buffer.frameCount - position;
            }
            putSamples(buffer.vector, buffer.position + position, numFrames);
        }

        public function receive(numFrames:uint):void {
            numFrames = Math.min(_frameCount, numFrames);
            _frameCount -= numFrames;
            _position += numFrames;
        }

        public function receiveSamples(output:Vector.<Number>, numFrames:uint):void {
            var numSamples:uint = numFrames * 2;
            var sourceOffset:uint = startIndex;
            for (var i:uint = 0; i < numSamples; i++) {
                output[i] = _vector[i + sourceOffset];
            }
            receive(numFrames);
        }

        public function receiveBytes(output:ByteArray, numFrames:uint):void {
            var numSamples:uint = numFrames * 2;
            var sourceOffset:uint = startIndex;
            for (var i:uint = 0; i < numSamples; i++) {
                output.writeFloat(_vector[i + sourceOffset]);
            }
            receive(numFrames);
        }

        public function ensureCapacity(numFrames:uint):void {
            rewind();
            var minLength:uint = numFrames * 2;
            if (_vector.length < minLength) {
                _vector.length = minLength;
            }
        }

        public function ensureAdditionalCapacity(numFrames:uint):void {
            ensureCapacity(frameCount + numFrames);
        }

        public function rewind():void {
            if (_position > 0) {
                var offset:int = startIndex;
                var numSamples:int = frameCount * 2;
                for (var i:int = 0; i < numSamples; i++) {
                    _vector[i] = _vector[i + offset];
                }
                _position = 0;
            }
        }
    }
}
