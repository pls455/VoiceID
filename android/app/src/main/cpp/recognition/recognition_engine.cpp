#include "recognition_engine.h"
#include "../embeddings/speaker_embedding.h"
namespace voiceid::recognition {
Match find_best(const std::vector<float>&probe,const std::vector<std::pair<std::string,std::vector<float>>>&profiles,float threshold){
 Match best;
 for(const auto&p:profiles){float s=voiceid::embedding::cosine_similarity(probe,p.second);if(s>best.similarity){best.person_id=p.first;best.similarity=s;}}
 best.known=!best.person_id.empty()&&best.similarity>=threshold;return best;
}}
