#include <jni.h>

extern "C" JNIEXPORT jfloat JNICALL
Java_com_voiceid_app_NativeBridge_cosineSimilarity(
    JNIEnv*, jobject, jfloatArray, jfloatArray) {
    return 0.0f;
}
