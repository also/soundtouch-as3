package com.ryanberdeen.soundtouch {
  public interface IInputBuffer {
    /**
    * The number of frames available.
    */
    function get framesAvailable():uint;

    function get(target:Vector.<Number>, numFrames:uint):uint;
    function consume(target:Vector.<Number>, numFrames:uint):uint;
    function advance(numFrames:uint):void;
  }
}
