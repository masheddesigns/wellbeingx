package com.wellbeingx.wellbeingx

import android.content.Context
import android.content.SharedPreferences

/**
 * Shared-preferences-backed snapshot of which packages are currently blocked
 * and in which mode. The Accessibility service reads from here on every
 * window-state-changed event — keeping it in shared prefs avoids needing
 * an IPC binding between the service and the Flutter side.
 */
object BlockingState {
    private const val PREFS = "wx_block_state"
    private const val KEY_PKGS = "pkgs"
    private const val KEY_MODE = "mode"
    private const val KEY_UNTIL = "until_ms"

    fun set(ctx: Context, packages: Set<String>, mode: String, untilMs: Long?) {
        prefs(ctx).edit().apply {
            putStringSet(KEY_PKGS, packages)
            putString(KEY_MODE, mode)
            if (untilMs == null) remove(KEY_UNTIL) else putLong(KEY_UNTIL, untilMs)
            apply()
        }
    }

    fun clear(ctx: Context) {
        prefs(ctx).edit().clear().apply()
    }

    fun isBlocked(ctx: Context, pkg: String): Pair<Boolean, String> {
        val p = prefs(ctx)
        val until = p.getLong(KEY_UNTIL, -1L)
        if (until > 0 && System.currentTimeMillis() > until) {
            clear(ctx)
            return false to "soft"
        }
        val pkgs = p.getStringSet(KEY_PKGS, emptySet()) ?: emptySet()
        if (!pkgs.contains(pkg)) return false to "soft"
        return true to (p.getString(KEY_MODE, "soft") ?: "soft")
    }

    private fun prefs(ctx: Context): SharedPreferences =
        ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
