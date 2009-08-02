package com.ryanberdeen.soundtouch {
  import flash.media.Sound;
  import flash.utils.ByteArray;
  import flash.external.ExternalInterface;

  public class SoundInputBuffer implements IInputBuffer {
    private var _sound:Sound;
    private var _frameCount:uint;
    private var _position:uint;
    private var _maxPosition:uint;

    private var temp:ByteArray;

    public function SoundInputBuffer(sound:Sound) {
      _sound = sound;
      _position = 0;
      _maxPosition = 0;
      temp = new ByteArray();

      determineFrameCount();
    }

    /**
    * Determine the number of frames in the sound.
    *
    * <p>sound.length * 44.1 might not be exact, so figure out the correct
    * number of frames.</p>
    */
    private function determineFrameCount():void {
      _frameCount = _sound.length * 44.1 - 500;
      var framesLeft:uint;
      do {
        temp.position = 0;
        framesLeft = _sound.extract(temp, 500, _frameCount);
        _frameCount += framesLeft;
      } while (framesLeft > 0)
    }

    public function get frameCount():uint {
      return _frameCount;
    }

    public function get position():uint {
      return _position;
    }

    public function set position(position:uint):void {
      _position = position;
      _maxPosition = position;
    }

    public function get framesAvailable():uint {
      return _maxPosition - _position;
    }

    public function putSamples(numFrames:uint):void {
      _maxPosition += numFrames;
    }

    public function get(target:Vector.<Number>, numFrames:uint):uint {
      temp.position = 0;
      var frameCount:uint = _sound.extract(temp, numFrames, _position);

      temp.position = 0;
      var sampleCount:uint = frameCount * 2;
      for (var i:uint = 0; i < sampleCount; i += 2) {
        target[i] = temp.readFloat();
        target[i + 1] = temp.readFloat();
      }
      return frameCount;
    }

    public function consume(target:Vector.<Number>, numFrames:uint):uint {
      var frameCount:uint = get(target, numFrames);
      advance(frameCount);
      return frameCount;
    }

    public function advance(numFrames:uint):void {
      _position += numFrames;
    }
  }
}
