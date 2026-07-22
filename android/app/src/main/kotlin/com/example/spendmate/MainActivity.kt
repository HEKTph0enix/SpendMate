package com.example.spendmate

import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "spendmate.notification.methods"
    private val EVENT_CHANNEL = "spendmate.notification.events"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationListenerEnabled" -> {
                    val isEnabled = isNotificationListenerEnabled(context)
                    result.success(isEnabled)
                }
                "openNotificationListenerSettings" -> {
                    val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    startActivity(intent)
                    result.success(null)
                }
                "getPendingNotifications" -> {
                    val prefs = getSharedPreferences("spendmate_prefs", Context.MODE_PRIVATE)
                    val jsonStr = prefs.getString("pending_notifications", "[]")
                    result.success(jsonStr)
                }
                "clearPendingNotifications" -> {
                    val prefs = getSharedPreferences("spendmate_prefs", Context.MODE_PRIVATE)
                    prefs.edit().putString("pending_notifications", "[]").apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    NotificationEventReceiver.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    NotificationEventReceiver.eventSink = null
                }
            }
        )
    }

    private fun isNotificationListenerEnabled(context: Context): Boolean {
        return NotificationManagerCompat.getEnabledListenerPackages(context).contains(context.packageName)
    }
}

object NotificationEventReceiver {
    var eventSink: EventChannel.EventSink? = null
}
