#include "speaker_embedding.h"
#include <cmath>
namespace voiceid::embedding {
bool l2_normalize(std::vector<float>& v){double s=0;for(float x:v)s+=double(x)*x;if(v.empty()||s<=1e-12)return false;float inv=1.0f/std::sqrt(s);for(float&x:v)x*=inv;return true;}
float cosine_similarity(const std::vector<float>&a,const std::vector<float>&b){if(a.empty()||a.size()!=b.size())return -1.0f;double d=0,aa=0,bb=0;for(size_t i=0;i<a.size();++i){d+=double(a[i])*b[i];aa+=double(a[i])*a[i];bb+=double(b[i])*b[i];}if(aa<=1e-12||bb<=1e-12)return -1.0f;return float(d/std::sqrt(aa*bb));}
EmbeddingResult average(const std::vector<std::vector<float>>& samples){EmbeddingResult r;if(samples.empty())return r;const size_t n=samples.front().size();if(!n)return r;r.vector.assign(n,0);for(const auto&v:samples){if(v.size()!=n)return {};for(size_t i=0;i<n;++i)r.vector[i]+=v[i];}for(float&x:r.vector)x/=float(samples.size());r.valid=l2_normalize(r.vector);return r;}
}