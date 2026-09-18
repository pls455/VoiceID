#include <jni.h>
#include "audio/audio_engine.h"

extern "C" __attribute__((visibility("default")))
int voiceid_audio_start() { return voiceid::audio::start(); }

extern "C" __attribute__((visibility("default")))
void voiceid_audio_stop() { voiceid::audio::stop(); }

extern "C" __attribute__((visibility("default")))
float voiceid_audio_level() { return voiceid::audio::level(); }
