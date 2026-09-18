# VoiceID

Offline Android speaker recognition application.

## Phase 1
Flutter UI, Android microphone permission foundation, and native C++/CMake bridge.

## Architecture
Flutter UI -> Dart services -> native layer -> C++ audio/DSP -> embedding model -> recognition.

## Important
Speaker recognition is not mocked. The embedding model and inference pipeline will be added in later phases.

## Requirements
- Flutter
- Android SDK
- Android NDK
- CMake
- C++17
