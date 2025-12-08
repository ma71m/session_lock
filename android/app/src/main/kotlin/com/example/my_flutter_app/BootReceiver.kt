package com.example.session_lock

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Restart monitoring service if it was running before reboot
            // This would require checking SharedPreferences for monitoring state
            // For now, user needs to manually restart
        }
    }
}
