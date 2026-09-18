cmake_minimum_required(VERSION 3.22.1)
project(voiceid_native)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(voiceid_native SHARED native_bridge.cpp)
find_library(log-lib log)
target_link_libraries(voiceid_native ${log-lib})
