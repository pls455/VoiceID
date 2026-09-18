#include <jni.h>
#include <cstdint>
#include "audio/audio_engine.h"
#include "recognition/recognition_registry.h"
#include <cstring>
#include <string>
#include <vector>
extern "C" __attribute__((visibility("default"))) int voiceid_audio_start(){return voiceid::audio::start();}
extern "C" __attribute__((visibility("default"))) void voiceid_audio_stop(){voiceid::audio::stop();}
extern "C" __attribute__((visibility("default"))) float voiceid_audio_level(){return voiceid::audio::level();}
extern "C" __attribute__((visibility("default"))) bool voiceid_audio_speech(){return voiceid::audio::speech_detected();}
extern "C" JNIEXPORT jint JNICALL Java_com_voiceid_MainActivity_nativePushPcm(JNIEnv*e,jobject,jshortArray a,jint c){if(!a||c<=0)return 0;jsize l=e->GetArrayLength(a);jint n=c<l?c:l;jshort*d=e->GetShortArrayElements(a,nullptr);if(!d)return 0;auto w=voiceid::audio::push_pcm(reinterpret_cast<const int16_t*>(d),size_t(n));e->ReleaseShortArrayElements(a,d,JNI_ABORT);return jint(w);}
extern "C" __attribute__((visibility("default"))) int voiceid_profile_add(const char* id, const float* embedding, size_t length) {
  if (!id || !embedding || length == 0) return 0;
  return voiceid::recognition::registry().add(id, std::vector<float>(embedding, embedding + length)) ? 1 : 0;
}
extern "C" __attribute__((visibility("default"))) void voiceid_profile_clear() { voiceid::recognition::registry().clear(); }
extern "C" __attribute__((visibility("default"))) float voiceid_recognize(const float* embedding, size_t length, float threshold, char* out_id, size_t out_capacity) {
  if (!embedding || length == 0 || !out_id || out_capacity == 0) return -1.0f;
  auto match = voiceid::recognition::registry().recognize(std::vector<float>(embedding, embedding + length), threshold);
  if (match.known) {
    std::strncpy(out_id, match.person_id.c_str(), out_capacity - 1);
    out_id[out_capacity - 1] = '\\0';
  } else {
    out_id[0] = '\\0';
  }
  return match.similarity;
}
