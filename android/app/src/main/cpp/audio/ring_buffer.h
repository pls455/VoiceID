#pragma once
#include <atomic>
#include <cstddef>
#include <cstdint>
#include <vector>
namespace voiceid::audio { class RingBuffer { public: explicit RingBuffer(size_t); size_t write(const int16_t*,size_t); size_t read(int16_t*,size_t); size_t available() const; void clear(); private: const size_t capacity_; std::vector<int16_t> buffer_; std::atomic<size_t> write_pos_{0},read_pos_{0}; }; }