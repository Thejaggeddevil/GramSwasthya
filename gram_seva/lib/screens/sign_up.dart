// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'emergency_contacts_screen.dart';
import 'login_screen.dart';

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

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _obscurePassword = true;
          _obscureConfirmPassword = true;
        });
      }
    });
  }

  Future<void> _signUp() async {
    // Basic validation
    if (_fullNameController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('pleaseEnterFullName'.tr())));
      }
      return;
    }

    if (_phoneNumberController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('pleaseEnterPhoneNumber'.tr())));
      }
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('pleaseEnterEmail'.tr())));
      }
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('pleaseEnterPassword'.tr())));
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
          preferredLanguage:
              context.locale.languageCode == 'en' ? 'English' : 'Hindi',
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
      ).showSnackBar(SnackBar(content: Text('accountCreated'.tr())));

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
    return Scaffold(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Language dropdown at the top
                  Align(
                    alignment: Alignment.topRight,
                    child: DropdownButton<Locale>(
                      value: context.locale,
                      icon: const Icon(Icons.language, color: Colors.white),
                      dropdownColor: const Color(0xFF8F5FFF),
                      underline: Container(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale('hi'),
                          child: Text('हिन्दी'),
                        ),
                      ],
                      onChanged: (locale) async {
                        if (locale != null) {
                          await context.setLocale(locale);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      Icons.person_add_alt_1,
                      size: 60,
                      color: Color(0xFF8F5FFF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'createAccount'.tr(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'signUpToGetStarted'.tr(),
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _modernTextField(
                              controller: _fullNameController,
                              label: 'fullName'.tr(),
                              icon: Icons.person,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'pleaseEnterFullName'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _modernTextField(
                              controller: _phoneNumberController,
                              label: 'phoneNumber'.tr(),
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'pleaseEnterPhoneNumber'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _modernTextField(
                              controller: _emailController,
                              label: 'email'.tr(),
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'pleaseEnterEmail'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _modernTextField(
                              controller: _passwordController,
                              label: 'password'.tr(),
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xFF8F5FFF),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'pleaseEnterPassword'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _modernTextField(
                              controller: _confirmPasswordController,
                              label: 'confirmPassword'.tr(),
                              icon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xFF8F5FFF),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'pleaseConfirmPassword'.tr();
                                }
                                if (value != _passwordController.text) {
                                  return 'passwordsDontMatch'.tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8F5FFF),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          'signUp'.tr(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'alreadyHaveAccount'.tr(),
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'signIn'.tr(),
                                    style: TextStyle(
                                      color: Color(0xFF8F5FFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF8F5FFF)),
        suffixIcon: suffixIcon,
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
          borderSide: const BorderSide(color: Color(0xFF8F5FFF), width: 2),
        ),
      ),
    );
  }
}
