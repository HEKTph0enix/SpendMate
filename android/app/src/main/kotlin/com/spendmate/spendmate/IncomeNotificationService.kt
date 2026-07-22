package com.spendmate.spendmate

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import androidx.core.app.NotificationCompat
import org.json.JSONArray
import org.json.JSONObject

class IncomeNotificationService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val notification = sbn.notification
        val extras = notification.extras

        val title = extras.getString("android.title") ?: ""
        val text = extras.getCharSequence("android.text")?.toString() ?: ""
        val timestamp = sbn.postTime
        val notificationId = sbn.id.toString()

        // Ignore our own notifications
        if (packageName == applicationContext.packageName) return

        // Basic check to see if it might be income (credit words)
        val fullText = "$title $text".lowercase()
        val creditKeywords = listOf("credited", "received", "deposited", "added to your account")
        val ignoreKeywords = listOf("debited", "paid", "sent", "failed", "otp", "pending")

        if (ignoreKeywords.any { fullText.contains(it) }) return
        if (creditKeywords.none { fullText.contains(it) }) return

        // Extract a rough amount for the local notification
        val amountRegex = Regex("(?:(?:Rs\\.?|INR|₹)\\s*)(\\d+(?:,\\d+)*(?:\\.\\d+)?)", RegexOption.IGNORE_CASE)
        val match = amountRegex.find(fullText)
        val amountStr = match?.groupValues?.getOrNull(1) ?: ""

        if (amountStr.isEmpty()) return // If no amount found, skip

        // Save locally for Flutter to read
        saveNotificationLocally(packageName, title, text, timestamp, notificationId)

        // Broadcast to MainActivity if app is running
        val intent = Intent("com.spendmate.spendmate.NOTIFICATION_EVENT")
        intent.putExtra("packageName", packageName)
        intent.putExtra("title", title)
        intent.putExtra("text", text)
        intent.putExtra("timestamp", timestamp)
        intent.putExtra("notificationId", notificationId)
        sendBroadcast(intent)

        // Show a local notification to the user
        showLocalNotification(amountStr)
    }

    private fun saveNotificationLocally(
        packageName: String,
        title: String,
        text: String,
        timestamp: Long,
        notificationId: String
    ) {
        val prefs: SharedPreferences = getSharedPreferences("spendmate_notifications", Context.MODE_PRIVATE)
        val jsonArrayStr = prefs.getString("pending_notifications", "[]")
        val jsonArray = JSONArray(jsonArrayStr)

        val jsonObj = JSONObject()
        jsonObj.put("packageName", packageName)
        jsonObj.put("title", title)
        jsonObj.put("text", text)
        jsonObj.put("timestamp", timestamp)
        jsonObj.put("notificationId", notificationId)

        jsonArray.put(jsonObj)

        prefs.edit().putString("pending_notifications", jsonArray.toString()).apply()
    }

    private fun showLocalNotification(amountStr: String) {
        val channelId = "spendmate_income_channel"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Income Detection",
                NotificationManager.IMPORTANCE_DEFAULT
            )
            notificationManager.createNotificationChannel(channel)
        }

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Possible income detected: ₹$amountStr")
            .setContentText("Tap to review in SpendMate")
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        // Not needed
    }
}
