package com.example.gram_seva

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.Manifest
import android.content.Intent
import android.provider.ContactsContract
import android.net.Uri
import android.content.Context
import android.location.Location
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import android.location.LocationManager
import android.telephony.SmsManager
import com.google.firebase.firestore.FirebaseFirestore
import java.util.*
import android.net.ConnectivityManager
import android.net.NetworkCapabilities

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.mansi.gram_seva_backend/sos"
    private val SMS_PERMISSION_REQUEST = 100
    private val LOCATION_PERMISSION_REQUEST = 101
    private val CONTACT_PICKER_REQUEST = 102

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSOSMessage" -> {
                    val message = call.argument<String>("message") ?: ""
                    val emergencyContact = call.argument<String>("emergencyContact") ?: ""
                    val selectedContact = call.argument<String?>("selectedContact")
                    val sendToBoth = call.argument<Boolean>("sendToBoth") ?: true
                    
                    sendSOSMessage(message, emergencyContact, selectedContact, sendToBoth, result)
                }
                "getCurrentLocation" -> {
                    getCurrentLocation(result)
                }
                "saveSOSToFirestore" -> {
                    val userName = call.argument<String>("userName") ?: ""
                    val phoneNumber = call.argument<String>("phoneNumber") ?: ""
                    val latitude = call.argument<Double>("latitude") ?: 0.0
                    val longitude = call.argument<Double>("longitude") ?: 0.0
                    val language = call.argument<String>("language") ?: "English"
                    
                    saveSOSToFirestore(userName, phoneNumber, latitude, longitude, language, result)
                }
                "pickContact" -> {
                    pickContact(result)
                }
                "checkPermissions" -> {
                    checkPermissions(result)
                }
                "checkNetworkConnectivity" -> {
                    checkNetworkConnectivity(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendSOSMessage(
        message: String,
        emergencyContact: String,
        selectedContact: String?,
        sendToBoth: Boolean,
        result: MethodChannel.Result
    ) {
        try {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
                result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                return
            }

            val smsManager = SmsManager.getDefault()
            val parts = smsManager.divideMessage(message)

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

            result.success("SMS sent successfully")
        } catch (e: Exception) {
            result.error("SMS_FAILED", "Failed to send SMS: ${e.message}", null)
        }
    }

    private fun getCurrentLocation(result: MethodChannel.Result) {
        try {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
            ) {
                result.error("PERMISSION_DENIED", "Location permission not granted", null)
                return
            }

            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val providers = locationManager.getProviders(true)
            var bestLocation: Location? = null

            for (provider in providers) {
                val location = locationManager.getLastKnownLocation(provider) ?: continue
                if (bestLocation == null || location.accuracy < bestLocation.accuracy) {
                    bestLocation = location
                }
            }

            if (bestLocation != null) {
                val locationData = mapOf(
                    "latitude" to bestLocation.latitude,
                    "longitude" to bestLocation.longitude,
                    "accuracy" to bestLocation.accuracy
                )
                result.success(locationData)
            } else {
                result.error("LOCATION_NOT_FOUND", "Could not get location", null)
            }
        } catch (e: Exception) {
            result.error("LOCATION_ERROR", "Error getting location: ${e.message}", null)
        }
    }

    private fun saveSOSToFirestore(
        userName: String,
        phoneNumber: String,
        latitude: Double,
        longitude: Double,
        language: String,
        result: MethodChannel.Result
    ) {
        try {
            val db = FirebaseFirestore.getInstance()
            
            // Check if Firebase is available
            if (!db.app.isDataCollectionDefaultEnabled) {
                result.error("FIRESTORE_OFFLINE", "Firebase is offline or not configured", null)
                return
            }

            val sosData = hashMapOf(
                "userName" to userName,
                "phoneNumber" to phoneNumber,
                "latitude" to latitude,
                "longitude" to longitude,
                "language" to language,
                "timestamp" to Date()
            )
            
            db.collection("sos_history")
                .add(sosData)
                .addOnSuccessListener {
                    result.success("SOS saved to Firestore")
                }
                .addOnFailureListener { e ->
                    if (e.message?.contains("offline") == true || e.message?.contains("network") == true) {
                        result.error("FIRESTORE_OFFLINE", "Firebase is offline. SOS will be saved when connection is restored.", null)
                    } else {
                        result.error("FIRESTORE_ERROR", "Failed to save SOS: ${e.message}", null)
                    }
                }
        } catch (e: Exception) {
            if (e.message?.contains("offline") == true || e.message?.contains("network") == true) {
                result.error("FIRESTORE_OFFLINE", "Firebase is offline. SOS will be saved when connection is restored.", null)
            } else {
                result.error("FIRESTORE_ERROR", "Error saving SOS: ${e.message}", null)
            }
        }
    }

    private fun pickContact(result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
        startActivityForResult(intent, CONTACT_PICKER_REQUEST)
        // Note: This will need to be handled in onActivityResult
        result.success("Contact picker launched")
    }

    private fun checkPermissions(result: MethodChannel.Result) {
        val smsPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED
        val locationPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
                                ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val contactPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED

        val permissions = mapOf(
            "sms" to smsPermission,
            "location" to locationPermission,
            "contacts" to contactPermission
        )
        
        result.success(permissions)
    }

    private fun checkNetworkConnectivity(result: MethodChannel.Result) {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val networkCapabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
        val isConnected = networkCapabilities != null &&
                          networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)

        result.success(isConnected)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == CONTACT_PICKER_REQUEST && resultCode == RESULT_OK) {
            val uri: Uri? = data?.data
            uri?.let {
                val cursor = contentResolver.query(
                    it,
                    arrayOf(
                        ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                        ContactsContract.CommonDataKinds.Phone.NUMBER
                    ),
                    null,
                    null,
                    null
                )
                cursor?.moveToFirst()
                val name = cursor?.getString(0) ?: "Unknown"
                val number = cursor?.getString(1) ?: ""
                cursor?.close()
                
                // Send the contact data back to Flutter
                val contactData = mapOf(
                    "name" to name,
                    "phone" to number
                )
                // You would need to implement a way to send this back to Flutter
                // This could be done through a callback or event channel
            }
        }
    }
}
