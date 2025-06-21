import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sos_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedLanguage = 'English';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('passwordsDontMatch'.tr())));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('signUpSuccess'.tr())));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SosScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'signUpFailed'.tr()}: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                'Create Account'.tr(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 2,
                shape: RoundedInputBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInputField(
                        controller: _fullNameController,
                        label: 'Full Name'.tr(),
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _phoneNumberController,
                        label: 'Phone Number'.tr(),
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _emailController,
                        label: 'Email'.tr(),
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _buildLanguageDropdown(),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _passwordController,
                        label: 'Password'.tr(),
                        isConfirm: false,
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password'.tr(),
                        isConfirm: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Sign Up'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'By SignUp you are agreeing to our Terms and conditions'.tr(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green[500]!),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isConfirm,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isConfirm ? _obscureConfirmPassword : _obscurePassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          isConfirm ? Icons.lock_outline : Icons.lock,
          color: Colors.green[700],
        ),
        suffixIcon: IconButton(
          icon: Icon(
            (isConfirm ? _obscureConfirmPassword : _obscurePassword)
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.green[700],
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              } else {
                _obscurePassword = !_obscurePassword;
              }
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green[500]!),
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      decoration: InputDecoration(
        labelText: 'Preferred Language'.tr(),
        prefixIcon: Icon(Icons.language, color: Colors.green[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.green[500]!),
        ),
      ),
      items:
          ['English', 'Hindi']
              .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
              .toList(),
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
          context.setLocale(Locale(value == 'Hindi' ? 'hi' : 'en'));
        });
      },
    );
  }
}

class RoundedInputBorder extends OutlineInputBorder {
  @override
  BorderRadius get borderRadius => BorderRadius.circular(12);
}
