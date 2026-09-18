package com.voiceid

import android.content.Context
import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession

class SpeakerEmbeddingEngine(context: Context) : AutoCloseable {
    private val environment = OrtEnvironment.getEnvironment()
    private val session: OrtSession
    init {
        val model = context.assets.open("flutter_assets/assets/models/speaker_encoder_int8.onnx").use { it.readBytes() }
        session = environment.createSession(model)
    }

    fun embed(pcm16: ShortArray): FloatArray {
        require(pcm16.isNotEmpty()) { "Audio is empty" }
        val input = FloatArray(pcm16.size)
        for (i in pcm16.indices) input[i] = pcm16[i] / 32768.0f
        OnnxTensor.createTensor(environment, arrayOf(input)).use { tensor ->
            val inputName = session.inputNames.iterator().next()
            session.run(mapOf(inputName to tensor)).use { results ->
                val raw = results[0].value
                val vector = when (raw) {
                    is Array<*> -> {
                        val row = raw[0]
                        when (row) {
                            is FloatArray -> row
                            is Array<*> -> (row as Array<*>).flatMap { (it as FloatArray).asIterable() }.toFloatArray()
                            else -> error("Unsupported embedding output")
                        }
                    }
                    is FloatArray -> raw
                    else -> error("Unsupported embedding output")
                }
                var norm = 0.0
                for (v in vector) norm += v * v
                val inv = (1.0 / kotlin.math.sqrt(norm)).toFloat()
                for (i in vector.indices) vector[i] *= inv
                return vector
            }
        }
    }

    override fun close() {
        session.close()
    }
}
