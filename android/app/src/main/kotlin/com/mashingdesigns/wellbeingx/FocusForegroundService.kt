package com.mashingdesigns.wellbeingx

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CountDownTimer
import android.os.IBinder

class FocusForegroundService : Service() {
    private var timer: CountDownTimer? = null
    private var endAt: Long = 0L
    private var mode: String = "pomodoro"

    companion object {
        const val ACTION_START = "wx.focus.start"
        const val ACTION_STOP = "wx.focus.stop"
        const val EXTRA_DURATION_MS = "duration_ms"
        const val EXTRA_MODE = "mode"
        private const val CHANNEL_ID = "wx_focus"
        private const val NOTIF_ID = 0xF0C5

        fun start(ctx: Context, durationMs: Long, mode: String) {
            val i = Intent(ctx, FocusForegroundService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_DURATION_MS, durationMs)
                putExtra(EXTRA_MODE, mode)
            }
            ctx.startForegroundService(i)
        }

        fun stop(ctx: Context) {
            val i = Intent(ctx, FocusForegroundService::class.java).apply { action = ACTION_STOP }
            ctx.startService(i)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                val dur = intent.getLongExtra(EXTRA_DURATION_MS, 25L * 60_000L)
                mode = intent.getStringExtra(EXTRA_MODE) ?: "pomodoro"
                endAt = System.currentTimeMillis() + dur
                startForeground(NOTIF_ID, buildNotif(dur))
                timer?.cancel()
                timer = object : CountDownTimer(dur, 1000L) {
                    override fun onTick(remaining: Long) {
                        NativeEventBus.emit(
                            mapOf(
                                "type" to "focus.tick",
                                "remainingMs" to remaining,
                                "mode" to mode
                            )
                        )
                        try {
                            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            nm.notify(NOTIF_ID, buildNotif(remaining))
                        } catch (_: Throwable) {}
                    }

                    override fun onFinish() {
                        NativeEventBus.emit(
                            mapOf(
                                "type" to "focus.finished",
                                "mode" to mode,
                                "timestamp" to System.currentTimeMillis()
                            )
                        )
                        stopSelf()
                    }
                }.start()
            }
            ACTION_STOP -> {
                NativeEventBus.emit(
                    mapOf(
                        "type" to "focus.stopped",
                        "mode" to mode,
                        "timestamp" to System.currentTimeMillis()
                    )
                )
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        timer?.cancel()
        timer = null
        super.onDestroy()
    }

    private fun buildNotif(remainingMs: Long): Notification {
        ensureChannel()
        val open = packageManager.getLaunchIntentForPackage(packageName)
        val pi = PendingIntent.getActivity(
            this,
            0,
            open,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        val mins = (remainingMs / 60_000L).toInt()
        val secs = ((remainingMs / 1000L) % 60L).toInt()
        val title = if (mode == "deep") "Deep Work" else "Focus"
        val text = String.format("%02d:%02d remaining", mins, secs)
        return Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("$title in progress")
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(pi)
            .setShowWhen(false)
            .build()
    }

    private fun ensureChannel() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (nm.getNotificationChannel(CHANNEL_ID) != null) return
        nm.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Focus sessions",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                setShowBadge(false)
                description = "Live timer and progress for focus sessions."
            }
        )
    }
}
