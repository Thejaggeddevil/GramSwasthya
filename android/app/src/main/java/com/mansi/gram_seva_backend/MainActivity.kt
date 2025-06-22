package com.mansi.gram_seva_backend

import android.Manifest
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.platform.LocalContext
import com.mansi.gram_seva_backend.SOSScreen
import com.mansi.gram_seva_backend.ui.theme.Gram_seva_backendTheme



class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Request permissions on launch
        val requestPermissionLauncher = registerForActivityResult(
            ActivityResultContracts.RequestMultiplePermissions()
        ) { permissions ->
            val granted = permissions.entries.all { it.value }
            if (!granted) {
                Toast.makeText(this, "All permissions are required!", Toast.LENGTH_LONG).show()
            }
        }

        requestPermissionLauncher.launch(
            arrayOf(
                Manifest.permission.SEND_SMS,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.READ_CONTACTS
            )
        )

        setContent {
            Gram_seva_backendTheme {
                Surface {
                    SOSScreen()
                }
            }
        }
    }
}
