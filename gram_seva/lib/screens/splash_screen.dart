import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gram_seva/screens/sign_up.dart';
import 'package:gram_seva/screens/main_screen.dart';
import 'package:gram_seva/screens/sos_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for 5 seconds and also for location/auth checks to complete.
    await Future.wait([
      _handleLocationAndAuth(),
      Future.delayed(const Duration(seconds: 5)),
    ]);
  }

  Future<void> _handleLocationAndAuth() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                'Please enable location services to use this app.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openLocationSettings();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return; // Or handle it gracefully
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return; // Or handle it gracefully
    }

    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[800],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          double scaleFactor;

          if (maxWidth < 600) {
            // Phone
            scaleFactor = 1.0;
          } else if (maxWidth < 1200) {
            // Tablet
            scaleFactor = 1.5;
          } else {
            // Website
            scaleFactor = 2.0;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 80 * scaleFactor,
                  color: Colors.white,
                ),
                SizedBox(height: 20 * scaleFactor),
                Text(
                  'GramaSwasthya',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28 * scaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8 * scaleFactor),
                Text(
                  'Rural SOS & Health Alert',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * scaleFactor,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 40 * scaleFactor),
                SizedBox(
                  width: 30 * scaleFactor,
                  height: 30 * scaleFactor,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 4.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
