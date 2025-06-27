package com.mansi.gram_seva_backend.utils

import android.content.Context
import android.location.Location
import android.util.Log
import com.mansi.gram_seva_backend.data.PlaceInfo
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

object LocationHelper {
    suspend fun getNearestPlace(
        context: Context,
        query: String,
        userLat: Double,
        userLon: Double
    ): PlaceInfo? {
        return withContext(Dispatchers.IO) {
            try {
                val baseUrl = "https://nominatim.openstreetmap.org/search"
                val encodedQuery = URLEncoder.encode(query, "UTF-8")
                val url = URL("$baseUrl?format=json&q=$encodedQuery&lat=$userLat&lon=$userLon&limit=1")

                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "GET"
                conn.setRequestProperty("User-Agent", "GramSwasthyaApp/1.0")
                conn.connectTimeout = 10000
                conn.readTimeout = 10000

                val responseCode = conn.responseCode
                if (responseCode == 200) {
                    val inputStream = conn.inputStream
                    val response = inputStream.bufferedReader().use { it.readText() }
                    val jsonArray = JSONArray(response)

                    if (jsonArray.length() > 0) {
                        val obj = jsonArray.getJSONObject(0)
                        val name = obj.optString("display_name")
                        val lat = obj.optDouble("lat")
                        val lon = obj.optDouble("lon")
                        return@withContext PlaceInfo(name, lat, lon)
                    }
                } else {
                    Log.e("LocationHelper", "HTTP error code: $responseCode")
                }
            } catch (e: Exception) {
                Log.e("LocationHelper", "Exception: ${e.message}")
            }
            return@withContext null
        }
    }
}
