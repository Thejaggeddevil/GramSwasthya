package com.mansi.gram_seva_backend.utils


import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONArray

object NearbyPlaceHelper {

    private val client = OkHttpClient()

    suspend fun getNearestPlace(lat: Double, lon: Double, query: String): String? {
        val url = "https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=1&lat=$lat&lon=$lon"

        return withContext(Dispatchers.IO) {
            try {
                val request = Request.Builder()
                    .url(url)
                    .header("User-Agent", "GramSwasthyaApp")
                    .build()

                val response = client.newCall(request).execute()
                val jsonString = response.body?.string()
                val jsonArray = JSONArray(jsonString)

                if (jsonArray.length() > 0) {
                    val obj = jsonArray.getJSONObject(0)
                    val displayName = obj.getString("display_name")
                    "📍 $displayName"
                } else {
                    null
                }
            } catch (e: Exception) {
                Log.e("NearbyPlaceHelper", "Error fetching nearest place", e)
                null
            }
        }
    }
}
