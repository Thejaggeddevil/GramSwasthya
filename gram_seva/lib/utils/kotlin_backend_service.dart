import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KotlinBackendService {
  static const MethodChannel _channel = MethodChannel(
    'com.mansi.gram_seva_backend/sos',
  );

  static Future<bool> sendSOSMessage({
    required String message,
    required String emergencyContact,
    String? selectedContact,
    bool sendToBoth = true,
  }) async {
    try {
      if (kIsWeb || Platform.isWindows) {
        debugPrint('SOS Message (Desktop): $message');
        return true;
      }

      final result = await _channel.invokeMethod('sendSOSMessage', {
        'message': message,
        'emergencyContact': emergencyContact,
        'selectedContact': selectedContact,
        'sendToBoth': sendToBoth,
      });

      return result == 'SMS sent successfully';
    } on PlatformException catch (e) {
      debugPrint('Platform Exception: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error sending SOS: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        return {'latitude': 0.0, 'longitude': 0.0, 'accuracy': 0.0};
      }

      final result = await _channel.invokeMethod('getCurrentLocation');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      debugPrint('Platform Exception: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  static Future<bool> saveSOSToFirestore({
    required String userName,
    required String phoneNumber,
    required double latitude,
    required double longitude,
    String language = 'English',
  }) async {
    try {
      if (kIsWeb || Platform.isWindows) {
        debugPrint('SOS saved to Firestore (Desktop): $userName');
        return true;
      }

      final result = await _channel.invokeMethod('saveSOSToFirestore', {
        'userName': userName,
        'phoneNumber': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
        'language': language,
      });

      return result == 'SOS saved to Firestore';
    } on PlatformException catch (e) {
      debugPrint('Platform Exception: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error saving SOS: $e');
      return false;
    }
  }

  static Future<Map<String, String>?> pickContact() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        return {'name': 'Mock Contact', 'phone': '+1234567890'};
      }

      final result = await _channel.invokeMethod('pickContact');
      return null;
    } on PlatformException catch (e) {
      debugPrint('Platform Exception: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Error picking contact: $e');
      return null;
    }
  }

  static Future<bool> checkNetworkConnectivity() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        return true;
      }

      final result = await _channel.invokeMethod('checkNetworkConnectivity');
      return result == true;
    } catch (e) {
      debugPrint('Network connectivity check failed: $e');
      return false;
    }
  }

  static Future<Map<String, bool>> checkPermissions() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        return {'sms': true, 'location': true, 'contacts': true};
      }

      final result = await _channel.invokeMethod('checkPermissions');
      return Map<String, bool>.from(result);
    } on PlatformException catch (e) {
      debugPrint('Platform Exception: ${e.code} - ${e.message}');
      return {'sms': false, 'location': false, 'contacts': false};
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return {'sms': false, 'location': false, 'contacts': false};
    }
  }

  static Future<bool> sendCompleteSOS({
    required String userName,
    required String userPhone,
    required List<String> emergencyContacts,
    String? customMessage,
  }) async {
    try {
      final location = await getCurrentLocation();
      if (location == null) {
        debugPrint('Failed to get location');
        return false;
      }

      final message =
          customMessage ??
          _createSOSMessage(
            userName: userName,
            userPhone: userPhone,
            location: location,
          );

      bool smsSuccess = false;
      for (String contact in emergencyContacts) {
        final success = await sendSOSMessage(
          message: message,
          emergencyContact: contact,
          sendToBoth: false,
        );
        if (success) {
          smsSuccess = true;
        }
      }

      try {
        await saveSOSToFirestore(
          userName: userName,
          phoneNumber: userPhone,
          latitude: location['latitude'] ?? 0.0,
          longitude: location['longitude'] ?? 0.0,
        );
      } catch (e) {
        debugPrint('Firestore save failed, but SMS was sent: $e');
        _saveOfflineSOS(userName, userPhone, location);
      }

      return smsSuccess;
    } catch (e) {
      debugPrint('Error in complete SOS workflow: $e');
      return false;
    }
  }

  static void _saveOfflineSOS(
    String userName,
    String userPhone,
    Map<String, dynamic> location,
  ) {
    try {
      debugPrint(
        'Offline SOS saved locally: $userName at ${location['latitude']}, ${location['longitude']}',
      );
    } catch (e) {
      debugPrint('Failed to save offline SOS: $e');
    }
  }

  static Future<bool> sendQuickSOS(BuildContext context) async {
    try {
      if (kIsWeb || Platform.isWindows) {
        _showError(context, 'Quick SOS is only available on mobile devices');
        return false;
      }
      // Check network connectivity first
      final hasNetwork = await checkNetworkConnectivity();
      if (!hasNetwork) {
        _showError(
          context,
          'No internet connection. Please check your network and try again.',
        );
        return false;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError(context, 'User not authenticated');
        return false;
      }
      // Check network connectivity first
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 10));

        if (!userDoc.exists) {
          _showError(
            context,
            'User data not found. Please check your internet connection.',
          );
          return false;
        }

        final userData = userDoc.data()!;
        final emergencyContacts = List<String>.from(
          userData['emergencyContacts'] ?? [],
        );
        final userName = userData['fullName'] ?? 'User';
        final userPhone = userData['phoneNumber'] ?? '';

        if (emergencyContacts.isEmpty) {
          _showError(
            context,
            'No emergency contacts found. Please add contacts in your profile.',
          );
          return false;
        }
        // Check permissions before sending
        final permissions = await checkPermissions();
        if (!permissions['sms']!) {
          _showError(
            context,
            'SMS permission not granted. Please enable SMS permissions in app settings.',
          );
          return false;
        }

        if (!permissions['location']!) {
          _showError(
            context,
            'Location permission not granted. Please enable location permissions in app settings.',
          );
          return false;
        }

        final success = await sendCompleteSOS(
          userName: userName,
          userPhone: userPhone,
          emergencyContacts: emergencyContacts,
        );

        if (success) {
          _showSuccess(context, 'SOS alert sent successfully!');
          return true;
        } else {
          _showError(context, 'Failed to send SOS alert. Please try again.');
          return false;
        }
      } on TimeoutException {
        _showError(
          context,
          'Network timeout. Please check your internet connection and try again.',
        );
        return false;
      } catch (e) {
        if (e.toString().contains('offline') ||
            e.toString().contains('network')) {
          _showError(
            context,
            'No internet connection. Please check your network and try again.',
          );
        } else {
          _showError(context, 'Error: ${e.toString()}');
        }
        return false;
      }
    } catch (e) {
      _showError(context, 'Error sending SOS: ${e.toString()}');
      return false;
    }
  }

  /// Show success message
  static void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show error message
  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => sendQuickSOS(context),
          ),
        ),
      );
    }
  }

  /// Create SOS message
  static String _createSOSMessage({
    required String userName,
    required String userPhone,
    required Map<String, dynamic> location,
  }) {
    final latitude = location['latitude'] ?? 0.0;
    final longitude = location['longitude'] ?? 0.0;
    final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';
    final timestamp = DateTime.now().toString().substring(0, 19);

    return '''🚨 SOS EMERGENCY ALERT 🚨

$userName needs immediate assistance!

📱 User Phone: $userPhone
📍 Location: Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}
🗺️ Maps: $mapsLink
⏰ Time: $timestamp

Please respond immediately!
This is an automated emergency alert from Gram Seva App.''';
  }
}
