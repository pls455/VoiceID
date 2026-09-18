#pragma once
#include <cstddef>
#include <vector>
namespace voiceid::embedding {
struct EmbeddingResult { bool valid=false; std::vector<float> vector; };
bool l2_normalize(std::vector<float>& vector);
float cosine_similarity(const std::vector<float>& a,const std::vector<float>& b);
EmbeddingResult average(const std::vector<std::vector<float>>& samples);
}