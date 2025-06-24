// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

import 'package:gram_seva/utils/responsive_helper.dart';
import 'package:gram_seva/utils/kotlin_backend_service.dart';
import 'emergency_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AlertsScreen(),
    const ServicesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gram Alert Seva Doot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Alerts'),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture),
            label: 'Services',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Village Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAlertCard(
              context,
              'Weather Alert',
              'Heavy rainfall expected in next 24 hours',
              Icons.cloud,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              context,
              'Crop Advisory',
              'Apply fertilizers for wheat crops',
              Icons.eco,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              context,
              'Government Scheme',
              'New subsidy for irrigation equipment',
              Icons.assignment,
              Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildServiceButton(context, Icons.help, 'Help', Colors.red),
                _buildServiceButton(
                  context,
                  Icons.local_hospital,
                  'Health',
                  Colors.pink,
                ),
                _buildServiceButton(
                  context,
                  Icons.school,
                  'Education',
                  Colors.purple,
                ),
                _buildServiceButton(
                  context,
                  Icons.agriculture,
                  'Farming',
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 12),
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
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAlertItem(
          'Weather Warning',
          'Cyclone alert for coastal regions',
          '2 hours ago',
          Icons.warning,
          Colors.red,
        ),
        _buildAlertItem(
          'Market Prices',
          'Tomato prices increased by 20%',
          '5 hours ago',
          Icons.attach_money,
          Colors.green,
        ),
        _buildAlertItem(
          'Government Notice',
          'Submit land records by 30th Nov',
          '1 day ago',
          Icons.announcement,
          Colors.blue,
        ),
        _buildAlertItem(
          'Health Advisory',
          'Vaccination camp on 15th Dec',
          '2 days ago',
          Icons.medical_services,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildAlertItem(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message),
        trailing: Text(time, style: const TextStyle(fontSize: 12)),
        onTap: () {
          // Handle alert tap
        },
      ),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildServiceCard(
          context,
          'Agriculture',
          Icons.agriculture,
          Colors.green,
        ),
        _buildServiceCard(context, 'Health', Icons.local_hospital, Colors.red),
        _buildServiceCard(context, 'Education', Icons.school, Colors.blue),
        _buildServiceCard(
          context,
          'Government Schemes',
          Icons.assignment,
          Colors.orange,
        ),
        _buildServiceCard(
          context,
          'Market Prices',
          Icons.attach_money,
          Colors.green,
        ),
        _buildServiceCard(context, 'Weather', Icons.wb_sunny, Colors.yellow),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          // Handle service tap
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userData;
  bool isLoading = true;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw Exception('Firestore timeout');
                },
              );

          if (doc.exists) {
            if (context.mounted) {
              setState(() {
                userData = UserModel.fromMap(doc.data()!);
                isLoading = false;
              });
            }
          } else {
            // Create basic user data from Firebase Auth
            if (context.mounted) {
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
          // Create basic user data from Firebase Auth
          if (context.mounted) {
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
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        // Here you would typically upload the image to Firebase Storage
        // For now, we'll just show the local image
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Profile Picture'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAddVillageDialog() {
    final TextEditingController villageController = TextEditingController();
    bool isDetectingLocation = false;
    bool isSaving = false;
    bool isWindowsDesktop = kIsWeb || Platform.isWindows;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Add Your Village'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: villageController,
                        decoration: InputDecoration(
                          labelText: 'Village Name',
                          hintText:
                              isWindowsDesktop
                                  ? 'Enter your village name'
                                  : 'Enter your village name or detect automatically',
                        ),
                      ),
                      if (!isWindowsDesktop) ...[
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              isDetectingLocation
                                  ? null
                                  : () async {
                                    setDialogState(() {
                                      isDetectingLocation = true;
                                    });

                                    try {
                                      final village =
                                          await _detectCurrentVillage();
                                      if (village != null && context.mounted) {
                                        villageController.text = village;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Detected: $village'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Location detection failed: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setDialogState(() {
                                          isDetectingLocation = false;
                                        });
                                      }
                                    }
                                  },
                          icon:
                              isDetectingLocation
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.location_on),
                          label: Text(
                            isDetectingLocation
                                ? 'Detecting...'
                                : 'Detect Current Location',
                          ),
                        ),
                      ],
                      if (isWindowsDesktop) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Location detection is not available on Windows desktop. Please enter your village name manually.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isSaving
                              ? null
                              : () async {
                                final villageName =
                                    villageController.text.trim();
                                if (villageName.isEmpty) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter a village name',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                setDialogState(() {
                                  isSaving = true;
                                });

                                try {
                                  await _updateVillage(villageName);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Village saved: $villageName',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error saving village: $e',
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() {
                                      isSaving = false;
                                    });
                                  }
                                }
                              },
                      child:
                          isSaving
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<String?> _detectCurrentVillage() async {
    try {
      // Check if running on Windows desktop
      if (kIsWeb || Platform.isWindows) {
        // For Windows desktop, show a message and return null
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location detection is not available on Windows desktop. Please enter your village manually.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Try to get village/locality name
        String village =
            place.locality ??
            place.subLocality ??
            place.administrativeArea ??
            place.subAdministrativeArea ??
            'Unknown Location';

        // Save coordinates along with village name
        await _updateVillageWithLocation(
          village,
          position.latitude,
          position.longitude,
        );

        return village;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateVillage(String village) async {
    await _updateVillageWithLocation(village, null, null);
  }

  Future<void> _updateVillageWithLocation(
    String village,
    double? latitude,
    double? longitude,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No authenticated user found');
      }

      Map<String, dynamic> updateData = {'village': village};
      if (latitude != null && longitude != null) {
        updateData['latitude'] = latitude;
        updateData['longitude'] = longitude;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      // Reload user data
      await _loadUserData();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Header with curve
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFF43A047),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          // Profile content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                // Profile picture
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (userData!.profilePictureUrl != null
                                      ? NetworkImage(
                                            userData!.profilePictureUrl!,
                                          )
                                          as ImageProvider
                                      : const NetworkImage(
                                        'https://randomuser.me/api/portraits/men/1.jpg',
                                      )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userData!.fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData!.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userData!.phoneNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                if (userData!.village != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Village: ${userData!.village}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                // Profile actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildProfileActionCard(
                        Icons.person,
                        'Personal Details',
                        theme,
                      ),
                      _buildProfileActionCard(
                        Icons.location_on,
                        userData!.village != null
                            ? 'My Village'
                            : 'Add Village',
                        theme,
                      ),
                      _buildProfileActionCard(
                        Icons.emergency,
                        'Emergency Contacts',
                        theme,
                      ),
                      _buildProfileActionCard(
                        Icons.settings,
                        'Settings',
                        theme,
                      ),
                      _buildProfileActionCard(
                        Icons.help,
                        'Help & Support',
                        theme,
                      ),
                      _buildProfileActionCard(
                        Icons.logout,
                        'Logout',
                        theme,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionCard(
    IconData icon,
    String title,
    ThemeData theme, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (color ?? theme.primaryColor).withOpacity(0.15),
          child: Icon(icon, color: color ?? theme.primaryColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          if (title == 'Personal Details') {
            _showPersonalDetails();
          } else if (title == 'Add Village' || title == 'My Village') {
            if (userData!.village != null) {
              _showVillageDetails();
            } else {
              _showAddVillageDialog();
            }
          } else if (title == 'Emergency Contacts') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmergencyContactsScreen(),
              ),
            );
          } else if (title == 'Logout') {
            _logout();
          }
          // Handle other profile item taps
        },
      ),
    );
  }

  void _showPersonalDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Personal Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Full Name', userData!.fullName),
                _buildDetailRow('Email', userData!.email),
                _buildDetailRow('Phone Number', userData!.phoneNumber),
                _buildDetailRow(
                  'Preferred Language',
                  userData!.preferredLanguage,
                ),
                _buildDetailRow('Village', userData!.village ?? 'Not set'),
                if (userData!.latitude != null &&
                    userData!.longitude != null) ...[
                  _buildDetailRow(
                    'Location',
                    '${userData!.latitude!.toStringAsFixed(4)}, ${userData!.longitude!.toStringAsFixed(4)}',
                  ),
                ],
                _buildDetailRow(
                  'Account Created',
                  '${userData!.createdAt.day}/${userData!.createdAt.month}/${userData!.createdAt.year}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showVillageDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('My Village'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Village: ${userData!.village}'),
                const SizedBox(height: 16),
                const Text('Would you like to change your village?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddVillageDialog();
                },
                child: const Text('Change Village'),
              ),
            ],
          ),
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }
}

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _isLoading = false;
  bool _isSending = false;
  //String? _currentLocation;
  UserModel? _userData;
  final TextEditingController _customMessageController =
      TextEditingController();
  final bool _useCustomMessage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (doc.exists) {
          setState(() {
            _userData = UserModel.fromMap(doc.data()!);
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled';
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied';
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      } else {
        return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      }
    } catch (e) {
      return 'Unable to get location: $e';
    }
  }

  Future<void> _sendEmergencySMS() async {
    if (_userData?.emergencyContacts.isEmpty ?? true) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No emergency contacts found. Please add contacts in your profile.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      // Check if we're on a platform that supports Kotlin backend
      if (kIsWeb || Platform.isWindows) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detailed SOS is only available on mobile devices'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Check network connectivity first
      final hasNetwork = await KotlinBackendService.checkNetworkConnectivity();
      if (!hasNetwork) {
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

      // Check permissions using Kotlin backend
      final permissions = await KotlinBackendService.checkPermissions();

      if (!permissions['sms']!) {
        throw Exception('SMS permissions not granted');
      }

      if (!permissions['location']!) {
        throw Exception('Location permissions not granted');
      }

      // Send complete SOS using Kotlin backend
      final success = await KotlinBackendService.sendCompleteSOS(
        userName: _userData!.fullName,
        userPhone: _userData!.phoneNumber,
        emergencyContacts: _userData!.emergencyContacts,
        customMessage:
            _useCustomMessage && _customMessageController.text.trim().isNotEmpty
                ? _customMessageController.text.trim()
                : null,
      );

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emergency SOS sent to all contacts!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to send SOS message');
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Error sending SOS';

        if (e.toString().contains('permission')) {
          errorMessage =
              'SMS permissions not granted. Please enable SMS permissions in app settings.';
        } else if (e.toString().contains('location')) {
          errorMessage =
              'Location permissions not granted. Please enable location permissions in app settings.';
        } else if (e.toString().contains('capable')) {
          errorMessage =
              'This device cannot send SMS. Please use a mobile device.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('offline')) {
          errorMessage =
              'Firebase is offline. SOS will be saved when connection is restored.';
        } else {
          errorMessage = 'Error sending SOS: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _sendEmergencySMS(),
            ),
          ),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showSOSHistory() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('SOS History'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('sos_history')
                        .where('userName', isEqualTo: _userData?.fullName)
                        .orderBy('timestamp', descending: true)
                        .limit(50)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error loading SOS history'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return const Center(child: Text('No SOS alerts found'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = data['timestamp'] as Timestamp?;
                      final location =
                          'Lat: ${data['latitude']?.toStringAsFixed(4) ?? 'N/A'}, Lng: ${data['longitude']?.toStringAsFixed(4) ?? 'N/A'}';
                      final language = data['language'] as String? ?? 'Unknown';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.emergency,
                            color: Colors.red,
                          ),
                          title: Text(
                            timestamp?.toDate().toString().substring(0, 19) ??
                                'Unknown time',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: $location'),
                              Text('Language: $language'),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _showSOSDetails(data),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showSOSDetails(Map<String, dynamic> data) {
    final timestamp = data['timestamp'] as Timestamp?;
    final location = data['location'] as String? ?? 'Unknown';
    final contacts = List<String>.from(data['contactsNotified'] ?? []);
    final message = data['message'] as String? ?? 'No message';
    final status = data['status'] as String? ?? 'Unknown';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('SOS Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Time: ${timestamp?.toDate().toString().substring(0, 19) ?? 'Unknown'}',
                  ),
                  const SizedBox(height: 8),
                  Text('Status: $status'),
                  const SizedBox(height: 8),
                  Text('Location: $location'),
                  const SizedBox(height: 8),
                  Text('Contacts Notified: ${contacts.join(', ')}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Message:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickContactFromPhonebook() async {
    try {
      if (kIsWeb || Platform.isWindows) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Contact picker is only available on mobile devices',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Use Kotlin backend to pick contact
      final contactData = await KotlinBackendService.pickContact();

      if (contactData != null && context.mounted) {
        // Show dialog to confirm adding the contact
        final shouldAdd = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Add Emergency Contact'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${contactData['name']}'),
                    Text('Phone: ${contactData['phone']}'),
                    const SizedBox(height: 16),
                    const Text('Add this contact to your emergency contacts?'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Add Contact'),
                  ),
                ],
              ),
        );

        if (shouldAdd == true) {
          // Add contact to user's emergency contacts
          await _addContactToEmergencyContacts(
            contactData['name']!,
            contactData['phone']!,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addContactToEmergencyContacts(String name, String phone) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get current emergency contacts
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        final currentContacts = List<String>.from(
          userDoc.data()!['emergencyContacts'] ?? [],
        );
        final currentNames = List<String>.from(
          userDoc.data()!['emergencyContactNames'] ?? [],
        );

        // Add new contact if not already present
        if (!currentContacts.contains(phone)) {
          currentContacts.add(phone);
          currentNames.add(name);

          // Update Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
                'emergencyContacts': currentContacts,
                'emergencyContactNames': currentNames,
              });

          // Reload user data
          await _loadUserData();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added $name to emergency contacts'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contact already exists in emergency contacts'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding contact: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showManualContactDialog() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Emergency Contact'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a phone number';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Add Contact'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _addContactToEmergencyContacts(
        nameController.text.trim(),
        phoneController.text.trim(),
      );
    }

    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final scaleFactor = responsive.scaleFactor;

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: Text(
          'Emergency SOS',
          style: TextStyle(fontSize: 20 * scaleFactor),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Emergency Icon
                          Container(
                            padding: EdgeInsets.all(40 * scaleFactor),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emergency,
                              size: 100 * scaleFactor,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 32 * scaleFactor),

                          // Emergency Title
                          Text(
                            'EMERGENCY SOS',
                            style: TextStyle(
                              fontSize: 32 * scaleFactor,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          SizedBox(height: 16 * scaleFactor),

                          // Description
                          Text(
                            'Press the button below to send emergency alerts to all your saved contacts',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18 * scaleFactor,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 32 * scaleFactor),

                          // Emergency Contacts Info
                          if (_userData?.emergencyContacts.isNotEmpty ??
                              false) ...[
                            Container(
                              padding: EdgeInsets.all(16 * scaleFactor),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Emergency Contacts',
                                    style: TextStyle(
                                      fontSize: 18 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  SizedBox(height: 8 * scaleFactor),
                                  Text(
                                    '${_userData!.emergencyContacts.length} contact(s) will be notified',
                                    style: TextStyle(
                                      fontSize: 16 * scaleFactor,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 12 * scaleFactor),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const EmergencyContactsScreen(),
                                            ),
                                          ).then((_) {
                                            _loadUserData();
                                          });
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          size: 16 * scaleFactor,
                                          color: Colors.blue[700],
                                        ),
                                        label: Text(
                                          'Edit Contacts',
                                          style: TextStyle(
                                            fontSize: 14 * scaleFactor,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed:
                                            () => _pickContactFromPhonebook(),
                                        icon: Icon(
                                          Icons.contact_phone,
                                          size: 16 * scaleFactor,
                                          color: Colors.green[700],
                                        ),
                                        label: Text(
                                          'Add Contact',
                                          style: TextStyle(
                                            fontSize: 14 * scaleFactor,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8 * scaleFactor),
                                  TextButton.icon(
                                    onPressed: () => _showManualContactDialog(),
                                    icon: Icon(
                                      Icons.edit_note,
                                      size: 16 * scaleFactor,
                                      color: Colors.purple[700],
                                    ),
                                    label: Text(
                                      'Add Contact Manually',
                                      style: TextStyle(
                                        fontSize: 14 * scaleFactor,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24 * scaleFactor),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.all(16 * scaleFactor),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange[300]!),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.orange[700],
                                    size: 32 * scaleFactor,
                                  ),
                                  SizedBox(height: 8 * scaleFactor),
                                  Text(
                                    'No Emergency Contacts',
                                    style: TextStyle(
                                      fontSize: 18 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  SizedBox(height: 8 * scaleFactor),
                                  Text(
                                    'Please add emergency contacts to send SOS alerts',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16 * scaleFactor,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                  SizedBox(height: 16 * scaleFactor),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const EmergencyContactsScreen(),
                                        ),
                                      ).then((_) {
                                        // Reload user data when returning from contacts screen
                                        _loadUserData();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Add Emergency Contacts',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24 * scaleFactor),
                          ],

                          // SOS Button
                          SizedBox(
                            width: double.infinity,
                            height: 80 * scaleFactor,
                            child: ElevatedButton(
                              onPressed: _isSending ? null : _sendEmergencySMS,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 8,
                              ),
                              child:
                                  _isSending
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 24 * scaleFactor,
                                            height: 24 * scaleFactor,
                                            child:
                                                const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                          ),
                                          SizedBox(width: 12 * scaleFactor),
                                          Text(
                                            'Sending...',
                                            style: TextStyle(
                                              fontSize: 20 * scaleFactor,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.emergency,
                                            size: 32 * scaleFactor,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12 * scaleFactor),
                                          Text(
                                            'SEND SOS ALERT',
                                            style: TextStyle(
                                              fontSize: 20 * scaleFactor,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                            ),
                          ),
                          SizedBox(height: 24 * scaleFactor),

                          // SOS History Button
                          TextButton.icon(
                            onPressed: _showSOSHistory,
                            icon: Icon(
                              Icons.history,
                              size: 20 * scaleFactor,
                              color: Colors.grey[600],
                            ),
                            label: Text(
                              'View SOS History',
                              style: TextStyle(
                                fontSize: 16 * scaleFactor,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          // Warning Text
                          Container(
                            padding: EdgeInsets.all(16 * scaleFactor),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red[700],
                                  size: 24 * scaleFactor,
                                ),
                                SizedBox(height: 8 * scaleFactor),
                                Text(
                                  'Use this only in genuine emergencies',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16 * scaleFactor,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  @override
  void dispose() {
    _customMessageController.dispose();
    super.dispose();
  }
}
