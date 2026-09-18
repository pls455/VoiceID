package com.voiceid

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
    private val channel = "voiceid/audio"
    private var recorder: AudioRecord? = null
    private var thread: Thread? = null
    private val running = AtomicBoolean(false)
    private var level = 0.0

    private external fun nativePushPcm(samples: ShortArray, count: Int): Int

    companion object { init { System.loadLibrary("voiceid_native") } }

    override fun configureFlutterEngine(binding: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(binding)
        MethodChannel(binding.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 7001)
                        result.error("PERMISSION", "Microphone permission required", null)
                    } else {
                        startAudio()
                        result.success(true)
                    }
                }
                "stop" -> { stopAudio(); result.success(true) }
                "level" -> result.success(level)
                else -> result.notImplemented()
            }
        }
    }

    private fun startAudio() {
        if (running.get()) return
        val sampleRate = 16000
        val min = AudioRecord.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        recorder = AudioRecord(MediaRecorder.AudioSource.VOICE_RECOGNITION, sampleRate, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, min * 2)
        recorder?.startRecording()
        running.set(true)
        thread = Thread {
            val buffer = ShortArray(min.coerceAtLeast(1024))
            while (running.get()) {
                val n = recorder?.read(buffer, 0, buffer.size) ?: 0
                if (n > 0) {
                    var sum = 0.0
                    for (i in 0 until n) {
                        val x = buffer[i].toDouble() / 32768.0
                        sum += x * x
                    }
                    nativePushPcm(buffer, n)
                    level = sqrt(sum / n).coerceIn(0.0, 1.0)
                }
            }
        }.also { it.start() }
    }

    private fun stopAudio() {
        running.set(false)
        try { thread?.join(300) } catch (_: InterruptedException) {}
        recorder?.stop()
        recorder?.release()
        recorder = null
        thread = null
        level = 0.0
    }

    override fun onDestroy() {
        stopAudio()
        super.onDestroy()
    }
}
