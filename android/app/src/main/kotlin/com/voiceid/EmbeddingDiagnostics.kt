package com.voiceid

import android.content.Context

object EmbeddingDiagnostics {
    fun modelAvailable(context: Context): Boolean =
        try {
            context.assets.open("models/speaker_encoder_int8.onnx").use { true }
        } catch (_: Exception) {
            false
        }
}
