import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

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

    if (userData == null) {
      return const Center(child: Text('User data not found'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture with tap functionality
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (userData!.profilePictureUrl != null
                                ? NetworkImage(userData!.profilePictureUrl!)
                                    as ImageProvider
                                : const NetworkImage(
                                  'https://randomuser.me/api/portraits/men/1.jpg',
                                )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userData!.fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Email: ${userData!.email}'),
            const SizedBox(height: 4),
            Text('Phone: ${userData!.phoneNumber}'),
            const SizedBox(height: 4),
            Text('Language: ${userData!.preferredLanguage}'),
            if (userData!.village != null) ...[
              const SizedBox(height: 4),
              Text('Village: ${userData!.village}'),
            ],
            const SizedBox(height: 24),
            _buildProfileItem(Icons.person, 'Personal Details'),
            _buildProfileItem(
              Icons.location_on,
              userData!.village != null ? 'My Village' : 'Add Village',
            ),
            _buildProfileItem(Icons.settings, 'Settings'),
            _buildProfileItem(Icons.help, 'Help & Support'),
            _buildProfileItem(Icons.logout, 'Logout'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
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
