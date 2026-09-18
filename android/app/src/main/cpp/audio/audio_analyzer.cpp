#include "audio_analyzer.h"
#include <algorithm>
#include <cmath>
namespace voiceid::audio { AudioFeatures analyze(const int16_t*s,size_t n,float t){AudioFeatures o;if(!s||!n)return o;double e=0;float p=0;size_t z=0;for(size_t i=0;i<n;i++){float x=float(s[i])/32768.0f,a=std::fabs(x);e+=double(x)*x;p=std::max(p,a);if(i&&((s[i-1]<0&&s[i]>=0)||(s[i-1]>=0&&s[i]<0)))z++;}o.rms=std::sqrt(e/n);o.peak=p;o.zero_crossing_rate=n>1?float(z)/float(n-1):0;o.speech=o.rms>=t&&o.peak>=t*1.5f;return o;} }