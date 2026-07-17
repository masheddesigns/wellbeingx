package com.mashingdesigns.wellbeingx

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Single broadcast sink so any background piece (services, accessibility) can
 * publish events into the Flutter side. Latest events are buffered briefly so
 * a freshly-connected listener still sees the last few.
 */
object NativeEventBus : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(map: Map<String, Any?>) {
        val s = sink ?: return
        main.post { s.success(map) }
    }

    fun hasListener(): Boolean = sink != null
}
