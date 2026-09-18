#include "audio_engine.h"
#include <atomic>

namespace {
std::atomic<bool> g_running{false};
std::atomic<float> g_level{0.0f};
}

namespace voiceid::audio {
int start() {
  g_running.store(true, std::memory_order_release);
  g_level.store(0.0f, std::memory_order_release);
  return 0;
}
void stop() {
  g_running.store(false, std::memory_order_release);
  g_level.store(0.0f, std::memory_order_release);
}
float level() { return g_level.load(std::memory_order_acquire); }
}
