#include "audio_engine.h"
#include "ring_buffer.h"
#include <atomic>
#include <mutex>
#include <thread>
#include <vector>
namespace {constexpr size_t CAP=64000,FRAME=1600;voiceid::audio::RingBuffer ring(CAP);std::atomic<bool>running{false};std::atomic<float>lvl{0};std::atomic<bool>speech{false};voiceid::audio::AudioFeatures feat;std::mutex mu;std::thread worker;void loop(){std::vector<int16_t>f(FRAME);while(running.load()){if(ring.available()<FRAME){std::this_thread::yield();continue;}if(ring.read(f.data(),FRAME)!=FRAME)continue;auto x=voiceid::audio::analyze(f.data(),FRAME);lvl.store(x.rms);speech.store(x.speech);{std::lock_guard<std::mutex>l(mu);feat=x;}}}}
namespace voiceid::audio {int start(){if(running.exchange(true))return 0;ring.clear();lvl.store(0);speech.store(false);worker=std::thread(loop);return 0;}void stop(){if(!running.exchange(false))return;if(worker.joinable())worker.join();ring.clear();lvl.store(0);speech.store(false);}float level(){return lvl.load();}bool speech_detected(){return speech.load();}AudioFeatures features(){std::lock_guard<std::mutex>l(mu);return feat;}size_t push_pcm(const int16_t*s,size_t n){return ring.write(s,n);}}