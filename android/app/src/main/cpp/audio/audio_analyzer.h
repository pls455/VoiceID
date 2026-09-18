#pragma once
#include <cstddef>
#include <cstdint>
namespace voiceid::audio { struct AudioFeatures{float rms=0,peak=0,zero_crossing_rate=0;bool speech=false;}; AudioFeatures analyze(const int16_t*,size_t,float=0.012f); }