package com.spendmate.spendmate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "spendmate.notification.methods"
    private val EVENT_CHANNEL = "spendmate.notification.events"

    private var eventSink: EventChannel.EventSink? = null

    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val packageName = intent.getStringExtra("packageName") ?: ""
            val title = intent.getStringExtra("title") ?: ""
            val text = intent.getStringExtra("text") ?: ""
            val timestamp = intent.getLongExtra("timestamp", 0)
            val notificationId = intent.getStringExtra("notificationId") ?: ""

            val map = mapOf(
                "packageName" to packageName,
                "title" to title,
                "text" to text,
                "timestamp" to timestamp,
                "notificationId" to notificationId
            )
            eventSink?.success(map)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationListenerEnabled" -> {
                    result.success(isNotificationListenerEnabled(context))
                }
                "openNotificationListenerSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(true)
                }
                "getPendingNotifications" -> {
                    val prefs: SharedPreferences = getSharedPreferences("spendmate_notifications", Context.MODE_PRIVATE)
                    val jsonArrayStr = prefs.getString("pending_notifications", "[]")
                    result.success(jsonArrayStr)
                }
                "clearPendingNotifications" -> {
                    val prefs: SharedPreferences = getSharedPreferences("spendmate_notifications", Context.MODE_PRIVATE)
                    prefs.edit().putString("pending_notifications", "[]").apply()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Setup Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val filter = IntentFilter("com.spendmate.spendmate.NOTIFICATION_EVENT")
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(notificationReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                    } else {
                        registerReceiver(notificationReceiver, filter)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    try {
                        unregisterReceiver(notificationReceiver)
                    } catch (e: Exception) {
                        // ignore
                    }
                }
            }
        )
    }

    private fun isNotificationListenerEnabled(context: Context): Boolean {
        val packageNames = NotificationManagerCompat.getEnabledListenerPackages(context)
        return packageNames.contains(context.packageName)
    }
}
