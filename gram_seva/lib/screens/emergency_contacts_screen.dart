// ignore_for_file: use_build_context_synchronously, prefer_is_empty, unused_field, deprecated_member_use, unused_local_variable

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'emergencyContacts'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          DropdownButton<Locale>(
            value: context.locale,
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: const Color(0xFF8F5FFF),
            underline: Container(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('hi'), child: Text('हिन्दी')),
            ],
            onChanged: (locale) async {
              if (locale != null) {
                await context.setLocale(locale);
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F8FFF), Color(0xFF8F5FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: const Icon(
                          Icons.emergency,
                          size: 60,
                          color: Color(0xFFE63946),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'setEmergencyContacts'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'addUpTo3Contacts'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_hasError)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
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
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _lastErrorMessage,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      _modernContactCard(
                        label: 'contact1'.tr(),
                        nameController: _name1Controller,
                        phoneController: _contact1Controller,
                        isRequired: true,
                      ),
                      const SizedBox(height: 20),
                      _modernContactCard(
                        label: 'contact2Optional'.tr(),
                        nameController: _name2Controller,
                        phoneController: _contact2Controller,
                        isRequired: false,
                      ),
                      const SizedBox(height: 20),
                      _modernContactCard(
                        label: 'contact3Optional'.tr(),
                        nameController: _name3Controller,
                        phoneController: _contact3Controller,
                        isRequired: false,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveEmergencyContacts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8F5FFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                          child:
                              _isLoading
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'saving'.tr(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    'saveContacts'.tr(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          'skipForNow'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
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
      ),
    );
  }

  Widget _modernContactCard({
    required String label,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required bool isRequired,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8F5FFF),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'name'.tr(),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF8F5FFF)),
                filled: true,
                fillColor: const Color(0xFFF3F4FB),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF8F5FFF),
                    width: 2,
                  ),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'phoneNumber'.tr(),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF8F5FFF)),
                filled: true,
                fillColor: const Color(0xFFF3F4FB),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF8F5FFF),
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16),
              validator:
                  isRequired
                      ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'pleaseEnterPhoneNumber'.tr();
                        }
                        if (value.length < 10) {
                          return 'validPhone'.tr();
                        }
                        return null;
                      }
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
