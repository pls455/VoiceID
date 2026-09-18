#pragma once
#include <cstddef>
#include <cstdint>
#include "audio_analyzer.h"
namespace voiceid::audio { int start();void stop();float level();bool speech_detected();AudioFeatures features();size_t push_pcm(const int16_t*,size_t); }