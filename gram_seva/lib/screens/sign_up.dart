// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gram_seva/utils/responsive_helper.dart';
import '../models/user_model.dart';
import 'emergency_contacts_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isEnglish = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid accessing context in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isEnglish = context.locale == const Locale('en');
        });
      }
    });
  }

  Future<void> _changeLanguage(bool isEnglish) async {
    final newLocale = isEnglish ? const Locale('en') : const Locale('hi');
    // Use post-frame callback to avoid the inherited widget error
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await context.setLocale(newLocale);
        if (mounted) {
          setState(() {
            _isEnglish = isEnglish;
          });
        }
      }
    });
  }

  Future<void> _signUp() async {
    // Basic validation
    if (_fullNameController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter your full name')));
      }
      return;
    }

    if (_phoneNumberController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter your phone number')),
        );
      }
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter your email')));
      }
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a password')));
      }
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('passwordsDontMatch'.tr())));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create user with email and password
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Signup timed out. Please check your internet connection.',
              );
            },
          );

      // Store user data in Firestore
      try {
        final user = UserModel(
          uid: userCredential.user!.uid,
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          email: _emailController.text.trim(),
          preferredLanguage: _isEnglish ? 'English' : 'Hindi',
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toMap())
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Firestore storage timed out.');
              },
            );
      } catch (firestoreError) {
        // Continue even if Firestore fails - user is still created in Auth
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account created successfully!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const EmergencyContactsScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'signUpFailed'.tr();
      if (e.code == 'weak-password') {
        errorMessage = 'weakPassword'.tr();
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'emailInUse'.tr();
      } else if (e.code == 'invalid-email') {
        errorMessage = 'invalidEmail'.tr();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${'signUpFailed'.tr()}: $e')));
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final scaleFactor = responsive.scaleFactor;

    return Scaffold(
      backgroundColor: Colors.green[50],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'English',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch(
                          value: _isEnglish,
                          onChanged: (val) {
                            _changeLanguage(val);
                          },
                          activeColor: Colors.green,
                        ),
                        Text(
                          'हिन्दी',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8 * scaleFactor),
                    Text(
                      'Create Account'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 24 * scaleFactor),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name'.tr(),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: TextStyle(fontSize: 16 * scaleFactor),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    TextFormField(
                      controller: _phoneNumberController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number'.tr(),
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 16 * scaleFactor),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email'.tr(),
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 16 * scaleFactor),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password'.tr(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: TextStyle(fontSize: 16 * scaleFactor),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password'.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: TextStyle(fontSize: 16 * scaleFactor),
                    ),
                    SizedBox(height: 24 * scaleFactor),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
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
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(
                                'Sign Up'.tr(),
                                style: TextStyle(
                                  fontSize: 18 * scaleFactor,
                                  color: Colors.white,
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
}
