// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/kotlin_backend_service.dart';
import 'sos_screen.dart';
import 'ai_health_assistant_screen.dart';
import 'health_alert_board_screen.dart';
import 'medicine_reminders_screen.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  UserModel? userData;
  bool isLoading = true;
  String? _weatherDescription;
  double? _temperature;
  bool _fetchingWeather = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchWeather();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get()
              .timeout(const Duration(seconds: 10));

          if (doc.exists) {
            if (context.mounted) {
              try {
                if (!mounted) return;
                setState(() {
                  userData = UserModel.fromMap(doc.data()!);
                  isLoading = false;
                });
              } catch (parseError) {
                // Handle parsing error for existing users without emergencyContacts
                if (context.mounted) {
                  if (!mounted) return;
                  setState(() {
                    userData = UserModel(
                      uid: user.uid,
                      fullName:
                          doc.data()?['fullName'] ?? user.displayName ?? 'User',
                      phoneNumber:
                          doc.data()?['phoneNumber'] ??
                          user.phoneNumber ??
                          'Not provided',
                      email: doc.data()?['email'] ?? user.email ?? '',
                      preferredLanguage:
                          doc.data()?['preferredLanguage'] ?? 'English',
                      profilePictureUrl: doc.data()?['profilePictureUrl'],
                      village: doc.data()?['village'],
                      latitude: doc.data()?['latitude']?.toDouble(),
                      longitude: doc.data()?['longitude']?.toDouble(),
                      emergencyContacts: List<String>.from(
                        doc.data()?['emergencyContacts'] ?? [],
                      ),
                      createdAt: DateTime.parse(
                        doc.data()?['createdAt'] ??
                            DateTime.now().toIso8601String(),
                      ),
                    );
                    isLoading = false;
                  });
                }
              }
            }
          } else {
            if (context.mounted) {
              if (!mounted) return;
              setState(() {
                userData = UserModel(
                  uid: user.uid,
                  fullName: user.displayName ?? 'User',
                  phoneNumber: user.phoneNumber ?? 'Not provided',
                  email: user.email ?? '',
                  preferredLanguage: 'English',
                  createdAt: DateTime.now(),
                );
                isLoading = false;
              });
            }
          }
        } catch (firestoreError) {
          if (context.mounted) {
            if (!mounted) return;
            setState(() {
              userData = UserModel(
                uid: user.uid,
                fullName: user.displayName ?? 'User',
                phoneNumber: user.phoneNumber ?? 'Not provided',
                email: user.email ?? '',
                preferredLanguage: 'English',
                createdAt: DateTime.now(),
              );
              isLoading = false;
            });
          }
        }
      } else {
        if (context.mounted) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchWeather() async {
    setState(() => _fetchingWeather = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services disabled');
        if (!mounted) return;
        setState(() => _fetchingWeather = false);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          if (!mounted) return;
          setState(() => _fetchingWeather = false);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied');
        if (!mounted) return;
        setState(() => _fetchingWeather = false);
        return;
      }
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Got position: lat=${pos.latitude}, lon=${pos.longitude}');
      // WeatherAPI.com integration
      const apiKey = '13a02c5ed55e4267ab6122706252406';
      final url =
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${pos.latitude},${pos.longitude}';
      print('WeatherAPI URL: $url');
      final response = await http.get(Uri.parse(url));
      print('WeatherAPI response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _temperature = data['current']['temp_c']?.toDouble();
          _weatherDescription = data['current']['condition']['text'];
          _fetchingWeather = false;
        });
      } else {
        print('WeatherAPI error: ${response.statusCode}');
        if (!mounted) return;
        setState(() => _fetchingWeather = false);
      }
    } catch (e) {
      print('Weather fetch error: $e');
      if (!mounted) return;
      setState(() => _fetchingWeather = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Modern Gradient App Bar with Curve
            Stack(
              children: [
                // Gradient background with curve
                ClipPath(
                  clipper: _BottomCurveClipper(),
                  child: Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F8FFF), Color(0xFF8F5FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // App bar content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${userData?.fullName ?? 'User'} 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Your Health & Alert Dashboard',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 22,
                              child: Icon(
                                Icons.person,
                                color: Color(0xFF8F5FFF),
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 20),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(
                          'SOS Alert',
                          Icons.emergency,
                          Color(0xFFE63946),
                          () {
                            _showSOSOptions();
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Agriculture',
                          Icons.agriculture,
                          Color(0xFF4F8FFF),
                          () {
                            // Agriculture action
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Education',
                          Icons.school,
                          Color(0xFF8F5FFF),
                          () {
                            // Education action
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildQuickActionCard(
                          'Medicine Reminders',
                          Icons.medication,
                          Color(0xFF43AA8B),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MedicineRemindersScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Weather Card (now below quick actions)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                color: const Color(0xFFE3E8FF),
                child: ListTile(
                  leading: Icon(
                    Icons.wb_sunny,
                    color: Color(0xFFFFB300),
                    size: 36,
                  ),
                  title:
                      _fetchingWeather
                          ? const Text('Loading weather...')
                          : _temperature != null
                          ? Text(
                            '${_temperature!.toStringAsFixed(1)}°C, ${_weatherDescription ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF4F8FFF),
                            ),
                          )
                          : const Text('Weather unavailable'),
                  subtitle: Text(
                    userData?.village ?? 'Your Location',
                    style: const TextStyle(color: Color(0xFF5C5F66)),
                  ),
                  trailing: const Icon(
                    Icons.location_on,
                    color: Color(0xFFE63946),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Recent Alerts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Alerts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildAlertCard(
                    'Crop Advisory',
                    'Apply fertilizers for wheat crops',
                    Icons.eco,
                    Colors.green,
                    '5 hours ago',
                  ),
                  const SizedBox(height: 10),
                  _buildAlertCard(
                    'Government Scheme',
                    'New subsidy for irrigation equipment',
                    Icons.assignment,
                    Colors.orange,
                    '1 day ago',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      _buildServiceCard(
                        'Market Prices',
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildServiceCard(
                        'Weather',
                        Icons.wb_sunny,
                        Colors.yellow,
                      ),
                      _buildServiceCard(
                        'Government Schemes',
                        Icons.assignment,
                        Colors.orange,
                      ),
                      _buildServiceCard(
                        'Help & Support',
                        Icons.help,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIHealthAssistantScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4F8FFF),
        tooltip: 'Ask AI Health Assistant',
        child: const Icon(Icons.smart_toy, color: Colors.white),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    String title,
    String message,
    IconData icon,
    Color color,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Service action
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSOSOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SOS Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.emergency, color: Colors.red),
                  ),
                  title: const Text(
                    'Quick SOS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Send emergency alert immediately'),
                  onTap: () {
                    Navigator.pop(context);
                    _sendQuickSOS();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.settings, color: Colors.orange),
                  ),
                  title: const Text(
                    'Detailed SOS',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Customize your emergency alert'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SOSScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _sendQuickSOS() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Sending SOS...'),
              ],
            ),
          ),
    );

    // Send quick SOS
    final success = await KotlinBackendService.sendQuickSOS(context);

    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

// Modern curve clipper for app bar
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
