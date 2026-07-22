package com.example.spendmate

import android.content.Context
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Handler
import android.os.Looper
import org.json.JSONArray
import org.json.JSONObject

class IncomeNotificationService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        sbn?.let {
            val packageName = it.packageName
            val extras = it.notification.extras
            val title = extras.getString("android.title") ?: ""
            val text = extras.getCharSequence("android.text")?.toString() ?: ""

            // Quick pre-filter to only process likely financial notifications
            val lowerText = text.lowercase()
            if (lowerText.contains("rs") || lowerText.contains("₹") || lowerText.contains("inr") || lowerText.contains("credited") || lowerText.contains("received")) {
                val data = JSONObject().apply {
                    put("packageName", packageName)
                    put("title", title)
                    put("text", text)
                    put("notificationId", it.id.toString())
                    put("timestamp", it.postTime)
                }

                // If app is alive, send directly
                if (NotificationEventReceiver.eventSink != null) {
                    Handler(Looper.getMainLooper()).post {
                        NotificationEventReceiver.eventSink?.success(toMap(data))
                    }
                }
                
                // Always save to SharedPreferences in case flutter drops it or isn't fully ready
                saveToPending(data)
            }
        }
    }

    private fun saveToPending(data: JSONObject) {
        val prefs = getSharedPreferences("spendmate_prefs", Context.MODE_PRIVATE)
        val currentJson = prefs.getString("pending_notifications", "[]")
        try {
            val array = JSONArray(currentJson)
            array.put(data)
            prefs.edit().putString("pending_notifications", array.toString()).apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun toMap(jsonObj: JSONObject): Map<String, Any> {
        val map = HashMap<String, Any>()
        val keys = jsonObj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            map[key] = jsonObj.get(key)
        }
        return map
    }
}
