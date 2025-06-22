// ignore_for_file: use_build_context_synchronously, prefer_is_empty

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gram_seva/utils/responsive_helper.dart';
import 'main_screen.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contact1Controller = TextEditingController();
  final _contact2Controller = TextEditingController();
  final _contact3Controller = TextEditingController();
  final _name1Controller = TextEditingController();
  final _name2Controller = TextEditingController();
  final _name3Controller = TextEditingController();

  bool _isLoading = false;
  bool _isEnglish = true;
  bool _hasError = false;
  String _lastErrorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isEnglish = context.locale == const Locale('en');
        });
      }
    });
    _loadExistingContacts();
  }

  Future<void> _loadExistingContacts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Connection timed out. Please check your internet connection and try again.',
                );
              },
            );

        if (doc.exists) {
          final data = doc.data()!;
          final emergencyContacts = List<String>.from(
            data['emergencyContacts'] ?? [],
          );
          final contactNames = List<String>.from(
            data['emergencyContactNames'] ?? [],
          );

          if (emergencyContacts.isNotEmpty) {
            setState(() {
              if (emergencyContacts.length > 0) {
                _contact1Controller.text = emergencyContacts[0];
                _name1Controller.text =
                    contactNames.length > 0 ? contactNames[0] : '';
              }
              if (emergencyContacts.length > 1) {
                _contact2Controller.text = emergencyContacts[1];
                _name2Controller.text =
                    contactNames.length > 1 ? contactNames[1] : '';
              }
              if (emergencyContacts.length > 2) {
                _contact3Controller.text = emergencyContacts[2];
                _name3Controller.text =
                    contactNames.length > 2 ? contactNames[2] : '';
              }
            });
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load contacts: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveWithRetry(Map<String, dynamic> data, int maxRetries) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(data)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'Save operation timed out. Please check your internet connection and try again.',
                );
              },
            );

        return; // Success, exit the retry loop
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow; // Re-throw on final attempt
        }

        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  Future<void> _saveEmergencyContacts() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Check network connectivity first
      final isConnected = await _checkConnectivity();
      if (!isConnected) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No internet connection. Please check your network and try again.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not authenticated. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Collect emergency contacts
      final emergencyContacts = <String>[];
      final contactNames = <String>[];

      if (_contact1Controller.text.trim().isNotEmpty) {
        emergencyContacts.add(_contact1Controller.text.trim());
        contactNames.add(
          _name1Controller.text.trim().isNotEmpty
              ? _name1Controller.text.trim()
              : 'Contact 1',
        );
      }

      if (_contact2Controller.text.trim().isNotEmpty) {
        emergencyContacts.add(_contact2Controller.text.trim());
        contactNames.add(
          _name2Controller.text.trim().isNotEmpty
              ? _name2Controller.text.trim()
              : 'Contact 2',
        );
      }

      if (_contact3Controller.text.trim().isNotEmpty) {
        emergencyContacts.add(_contact3Controller.text.trim());
        contactNames.add(
          _name3Controller.text.trim().isNotEmpty
              ? _name3Controller.text.trim()
              : 'Contact 3',
        );
      }

      // Update user document with emergency contacts
      await _saveWithRetry({
        'emergencyContacts': emergencyContacts,
        'emergencyContactNames': contactNames,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, 3);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency contacts saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Error saving contacts';

        if (e.toString().contains('timeout')) {
          errorMessage =
              'Connection timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('permission')) {
          errorMessage =
              'Permission denied. Please check your Firebase configuration.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else {
          errorMessage = 'Error saving contacts: ${e.toString()}';
        }

        setState(() {
          _hasError = true;
          _lastErrorMessage = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _lastErrorMessage = '';
                });
                _saveEmergencyContacts();
              },
            ),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _contact1Controller.dispose();
    _contact2Controller.dispose();
    _contact3Controller.dispose();
    _name1Controller.dispose();
    _name2Controller.dispose();
    _name3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final scaleFactor = responsive.scaleFactor;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: TextStyle(fontSize: 20 * scaleFactor),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 600 * (responsive.isWeb ? 0.7 : 1.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scaleFactor,
                vertical: 16 * scaleFactor,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.emergency,
                      size: 80 * scaleFactor,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    Text(
                      'Set Emergency Contacts',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 8 * scaleFactor),
                    Text(
                      'Add up to 3 emergency contacts who will be notified when you press SOS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16 * scaleFactor,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 32 * scaleFactor),

                    // Error indicator
                    if (_hasError)
                      Container(
                        padding: EdgeInsets.all(16 * scaleFactor),
                        margin: EdgeInsets.only(bottom: 16 * scaleFactor),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[700],
                              size: 24 * scaleFactor,
                            ),
                            SizedBox(width: 12 * scaleFactor),
                            Expanded(
                              child: Text(
                                _lastErrorMessage,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 14 * scaleFactor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Contact 1
                    _buildContactField(
                      'Contact 1',
                      _name1Controller,
                      _contact1Controller,
                      true,
                      scaleFactor,
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Contact 2
                    _buildContactField(
                      'Contact 2 (Optional)',
                      _name2Controller,
                      _contact2Controller,
                      false,
                      scaleFactor,
                    ),
                    SizedBox(height: 20 * scaleFactor),

                    // Contact 3
                    _buildContactField(
                      'Contact 3 (Optional)',
                      _name3Controller,
                      _contact3Controller,
                      false,
                      scaleFactor,
                    ),
                    SizedBox(height: 32 * scaleFactor),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveEmergencyContacts,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 16 * scaleFactor,
                        ),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20 * scaleFactor,
                                    height: 20 * scaleFactor,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12 * scaleFactor),
                                  Text(
                                    'Saving...',
                                    style: TextStyle(
                                      fontSize: 18 * scaleFactor,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                'Save Contacts',
                                style: TextStyle(
                                  fontSize: 18 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    TextButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainScreen(),
                                  ),
                                );
                              },
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          fontSize: 16 * scaleFactor,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactField(
    String label,
    TextEditingController nameController,
    TextEditingController phoneController,
    bool isRequired,
    double scaleFactor,
  ) {
    return Container(
      padding: EdgeInsets.all(16 * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16 * scaleFactor,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          SizedBox(height: 12 * scaleFactor),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: TextStyle(fontSize: 16 * scaleFactor),
          ),
          SizedBox(height: 12 * scaleFactor),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 16 * scaleFactor),
            validator:
                isRequired
                    ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    }
                    : null,
          ),
        ],
      ),
    );
  }
}
