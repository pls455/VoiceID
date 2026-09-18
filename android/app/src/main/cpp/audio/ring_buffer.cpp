#include "ring_buffer.h"
#include <algorithm>
namespace voiceid::audio {
RingBuffer::RingBuffer(size_t c):capacity_(c),buffer_(c){}
size_t RingBuffer::write(const int16_t*d,size_t n){if(!d||!n)return 0;auto w=write_pos_.load();auto r=read_pos_.load(std::memory_order_acquire);auto used=std::min(capacity_,w-r);n=std::min(n,capacity_-used);for(size_t i=0;i<n;i++)buffer_[(w+i)%capacity_]=d[i];write_pos_.store(w+n,std::memory_order_release);return n;}
size_t RingBuffer::read(int16_t*d,size_t n){if(!d||!n)return 0;auto w=write_pos_.load(std::memory_order_acquire);auto r=read_pos_.load();n=std::min(n,w-r);for(size_t i=0;i<n;i++)d[i]=buffer_[(r+i)%capacity_];read_pos_.store(r+n,std::memory_order_release);return n;}
size_t RingBuffer::available()const{return write_pos_.load()-read_pos_.load();}
void RingBuffer::clear(){read_pos_.store(write_pos_.load());}}