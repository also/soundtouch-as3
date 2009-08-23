package com.ryanberdeen.soundtouch {
    public class AbstractFifoSamplePipe {
        protected var _inputBuffer:FifoSampleBuffer;
        protected var _outputBuffer:FifoSampleBuffer;

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
    }
}