#pragma once
#include <string>
#include <vector>
namespace voiceid::recognition {
struct Match { std::string person_id; float similarity=-1.0f; bool known=false; };
Match find_best(const std::vector<float>& probe,const std::vector<std::pair<std::string,std::vector<float>>>& profiles,float threshold);
}