package com.ryanberdeen.memory {
    import com.joa_ebert.abc.bytecode.asbridge.Memory;

    public class MemoryUtils {
        public static function writeFloatVector(vector:Vector.<Number>, address:int, startIndex:int = 0, numFloats:int = -1):void {
            if (numFloats == -1) {
                numFloats = vector.length - startIndex;
            }

            for (var i:int = 0; i < numFloats; i++) {
                Memory.writeFloat(vector[i + startIndex], address + i * 4);
            }
        }

        public static function readFloatVector(vector:Vector.<Number>, address:int, startIndex:int = 0, numFloats:int = -1):void {
            if (numFloats == -1) {
                numFloats = vector.length - startIndex;
            }
            for (var i:int = 0; i < numFloats; i++) {
                vector[i + startIndex] = Memory.readFloat(address + i * 4);
            }
        }
    }
}