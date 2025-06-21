package com.mansi.gram_seva_backend

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.mansi.gram_seva_backend.firebase.FirestoreManager
import com.mansi.gram_seva_backend.utils.LocationHelper

class MainActivity : ComponentActivity() {

    private lateinit var locationHelper: LocationHelper
    private lateinit var firestoreManager: FirestoreManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        locationHelper = LocationHelper(this)
        firestoreManager = FirestoreManager()

        // These values should be taken from actual input fields or login later
        val userName = "Mansi Bhandari"
        val userPhone = "+91XXXXXXXXXX" // you can pass from login/signup
        val currentTime = System.currentTimeMillis()

        locationHelper.getCurrentLocation(
            onSuccess = { loc ->
                firestoreManager.sendSOS(
                    name = userName,
                    phone = userPhone,
                    location = loc,
                    timestamp = currentTime,
                    onSuccess = {
                        println("✅ SOS saved to Firebase")
                    },
                    onFailure = {
                        println("❌ SOS save failed: ${it.message}")
                    }
                )

                // Optional: Send SMS to emergency contact from here too
                // SmsSender.sendSMS(this, emergencyContactNumber, "SOS from $userName at $loc")
            },
            onFailure = {
                println("❌ Failed to fetch location: ${it.message}")
            }
        )

        setContent {
            // You can create Composables for UI here if needed
        }
    }
}
