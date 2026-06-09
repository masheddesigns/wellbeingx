package com.wellbeingx.wellbeingx

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val methodChannelName = "wellbeingx/native"
    private val eventChannelName = "wellbeingx/native/events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, methodChannelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "perm.hasUsageAccess" -> result.success(hasUsageAccess())
                        "perm.openUsageAccess" -> {
                            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            result.success(null)
                        }
                        "perm.hasAccessibility" -> result.success(hasAccessibility())
                        "perm.openAccessibility" -> {
                            startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            result.success(null)
                        }
                        "perm.hasNotificationAccess" -> result.success(hasNotificationListenerAccess())
                        "perm.openNotificationListener" -> {
                            startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS").apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            })
                            result.success(null)
                        }
                        "perm.isIgnoringBatteryOpts" -> result.success(isIgnoringBatteryOpts())
                        "perm.requestIgnoreBatteryOpts" -> {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(null)
                        }
                        "usage.queryEvents" -> {
                            val start = (call.argument<Number>("startMs") ?: 0L).toLong()
                            val end = (call.argument<Number>("endMs") ?: System.currentTimeMillis()).toLong()
                            result.success(queryUsageEvents(start, end))
                        }
                        "usage.queryAggregates" -> {
                            val start = (call.argument<Number>("startMs") ?: 0L).toLong()
                            val end = (call.argument<Number>("endMs") ?: System.currentTimeMillis()).toLong()
                            result.success(queryAggregates(start, end))
                        }
                        "notifications.drainPending" -> {
                            result.success(PendingNotifications.drain(applicationContext))
                        }
                        "apps.list" -> result.success(listInstalledApps())
                        "apps.icon" -> {
                            val pkg = call.argument<String>("packageName") ?: ""
                            result.success(loadIconPng(pkg))
                        }
                        "block.set" -> {
                            @Suppress("UNCHECKED_CAST")
                            val pkgs = (call.argument<List<String>>("packages") ?: emptyList())
                            val mode = call.argument<String>("mode") ?: "soft"
                            val until = call.argument<Number?>("untilMs")?.toLong()
                            BlockingState.set(applicationContext, pkgs.toSet(), mode, until)
                            result.success(null)
                        }
                        "block.clear" -> {
                            BlockingState.clear(applicationContext)
                            result.success(null)
                        }
                        "focus.start" -> {
                            val ms = (call.argument<Number>("durationMs") ?: 0L).toLong()
                            val mode = call.argument<String>("mode") ?: "pomodoro"
                            FocusForegroundService.start(applicationContext, ms, mode)
                            result.success(null)
                        }
                        "focus.stop" -> {
                            FocusForegroundService.stop(applicationContext)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (t: Throwable) {
                    result.error("native_error", t.message, null)
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, eventChannelName)
            .setStreamHandler(NativeEventBus)
    }

    // ---------------- Permissions ----------------
    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun hasAccessibility(): Boolean {
        val expectedComponent = "$packageName/${BlockingAccessibilityService::class.java.name}"
        val enabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED, 0
        ) == 1
        if (!enabled) return false
        val services = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(services)
        for (service in splitter) {
            if (service.equals(expectedComponent, ignoreCase = true)) return true
        }
        return false
    }

    private fun hasNotificationListenerAccess(): Boolean {
        val flat = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false
        return flat.contains(packageName)
    }

    private fun isIgnoringBatteryOpts(): Boolean {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        return pm.isIgnoringBatteryOptimizations(packageName)
    }

    // ---------------- Usage queries ----------------
    private fun queryUsageEvents(startMs: Long, endMs: Long): List<Map<String, Any?>> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usm.queryEvents(startMs, endMs)
        val out = ArrayList<Map<String, Any?>>(256)
        val ev = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(ev)
            out.add(
                mapOf(
                    "packageName" to ev.packageName,
                    "eventType" to ev.eventType,
                    "timestamp" to ev.timeStamp,
                    "className" to ev.className
                )
            )
        }
        return out
    }

    /**
     * Fallback path. UsageStatsManager.queryUsageStats returns bucket-style totals.
     * On Android Q+ we prefer `totalTimeVisible` which is the conservative metric
     * Settings → Digital Wellbeing actually shows (excludes a lot of system / FGS time).
     * Falls back to `totalTimeInForeground` on older API levels.
     *
     * We also exclude system surfaces — launcher, system UI, recents, OEM launchers —
     * because users (correctly) expect screen time to count user-facing apps only.
     */
    private fun queryAggregates(startMs: Long, endMs: Long): List<Map<String, Any?>> {
        val usm = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val launchablePkgs = packageManager
            .queryIntentActivities(
                Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER),
                0
            )
            .map { it.activityInfo.packageName }
            .toSet()

        // Query day-by-day. queryUsageStats over a multi-day range can return
        // buckets that span multiple days; their totalTimeVisible/InForeground
        // covers the WHOLE bucket, not just one calendar day. Querying with
        // a 1-day window guarantees per-day-attributable totals.
        val out = ArrayList<Map<String, Any?>>()
        val cal = java.util.Calendar.getInstance()
        cal.timeInMillis = startMs
        cal.set(java.util.Calendar.HOUR_OF_DAY, 0)
        cal.set(java.util.Calendar.MINUTE, 0)
        cal.set(java.util.Calendar.SECOND, 0)
        cal.set(java.util.Calendar.MILLISECOND, 0)
        var dayStart = cal.timeInMillis

        while (dayStart < endMs) {
            val dayEnd = dayStart + 24L * 60L * 60L * 1000L
            // Clamp the last bucket to the requested end.
            val clampedEnd = if (dayEnd > endMs) endMs else dayEnd
            val list = usm.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                dayStart,
                clampedEnd
            )
            if (!list.isNullOrEmpty()) {
                // Aggregate by package within the day so multiple buckets
                // for the same app on the same day sum once, not duplicate.
                val perPkg = HashMap<String, Long>()
                val perPkgLast = HashMap<String, Long>()
                for (s in list) {
                    val pkg = s.packageName ?: continue
                    if (isExcludedSurface(pkg)) continue
                    if (!launchablePkgs.contains(pkg) && looksLikeSystemSurface(pkg)) continue
                    val ms = visibleOrForegroundMs(s)
                    if (ms <= 0L) continue
                    perPkg[pkg] = (perPkg[pkg] ?: 0L) + ms
                    if (s.lastTimeUsed > (perPkgLast[pkg] ?: 0L)) {
                        perPkgLast[pkg] = s.lastTimeUsed
                    }
                }
                for ((pkg, ms) in perPkg) {
                    out.add(
                        mapOf(
                            "packageName" to pkg,
                            "totalForegroundMs" to ms,
                            "firstTimeStamp" to dayStart,
                            "lastTimeStamp" to clampedEnd - 1,
                            "lastTimeUsed" to (perPkgLast[pkg] ?: clampedEnd - 1)
                        )
                    )
                }
            }
            dayStart = dayEnd
        }
        return out
    }

    private fun visibleOrForegroundMs(s: android.app.usage.UsageStats): Long {
        // `getTotalTimeVisible` is the metric Settings uses on Android Q+.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val visible = try { s.totalTimeVisible } catch (_: Throwable) { 0L }
            if (visible > 0L) return visible
        }
        return s.totalTimeInForeground
    }

    private val excludedExact = setOf(
        "com.wellbeingx.wellbeingx",
        "android",
        "com.android.systemui",
        "com.android.settings",
        "com.android.launcher",
        "com.android.launcher3",
        "com.google.android.apps.nexuslauncher",
        "com.bbk.launcher2",      // Vivo
        "com.miui.home",          // Xiaomi
        "com.oppo.launcher",      // Oppo
        "com.coloros.launcher",   // ColorOS
        "com.realme.launcher",    // Realme
        "com.huawei.android.launcher",
        "com.sec.android.app.launcher", // Samsung One UI
        "com.android.permissioncontroller",
        "com.google.android.permissioncontroller",
        "com.android.intentresolver"
    )

    private fun isExcludedSurface(pkg: String): Boolean = excludedExact.contains(pkg)

    private fun looksLikeSystemSurface(pkg: String): Boolean {
        return pkg.startsWith("com.android.") ||
            pkg.startsWith("android.") ||
            pkg.endsWith(".launcher") ||
            pkg.endsWith(".inputmethod") ||
            pkg.contains(".systemui") ||
            pkg.contains(".accessibility")
    }

    /**
     * Returns a PNG-encoded icon for the given package, downscaled to 144×144.
     * Returns null if the package isn't installed or the icon can't be rendered.
     * The Dart side caches the result.
     */
    private fun loadIconPng(pkg: String): ByteArray? {
        if (pkg.isEmpty()) return null
        return try {
            val drawable = packageManager.getApplicationIcon(pkg)
            val bmp = drawableToBitmap(drawable, 144, 144)
            val out = java.io.ByteArrayOutputStream()
            bmp.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, out)
            out.toByteArray()
        } catch (_: Throwable) {
            null
        }
    }

    private fun drawableToBitmap(
        d: android.graphics.drawable.Drawable,
        w: Int,
        h: Int
    ): android.graphics.Bitmap {
        if (d is android.graphics.drawable.BitmapDrawable && d.bitmap != null) {
            return android.graphics.Bitmap.createScaledBitmap(d.bitmap, w, h, true)
        }
        val bmp = android.graphics.Bitmap.createBitmap(
            w,
            h,
            android.graphics.Bitmap.Config.ARGB_8888
        )
        val canvas = android.graphics.Canvas(bmp)
        d.setBounds(0, 0, w, h)
        d.draw(canvas)
        return bmp
    }

    private fun listInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val infos = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val launchable = pm.queryIntentActivities(launcherIntent, 0)
            .map { it.activityInfo.packageName }
            .toSet()
        val out = ArrayList<Map<String, Any?>>(infos.size)
        for (info in infos) {
            val pkg = info.packageName
            // Skip pure system apps that have no launcher.
            val isSystem = (info.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            if (isSystem && !launchable.contains(pkg)) continue
            val label = pm.getApplicationLabel(info).toString()
            val cat = categoryToCode(if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) info.category else -1)
            val installedAtMs = try {
                pm.getPackageInfo(pkg, 0).firstInstallTime
            } catch (_: Throwable) { 0L }
            out.add(
                mapOf(
                    "packageName" to pkg,
                    "displayName" to label,
                    "category" to cat,
                    "installedAtMs" to installedAtMs,
                    "isSystem" to isSystem
                )
            )
        }
        return out
    }

    private fun categoryToCode(c: Int): String? = when (c) {
        ApplicationInfo.CATEGORY_SOCIAL -> "social"
        ApplicationInfo.CATEGORY_VIDEO, ApplicationInfo.CATEGORY_AUDIO,
        ApplicationInfo.CATEGORY_IMAGE -> "entertainment"
        ApplicationInfo.CATEGORY_GAME -> "gaming"
        ApplicationInfo.CATEGORY_PRODUCTIVITY -> "productivity"
        ApplicationInfo.CATEGORY_NEWS -> "entertainment"
        ApplicationInfo.CATEGORY_MAPS, ApplicationInfo.CATEGORY_ACCESSIBILITY -> "utility"
        else -> null
    }
}
