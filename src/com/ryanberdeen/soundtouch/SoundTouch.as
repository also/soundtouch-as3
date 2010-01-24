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
    public class SoundTouch implements IFifoSamplePipe {
        private var _rate:Number;
        private var _tempo:Number;

        private var virtualPitch:Number;
        private var virtualRate:Number;
        private var virtualTempo:Number;

        private var rateTransposer:RateTransposer;
        private var tdStretch:Stretch;

        private var _inputBuffer:FifoSampleBuffer;
        private var intermediateBuffer:FifoSampleBuffer;
        private var _outputBuffer:FifoSampleBuffer;

        public function SoundTouch() {
            rateTransposer = new RateTransposer(false);
            tdStretch = new Stretch(false);

            _inputBuffer = new FifoSampleBuffer();
            intermediateBuffer = new FifoSampleBuffer();
            _outputBuffer = new FifoSampleBuffer();

            _rate = 0;
            tempo = 0;

            virtualPitch = 1.0;
            virtualRate = 1.0;
            virtualTempo = 1.0;

            calculateEffectiveRateAndTempo();
        }

        public function clear():void {
            rateTransposer.clear();
            tdStretch.clear();
        }

        public function clone():IFifoSamplePipe {
            var result:SoundTouch = new SoundTouch();
            result.rate = rate;
            result.tempo = tempo;
            return result;
        }

        public function get rate():Number {
            return _rate;
        }

        public function set rate(rate:Number):void {
            virtualRate = rate;
            calculateEffectiveRateAndTempo();
        }

        public function set rateChange(rateChange:Number):void {
            rate = 1.0 + 0.01 * rateChange;
        }

        public function get tempo():Number {
            return _tempo;
        }

        public function set tempo(tempo:Number):void {
            virtualTempo = tempo;
            calculateEffectiveRateAndTempo();
        }

        public function set tempoChange(tempoChange:Number):void {
            tempo = 1.0 + 0.01 * tempoChange;
        }

        public function set pitch(pitch:Number):void {
            virtualPitch = pitch;
            calculateEffectiveRateAndTempo();
        }

        public function set pitchOctaves(pitchOctaves:Number):void {
            pitch = Math.exp(0.69314718056 * pitchOctaves);
            calculateEffectiveRateAndTempo();
        }

        public function set pitchSemitones(pitchSemitones:Number):void {
            pitchOctaves = pitchSemitones / 12.0;
        }

        public function get inputBuffer():FifoSampleBuffer {
            return _inputBuffer;
        }

        public function get outputBuffer():FifoSampleBuffer {
            return _outputBuffer;
        }

        private function testFloatEqual(a:Number, b:Number):Boolean {
            return (a > b ? a - b : b - a) > 1e-10;
        }

        private function calculateEffectiveRateAndTempo():void {
            var previousTempo:Number = _tempo;
            var previousRate:Number = _rate;

            _tempo = virtualTempo / virtualPitch;
            _rate = virtualRate * virtualPitch;

            if (testFloatEqual(_tempo, previousTempo)) {
                tdStretch.tempo = _tempo;
            }
            if (testFloatEqual(_rate, previousRate)) {
                rateTransposer.rate = _rate;
            }

            if (_rate > 1.0) {
                if (_outputBuffer != rateTransposer.outputBuffer) {
                    tdStretch.inputBuffer = _inputBuffer;
                    tdStretch.outputBuffer = intermediateBuffer;

                    rateTransposer.inputBuffer = intermediateBuffer;
                    rateTransposer.outputBuffer = _outputBuffer;
                }
            }
            else {
                if (_outputBuffer != tdStretch.outputBuffer) {
                    rateTransposer.inputBuffer = _inputBuffer;
                    rateTransposer.outputBuffer = intermediateBuffer;

                    tdStretch.inputBuffer = intermediateBuffer;
                    tdStretch.outputBuffer = _outputBuffer;
                }
            }
        }

        public function process():void {
            if (_rate > 1.0) {
                tdStretch.process();
                rateTransposer.process();
            }
            else {
                rateTransposer.process();
                tdStretch.process();
            }
        }
    }
}
