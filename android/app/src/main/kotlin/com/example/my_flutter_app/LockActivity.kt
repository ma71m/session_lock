package com.example.my_flutter_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.os.CountDownTimer
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class LockActivity : AppCompatActivity() {
    private var countDownTimer: CountDownTimer? = null
    private lateinit var timerText: TextView
    private lateinit var messageText: TextView
    private var remainingTimeMs: Int = 0

    private val hideReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            finish()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make activity full screen and show on lock screen
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        setContentView(R.layout.activity_lock)

        timerText = findViewById(R.id.timer_text)
        messageText = findViewById(R.id.message_text)
        val closeButton: Button = findViewById(R.id.close_button)

        remainingTimeMs = intent.getIntExtra("remainingTimeMs", 0)

        messageText.text = "Break in progress"
        
        startCountdown()

        closeButton.setOnClickListener {
            // For now, just close (can add PIN/biometric later)
            finish()
        }

        // Register receiver to hide this activity
        registerReceiver(hideReceiver, IntentFilter("com.example.session_lock.HIDE_LOCK"))
    }

    private fun startCountdown() {
        countDownTimer?.cancel()
        
        countDownTimer = object : CountDownTimer(remainingTimeMs.toLong(), 1000) {
            override fun onTick(millisUntilFinished: Long) {
                val minutes = (millisUntilFinished / 1000) / 60
                val seconds = (millisUntilFinished / 1000) % 60
                timerText.text = String.format("%02d:%02d", minutes, seconds)
            }

            override fun onFinish() {
                timerText.text = "00:00"
                finish()
            }
        }.start()
    }

    override fun onDestroy() {
        super.onDestroy()
        countDownTimer?.cancel()
        try {
            unregisterReceiver(hideReceiver)
        } catch (e: Exception) {
            // Receiver not registered
        }
    }

    override fun onBackPressed() {
        // Prevent back button from closing
        // User must wait for timer
    }
}
