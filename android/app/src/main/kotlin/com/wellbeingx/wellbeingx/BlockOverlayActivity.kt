package com.wellbeingx.wellbeingx

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Lightweight Kotlin activity that's launched by the Accessibility service
 * the moment a blocked app comes to the foreground. Intentionally not a Flutter
 * activity so it spins up instantly, even if Flutter is cold.
 */
class BlockOverlayActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val pkg = intent.getStringExtra("packageName") ?: ""
        val mode = intent.getStringExtra("mode") ?: "soft"

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#F0050608"))
            gravity = Gravity.CENTER
            setPadding(64, 64, 64, 64)
        }

        val title = TextView(this).apply {
            text = when (mode) {
                "extreme" -> "Blocked. No bypass."
                "hard" -> "Step away."
                else -> "Pause."
            }
            setTextColor(Color.parseColor("#F5F7FB"))
            textSize = 32f
            gravity = Gravity.CENTER
        }
        val sub = TextView(this).apply {
            text = "You set a Stay-Away rule for this app. Take a breath."
            setTextColor(Color.parseColor("#A9B0BF"))
            textSize = 16f
            gravity = Gravity.CENTER
            setPadding(16, 24, 16, 32)
        }
        val pkgLabel = TextView(this).apply {
            text = pkg
            setTextColor(Color.parseColor("#6B7280"))
            textSize = 12f
            gravity = Gravity.CENTER
            setPadding(8, 8, 8, 32)
        }

        val homeBtn = Button(this).apply {
            text = "Go home"
            setBackgroundColor(Color.parseColor("#7CF6C2"))
            setTextColor(Color.parseColor("#05060A"))
            setOnClickListener {
                val home = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(home)
                finish()
            }
        }

        val openWxBtn = Button(this).apply {
            text = "Open WellbeingX"
            setBackgroundColor(Color.parseColor("#1A1E29"))
            setTextColor(Color.parseColor("#F5F7FB"))
            setOnClickListener {
                val intent = packageManager.getLaunchIntentForPackage(packageName)
                if (intent != null) startActivity(intent)
                finish()
            }
        }

        val params = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        ).apply { topMargin = 24 }

        root.addView(title)
        root.addView(sub)
        root.addView(pkgLabel)
        root.addView(homeBtn, params)
        root.addView(openWxBtn, params)

        // For "extreme" mode: hide override button.
        if (mode == "extreme") {
            openWxBtn.visibility = View.GONE
        }

        setContentView(root)
    }

    override fun onBackPressed() {
        // Block the back gesture in hard/extreme; just go home.
        val home = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(home)
        finish()
    }
}
