import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef _AddNative = ffi.Int32 Function(ffi.Pointer<Utf8>, ffi.Pointer<ffi.Float>, ffi.IntPtr);
typedef _ClearNative = ffi.Void Function();
typedef _RecognizeNative = ffi.Float Function(ffi.Pointer<ffi.Float>, ffi.IntPtr, ffi.Float, ffi.Pointer<Utf8>, ffi.IntPtr);

typedef _Add = int Function(ffi.Pointer<Utf8>, ffi.Pointer<ffi.Float>, int);
typedef _Clear = void Function();
typedef _Recognize = double Function(ffi.Pointer<ffi.Float>, int, double, ffi.Pointer<Utf8>, int);

class RecognitionFfi {
  late final ffi.DynamicLibrary _lib;
  late final _Add _add;
  late final _Clear _clear;
  late final _Recognize _recognize;

  RecognitionFfi() {
    _lib = Platform.isAndroid
        ? ffi.DynamicLibrary.open('libvoiceid_native.so')
        : ffi.DynamicLibrary.process();
    _add = _lib.lookupFunction<_AddNative, _Add>('voiceid_profile_add');
    _clear = _lib.lookupFunction<_ClearNative, _Clear>('voiceid_profile_clear');
    _recognize = _lib.lookupFunction<_RecognizeNative, _Recognize>('voiceid_recognize');
  }

  void clear() => _clear();

  bool addProfile(String id, List<double> embedding) {
    if (embedding.isEmpty) return false;
    final idPtr = id.toNativeUtf8();
    final embPtr = calloc<ffi.Float>(embedding.length);
    try {
      for (var i = 0; i < embedding.length; i++) embPtr[i] = embedding[i];
      return _add(idPtr, embPtr, embedding.length) != 0;
    } finally {
      calloc.free(idPtr);
      calloc.free(embPtr);
    }
  }

  ({String id, double similarity, bool known}) recognize(
    List<double> embedding, {
    double threshold = 0.55,
  }) {
    final embPtr = calloc<ffi.Float>(embedding.length);
    final outPtr = calloc<ffi.Utf8>(256);
    try {
      for (var i = 0; i < embedding.length; i++) embPtr[i] = embedding[i];
      final similarity = _recognize(embPtr, embedding.length, threshold, outPtr, 256);
      final id = outPtr.toDartString();
      return (id: id, similarity: similarity, known: id.isNotEmpty);
    } finally {
      calloc.free(embPtr);
      calloc.free(outPtr);
    }
  }
}
