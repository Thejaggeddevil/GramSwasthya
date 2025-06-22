package com.mansi.gram_seva_backend.firebase

import com.google.firebase.firestore.FirebaseFirestore
import com.mansi.gram_seva_backend.data.UserContact
import java.util.*

object FirestoreManager {
    private val db = FirebaseFirestore.getInstance()

    fun saveSOS(
        userName: String,
        phoneNumber: String,
        latitude: Double,
        longitude: Double,
        language: String
    ) {
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
    }

    fun saveContact(contact: UserContact) {
        db.collection("emergency_contacts")
            .add(hashMapOf("name" to contact.name, "phone" to contact.phone))
    }

    fun saveUserLanguage(language: String) {
        db.collection("preferences")
            .document("language")
            .set(mapOf("selected_language" to language))
    }
}
