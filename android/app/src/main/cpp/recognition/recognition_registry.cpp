#include "recognition_registry.h"

namespace voiceid::recognition {
Registry& registry() {
  static Registry instance;
  return instance;
}
void Registry::clear() {
  std::lock_guard<std::mutex> lock(mutex_);
  profiles_.clear();
}
bool Registry::add(const std::string& id, const std::vector<float>& embedding) {
  if (id.empty() || embedding.empty()) return false;
  std::lock_guard<std::mutex> lock(mutex_);
  profiles_[id] = embedding;
  return true;
}
Match Registry::recognize(const std::vector<float>& probe, float threshold) const {
  std::vector<std::pair<std::string, std::vector<float>>> snapshot;
  {
    std::lock_guard<std::mutex> lock(mutex_);
    snapshot.reserve(profiles_.size());
    for (const auto& p : profiles_) snapshot.push_back(p);
  }
  return find_best(probe, snapshot, threshold);
}
}
