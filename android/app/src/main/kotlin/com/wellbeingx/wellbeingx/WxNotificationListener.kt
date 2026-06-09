package com.wellbeingx.wellbeingx

import android.app.Notification
import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class WxNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return
        val pkg = sbn.packageName ?: return
        // Skip ongoing/system notifications.
        val isOngoing = (sbn.notification.flags and Notification.FLAG_ONGOING_EVENT) != 0
        if (isOngoing) return
        if (pkg == applicationContext.packageName) return
        val event = mapOf(
            "type" to "notification.posted",
            "packageName" to pkg,
            "timestamp" to sbn.postTime
        )
        if (NativeEventBus.hasListener()) {
            NativeEventBus.emit(event)
        } else {
            PendingNotifications.store(applicationContext, pkg, sbn.postTime)
        }
    }
}

object PendingNotifications {
    private const val PREF = "wx_pending_notifications"
    private const val KEY = "events"

    fun store(context: Context, pkg: String, timestamp: Long) {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val next = prefs.getStringSet(KEY, emptySet())?.toMutableSet() ?: mutableSetOf()
        next.add("$timestamp|$pkg")
        prefs.edit().putStringSet(KEY, next).apply()
    }

    fun drain(context: Context): List<Map<String, Any?>> {
        val prefs = context.getSharedPreferences(PREF, Context.MODE_PRIVATE)
        val raw = prefs.getStringSet(KEY, emptySet()).orEmpty().toList()
        prefs.edit().remove(KEY).apply()
        return raw.mapNotNull { item ->
            val split = item.split("|", limit = 2)
            if (split.size != 2) return@mapNotNull null
            val ts = split[0].toLongOrNull() ?: return@mapNotNull null
            val pkg = split[1]
            mapOf(
                "type" to "notification.posted",
                "packageName" to pkg,
                "timestamp" to ts
            )
        }
    }
}
