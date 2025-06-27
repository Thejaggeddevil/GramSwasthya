import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sms_sender.dart';

class SOSService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> sendQuickSOS(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError(context, 'User not authenticated');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _showError(context, 'User data not found');
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

      final success = await SmsSender.sendSOSMessage(
        emergencyContacts: emergencyContacts,
        userName: userName,
        userPhone: userPhone,
        sendToAll: true,
      );

      if (success) {
        _showSuccess(context, 'SOS alert sent successfully!');
        return true;
      } else {
        _showError(context, 'Failed to send SOS alert');
        return false;
      }
    } catch (e) {
      _showError(context, 'Error sending SOS: ${e.toString()}');
      return false;
    }
  }

  static Future<bool> sendCustomSOS(
    BuildContext context, {
    required String customMessage,
    List<String>? specificContacts,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError(context, 'User not authenticated');
        return false;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _showError(context, 'User data not found');
        return false;
      }

      final userData = userDoc.data()!;
      final allContacts = List<String>.from(
        userData['emergencyContacts'] ?? [],
      );
      final contacts = specificContacts ?? allContacts;
      final userName = userData['fullName'] ?? 'User';
      final userPhone = userData['phoneNumber'] ?? '';

      if (contacts.isEmpty) {
        _showError(context, 'No emergency contacts found');
        return false;
      }

      final success = await SmsSender.sendSOSMessage(
        emergencyContacts: contacts,
        userName: userName,
        userPhone: userPhone,
        customMessage: customMessage,
        sendToAll: true,
      );

      if (success) {
        _showSuccess(context, 'Custom SOS alert sent successfully!');
        return true;
      } else {
        _showError(context, 'Failed to send custom SOS alert');
        return false;
      }
    } catch (e) {
      _showError(context, 'Error sending custom SOS: ${e.toString()}');
      return false;
    }
  }

  /// Get SOS statistics for the current user
  static Future<Map<String, dynamic>> getSOSStatistics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final sosDocs =
          await _firestore
              .collection('sos_history')
              .where('userId', isEqualTo: user.uid)
              .get();

      final totalSOS = sosDocs.docs.length;
      final today = DateTime.now();
      final todaySOS =
          sosDocs.docs.where((doc) {
            final timestamp = doc.data()['timestamp'] as Timestamp?;
            if (timestamp == null) return false;
            final docDate = timestamp.toDate();
            return docDate.year == today.year &&
                docDate.month == today.month &&
                docDate.day == today.day;
          }).length;

      final lastSOS =
          sosDocs.docs.isNotEmpty
              ? sosDocs.docs.first.data()['timestamp'] as Timestamp?
              : null;

      return {
        'totalSOS': totalSOS,
        'todaySOS': todaySOS,
        'lastSOS': lastSOS?.toDate(),
      };
    } catch (e) {
      return {};
    }
  }

  static Future<bool> hasEmergencyContacts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return false;

      final emergencyContacts = List<String>.from(
        userDoc.data()!['emergencyContacts'] ?? [],
      );
      return emergencyContacts.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get emergency contacts for current user
  static Future<List<String>> getEmergencyContacts() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return [];

      return List<String>.from(userDoc.data()!['emergencyContacts'] ?? []);
    } catch (e) {
      return [];
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
}
