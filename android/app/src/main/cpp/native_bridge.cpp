#include <jni.h>
#include <cstdint>
#include "audio/audio_engine.h"
extern "C" __attribute__((visibility("default"))) int voiceid_audio_start(){return voiceid::audio::start();}
extern "C" __attribute__((visibility("default"))) void voiceid_audio_stop(){voiceid::audio::stop();}
extern "C" __attribute__((visibility("default"))) float voiceid_audio_level(){return voiceid::audio::level();}
extern "C" __attribute__((visibility("default"))) bool voiceid_audio_speech(){return voiceid::audio::speech_detected();}
extern "C" JNIEXPORT jint JNICALL Java_com_voiceid_MainActivity_nativePushPcm(JNIEnv*e,jobject,jshortArray a,jint c){if(!a||c<=0)return 0;jsize l=e->GetArrayLength(a);jint n=c<l?c:l;jshort*d=e->GetShortArrayElements(a,nullptr);if(!d)return 0;auto w=voiceid::audio::push_pcm(reinterpret_cast<const int16_t*>(d),size_t(n));e->ReleaseShortArrayElements(a,d,JNI_ABORT);return jint(w);}