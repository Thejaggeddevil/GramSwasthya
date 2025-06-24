package com.mansi.gram_seva_backend

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.ContactsContract
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import com.mansi.gram_seva_backend.R
import com.mansi.gram_seva_backend.data.UserContact
import com.mansi.gram_seva_backend.utils.LocationHelper
import com.mansi.gram_seva_backend.utils.SmsSender
import com.mansi.gram_seva_backend.firebase.FirestoreManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Composable
fun SOSScreen() {
    val context = LocalContext.current
    var selectedContact by remember { mutableStateOf<UserContact?>(null) }
    var emergencyContact by remember {
        mutableStateOf(UserContact("+919876543210", "Default Emergency","abc@gmail.com"))
    }
    var language by remember { mutableStateOf("English") }

    // 👇 For picking contact from phonebook
    val contactPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            val uri: Uri? = result.data?.data
            uri?.let {
                val cursor = context.contentResolver.query(
                    it,
                    arrayOf(
                        ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                        ContactsContract.CommonDataKinds.Phone.NUMBER,
                        ContactsContract.CommonDataKinds.Email.ADDRESS
                    ),
                    null,
                    null,
                    null
                )
                cursor?.moveToFirst()
                val name = cursor?.getString(0) ?: "Unknown"
                val number = cursor?.getString(1) ?: ""
                val email = cursor?.getString(2) ?: ""
                selectedContact = UserContact(number, name,email)
                FirestoreManager.saveContact(UserContact(number, name,email))
                cursor?.close()
            }
        }
    }

    // 👇 UI Layout
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {

        // 🔘 Pick Emergency Contact
        Button(onClick = {
            val intent = Intent(Intent.ACTION_PICK, ContactsContract.CommonDataKinds.Phone.CONTENT_URI)
            contactPickerLauncher.launch(intent)
        }) {
            Text(stringResource(R.string.pick_emergency_contact))
        }

        // 🔴 Send SOS Button
        Button(onClick = {
            CoroutineScope(Dispatchers.Main).launch {
                try {
                    val location = LocationHelper.getLastKnownLocation(context)
                    if (location != null) {
                        val mapsLink = "https://maps.google.com/?q=${location.latitude},${location.longitude}"
                        val msg = "🚨 SOS: Need help!\nLocation: $mapsLink"

                        SmsSender.sendSOSMessage(
                            context = context,
                            message = msg,
                            emergencyContact = emergencyContact.phone,
                            selectedContact = selectedContact?.phone,
                            sendToBoth = true
                        )

                        FirestoreManager.saveSOS(
                            userName = selectedContact?.name ?: "Anonymous",
                            phoneNumber = selectedContact?.phone ?: "Unknown",
                            email = selectedContact?.email ?: "Unknown",
                            latitude = location.latitude,
                            longitude = location.longitude,
                            language = language
                        )

                        Toast.makeText(context, context.getString(R.string.sos_sent), Toast.LENGTH_SHORT).show()
                    } else {
                        Toast.makeText(context, context.getString(R.string.location_not_found), Toast.LENGTH_SHORT).show()
                    }
                } catch (e: Exception) {
                    Toast.makeText(context, context.getString(R.string.location_error), Toast.LENGTH_SHORT).show()
                }
            }
        }) {
            Text(stringResource(R.string.send_sos))
        }

        // 🌐 Language Buttons (English / Hindi)
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Button(onClick = {
                language = "English"
                FirestoreManager.saveUserLanguage("English")
            }) { Text(stringResource(R.string.english)) }

            Button(onClick = {
                language = "Hindi"
                FirestoreManager.saveUserLanguage("Hindi")
            }) { Text(stringResource(R.string.hindi)) }
        }
    }
}
