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
    import flash.events.SampleDataEvent;
    import flash.media.Sound;
    import flash.utils.ByteArray;

    public class SimpleFilter extends FilterSupport {
        private var sourceSound:Sound;
        private var sourcePosition:int;

        public function SimpleFilter(sourceSound:Sound, pipe:IFifoSamplePipe) {
            super(pipe);
            this.sourceSound = sourceSound;
            sourcePosition = 0;
        }

        override protected function fillInputBuffer(numFrames:int):void {
            var bytes:ByteArray = new ByteArray();
            var numFramesExtracted:uint = sourceSound.extract(bytes, numFrames, sourcePosition);
            sourcePosition += numFramesExtracted;
            inputBuffer.putBytes(bytes);
        }

        public function extract(target:ByteArray, numFrames:int):int {
            fillOutputBuffer(numFrames);
            var result:int = Math.min(numFrames, outputBuffer.frameCount);
            outputBuffer.receiveBytes(target, result);
            return result;
        }

        public function handleSampleData(e:SampleDataEvent):void {
            extract(e.data, 4096);
        }
    }
}
