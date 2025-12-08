package com.example.my_flutter_app

import android.app.*
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel

class ForegroundMonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var trackedApps: List<String> = emptyList()
    private var currentForegroundApp: String? = null
    private val pollInterval = 500L // Poll every 500ms

    companion object {
        var isRunning = false
        var eventSink: EventChannel.EventSink? = null
        private const val NOTIFICATION_ID = 1
        private const val CHANNEL_ID = "monitoring_channel"
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        trackedApps = intent?.getStringArrayListExtra("trackedApps") ?: emptyList()

        // Start foreground service with notification
        val notification = createNotification()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID, 
                notification, 
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Start polling
        startPolling()

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        handler.removeCallbacksAndMessages(null)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Session Monitoring",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors your social media usage"
                setShowBadge(false)
            }

            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SessionLock Active")
            .setContentText("Monitoring your social media usage")
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun startPolling() {
        handler.post(object : Runnable {
            override fun run() {
                checkForegroundApp()
                handler.postDelayed(this, pollInterval)
            }
        })
    }

    private fun checkForegroundApp() {
        val foregroundApp = getCurrentForegroundApp()
        
        if (foregroundApp != currentForegroundApp) {
            currentForegroundApp = foregroundApp
            
            // Send event to Flutter
            foregroundApp?.let { packageName ->
                eventSink?.success(packageName)
            }
        }
    }

    private fun getCurrentForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 1000 * 2 // Last 2 seconds

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            beginTime,
            endTime
        )

        if (stats.isNullOrEmpty()) return null

        // Get most recently used app
        val sortedStats = stats.sortedByDescending { it.lastTimeUsed }
        return sortedStats.firstOrNull()?.packageName
    }
}
