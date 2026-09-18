#pragma once
#include <string>
#include <unordered_map>
#include <vector>
#include <mutex>
#include "recognition_engine.h"

namespace voiceid::recognition {
class Registry {
 public:
  void clear();
  bool add(const std::string& id, const std::vector<float>& embedding);
  Match recognize(const std::vector<float>& probe, float threshold) const;
 private:
  mutable std::mutex mutex_;
  std::unordered_map<std::string, std::vector<float>> profiles_;
};
Registry& registry();
}
