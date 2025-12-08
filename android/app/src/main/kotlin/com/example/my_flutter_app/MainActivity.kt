package com.example.my_flutter_app

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Base64
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.session_lock/monitoring"
    private val EVENT_CHANNEL = "com.example.session_lock/events"
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel for platform calls
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStatsPermission" -> {
                    requestUsageStatsPermission()
                    result.success(null)
                }
                "checkOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "getInstalledApps" -> {
                    result.success(getInstalledApps())
                }
                "getCurrentForegroundApp" -> {
                    result.success(getCurrentForegroundApp())
                }
                "startMonitoringService" -> {
                    val trackedApps = call.argument<List<String>>("trackedApps") ?: emptyList()
                    startMonitoringService(trackedApps)
                    result.success(true)
                }
                "stopMonitoringService" -> {
                    stopMonitoringService()
                    result.success(true)
                }
                "showBlockingScreen" -> {
                    val remainingTimeMs = call.argument<Int>("remainingTimeMs") ?: 0
                    showBlockingScreen(remainingTimeMs)
                    result.success(null)
                }
                "hideBlockingScreen" -> {
                    hideBlockingScreen()
                    result.success(null)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    requestIgnoreBatteryOptimizations()
                    result.success(null)
                }
                "isMonitoringServiceRunning" -> {
                    result.success(ForegroundMonitorService.isRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Event channel for foreground app updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    ForegroundMonitorService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    ForegroundMonitorService.eventSink = null
                }
            }
        )
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivity(intent)
        }
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
            intent.data = Uri.parse("package:$packageName")
            startActivity(intent)
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        
        return apps.filter { app ->
            // Filter out system apps and our own app
            (app.flags and ApplicationInfo.FLAG_SYSTEM) == 0 && app.packageName != packageName
        }.map { app ->
            mapOf(
                "packageName" to app.packageName,
                "appName" to pm.getApplicationLabel(app).toString(),
                "iconBase64" to getAppIconBase64(app.packageName)
            )
        }.sortedBy { it["appName"] as String }
    }

    private fun getAppIconBase64(packageName: String): String? {
        return try {
            val icon = packageManager.getApplicationIcon(packageName)
            val bitmap = drawableToBitmap(icon)
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT)
        } catch (e: Exception) {
            null
        }
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        if (drawable is BitmapDrawable) {
            return drawable.bitmap
        }

        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth.coerceAtLeast(1),
            drawable.intrinsicHeight.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )

        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun getCurrentForegroundApp(): String? {
        if (!hasUsageStatsPermission()) return null

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val beginTime = endTime - 1000 * 10 // Last 10 seconds

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

    private fun startMonitoringService(trackedApps: List<String>) {
        val intent = Intent(this, ForegroundMonitorService::class.java)
        intent.putStringArrayListExtra("trackedApps", ArrayList(trackedApps))
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopMonitoringService() {
        val intent = Intent(this, ForegroundMonitorService::class.java)
        stopService(intent)
    }

    private fun showBlockingScreen(remainingTimeMs: Int) {
        val intent = Intent(this, LockActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        intent.putExtra("remainingTimeMs", remainingTimeMs)
        startActivity(intent)
    }

    private fun hideBlockingScreen() {
        // Send broadcast to close LockActivity
        sendBroadcast(Intent("com.example.session_lock.HIDE_LOCK"))
    }
}
