import 'package:flutter/foundation.dart';
import 'package:another_telephony/telephony.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class SmsSender {
  static final Telephony _telephony = Telephony.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send SOS message to emergency contacts
  static Future<bool> sendSOSMessage({
    required List<String> emergencyContacts,
    required String userName,
    required String userPhone,
    String? customMessage,
    bool sendToAll = true,
  }) async {
    try {
      // Get current location
      final location = await _getCurrentLocation();
      final locationText = location ?? 'Location unavailable';

      // Create SOS message
      final message =
          customMessage ??
          _createSOSMessage(
            userName: userName,
            userPhone: userPhone,
            location: locationText,
          );

      // Check platform and send SMS accordingly
      if (kIsWeb || Platform.isWindows) {
        // For web/desktop, log to Firestore only
        await _logSOSToFirestore(
          userName: userName,
          userPhone: userPhone,
          location: locationText,
          contactsNotified: emergencyContacts,
          message: message,
        );
        return true;
      } else {
        // For mobile platforms, send actual SMS
        return await _sendSMSToContacts(
          contacts: emergencyContacts,
          message: message,
          sendToAll: sendToAll,
        );
      }
    } catch (e) {
      debugPrint('SMS Sender Error: $e');
      return false;
    }
  }

  /// Send SMS to multiple contacts
  static Future<bool> _sendSMSToContacts({
    required List<String> contacts,
    required String message,
    required bool sendToAll,
  }) async {
    try {
      // Request SMS permissions
      bool? permissionsGranted = await _telephony.requestSmsPermissions;

      if (permissionsGranted != true) {
        throw Exception('SMS permissions not granted');
      }

      // Check if device can send SMS
      bool? isSmsCapable = await _telephony.isSmsCapable;
      if (isSmsCapable != true) {
        throw Exception('Device cannot send SMS');
      }

      // Send SMS to contacts
      int successCount = 0;
      for (String contact in contacts) {
        try {
          await _telephony.sendSms(to: contact, message: message);
          successCount++;

          // Add small delay between messages to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('Failed to send SMS to $contact: $e');
        }
      }

      return successCount > 0;
    } catch (e) {
      debugPrint('SMS sending failed: $e');
      return false;
    }
  }

  /// Get current location
  static Future<String?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services disabled';
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permission permanently denied';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Create Google Maps link
      final mapsLink =
          'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      return 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}\nMaps: $mapsLink';
    } catch (e) {
      debugPrint('Location error: $e');
      return 'Location unavailable';
    }
  }

  /// Create SOS message
  static String _createSOSMessage({
    required String userName,
    required String userPhone,
    required String location,
  }) {
    final timestamp = DateTime.now().toString().substring(0, 19);

    return '''🚨 SOS EMERGENCY ALERT 🚨

$userName needs immediate assistance!

📱 User Phone: $userPhone
📍 Location: $location
⏰ Time: $timestamp

Please respond immediately!
This is an automated emergency alert from Gram Seva App.''';
  }

  /// Log SOS to Firestore
  static Future<void> _logSOSToFirestore({
    required String userName,
    required String userPhone,
    required String location,
    required List<String> contactsNotified,
    required String message,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('sos_history').add({
          'userId': user.uid,
          'userName': userName,
          'userPhone': userPhone,
          'location': location,
          'contactsNotified': contactsNotified,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'sent',
          'platform':
              kIsWeb
                  ? 'web'
                  : Platform.isWindows
                  ? 'windows'
                  : 'mobile',
        });
      }
    } catch (e) {
      debugPrint('Failed to log SOS to Firestore: $e');
    }
  }

  /// Send custom message to specific contact
  static Future<bool> sendCustomMessage({
    required String contact,
    required String message,
  }) async {
    try {
      if (kIsWeb || Platform.isWindows) {
        // For web/desktop, just log the message
        await _logCustomMessageToFirestore(contact, message);
        return true;
      } else {
        // For mobile, send actual SMS
        bool? permissionsGranted = await _telephony.requestSmsPermissions;
        if (permissionsGranted == true) {
          await _telephony.sendSms(to: contact, message: message);
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Custom message sending failed: $e');
      return false;
    }
  }

  /// Log custom message to Firestore
  static Future<void> _logCustomMessageToFirestore(
    String contact,
    String message,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('custom_messages').add({
          'userId': user.uid,
          'contact': contact,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'platform':
              kIsWeb
                  ? 'web'
                  : Platform.isWindows
                  ? 'windows'
                  : 'mobile',
        });
      }
    } catch (e) {
      debugPrint('Failed to log custom message: $e');
    }
  }

  /// Check SMS permissions
  static Future<bool> checkSmsPermissions() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        return true; // No SMS permissions needed for web/desktop
      }

      bool? permissionsGranted = await _telephony.requestSmsPermissions;
      return permissionsGranted == true;
    } catch (e) {
      debugPrint('Permission check failed: $e');
      return false;
    }
  }

  /// Check if device can send SMS
  static Future<bool> isSmsCapable() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        return false; // Web/desktop cannot send SMS
      }

      bool? isCapable = await _telephony.isSmsCapable;
      return isCapable == true;
    } catch (e) {
      debugPrint('SMS capability check failed: $e');
      return false;
    }
  }

  /// Get SOS history for current user
  static Stream<QuerySnapshot> getSOSHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return _firestore
          .collection('sos_history')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    }
    return const Stream.empty();
  }
}
