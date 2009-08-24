SoundTouch AS3
==============

An ActionScript 3 port of the [SoundTouch][1] audio processing library.

SoundTouch AS3 allows realtime processing of audio in Flash 10. It includes filters that perform time compression/expansion and rate transposition. In tandem, these filters can perform pitch-shifting.

Usage
=====

    var source:Sound = …;
    var output:Sound = new Sound();

    var soundTouch:SoundTouch = new SoundTouch();
    soundTouch.pitchSemitones = -6;

    var filter:SimpleFilter = new SimpleFilter(sound, soundTouch);
    output.addEventListener(SampleDataEvent.SAMPLE_DATA, filter.handleSampleData);

    output.play();

For details on using the SoundTouch, Stretch, or RateTransposer classes, look in SimpleFilter and FilterSupport.

Roadmap
=======

The original C++ library includes several features that have not yet been implemented in ActionScript, including a FIR filter, which can be used to prevent aliasing during rate transposition.

License
=======

SoundTouch AS3 audio processing library

Copyright © Olli Parviainen 2001-2009  
Copyright © Ryan Berdeen 2009

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

[1]: http://www.surina.net/soundtouch/
