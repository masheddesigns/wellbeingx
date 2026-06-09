package com.wellbeingx.wellbeingx

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class BlockingAccessibilityService : AccessibilityService() {

    private var lastBlockedPkg: String? = null
    private var lastTriggerMs: Long = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        // Ignore our own UI and system UI.
        if (pkg == applicationContext.packageName ||
            pkg == "com.android.systemui" ||
            pkg == "android"
        ) return

        val (blocked, mode) = BlockingState.isBlocked(applicationContext, pkg)
        if (!blocked) {
            lastBlockedPkg = null
            return
        }

        val now = System.currentTimeMillis()
        // Debounce — accessibility can fire many events per ms.
        if (pkg == lastBlockedPkg && now - lastTriggerMs < 800L) return
        lastBlockedPkg = pkg
        lastTriggerMs = now

        NativeEventBus.emit(
            mapOf(
                "type" to "block.attempt",
                "packageName" to pkg,
                "mode" to mode,
                "timestamp" to now
            )
        )

        when (mode) {
            "extreme", "hard" -> {
                // Drop the user back home.
                performGlobalAction(GLOBAL_ACTION_HOME)
                showOverlay(pkg, mode)
            }
            else -> showOverlay(pkg, mode)
        }
    }

    private fun showOverlay(pkg: String, mode: String) {
        val intent = Intent(this, BlockOverlayActivity::class.java).apply {
            putExtra("packageName", pkg)
            putExtra("mode", mode)
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_NO_HISTORY or
                    Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
            )
        }
        startActivity(intent)
    }

    override fun onInterrupt() = Unit
}
