import 'dart:ffi' as ffi;
import 'dart:io';

typedef _NativeStart = ffi.Int32 Function();
typedef _NativeStop = ffi.Void Function();
typedef _NativeLevel = ffi.Float Function();

typedef _Start = int Function();
typedef _Stop = void Function();
typedef _Level = double Function();

class AudioEngineFfi {
  late final ffi.DynamicLibrary _lib;
  late final _Start _start;
  late final _Stop _stop;
  late final _Level _level;

  AudioEngineFfi() {
    _lib = Platform.isAndroid
        ? ffi.DynamicLibrary.open('libvoiceid_native.so')
        : ffi.DynamicLibrary.process();
    _start = _lib.lookupFunction<_NativeStart, _Start>('voiceid_audio_start');
    _stop = _lib.lookupFunction<_NativeStop, _Stop>('voiceid_audio_stop');
    _level = _lib.lookupFunction<_NativeLevel, _Level>('voiceid_audio_level');
  }

  int start() => _start();
  void stop() => _stop();
  double get level => _level();
}
