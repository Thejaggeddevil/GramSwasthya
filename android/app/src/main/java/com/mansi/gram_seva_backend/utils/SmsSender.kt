package com.mansi.gram_seva_backend.utils

import android.content.Context
import android.telephony.SmsManager
import android.widget.Toast

object SmsSender {
    fun sendSOSMessage(
        context: Context,
        message: String,
        emergencyContact: String,
        selectedContact: String?,
        sendToBoth: Boolean
    ) {
        try {
            val smsManager = SmsManager.getDefault()
            val parts = smsManager.divideMessage(message)  // ✅ Handles long message

            if (sendToBoth) {
                smsManager.sendMultipartTextMessage(emergencyContact, null, parts, null, null)
                selectedContact?.let {
                    smsManager.sendMultipartTextMessage(it, null, parts, null, null)
                }
            } else {
                selectedContact?.let {
                    smsManager.sendMultipartTextMessage(it, null, parts, null, null)
                }
            }

            Toast.makeText(context, "📤 SOS message sent", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            Toast.makeText(context, "❌ SMS failed: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }
}
