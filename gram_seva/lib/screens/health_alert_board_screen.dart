// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthAlertBoardScreen extends StatefulWidget {
  const HealthAlertBoardScreen({super.key});

  @override
  State<HealthAlertBoardScreen> createState() => _HealthAlertBoardScreenState();
}

class _HealthAlertBoardScreenState extends State<HealthAlertBoardScreen> {
  Position? _position;
  String? _locationText;
  bool _isLoading = true;
  List<_DiseaseAlert> _alerts = [];
  bool _fetchingAlerts = false;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndAlerts();
  }

  Future<void> _fetchLocationAndAlerts() async {
    setState(() {
      _isLoading = true;
      _fetchingAlerts = true;
    });
    try {
      // Get device location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationText = 'Location services disabled';
          _isLoading = false;
          _fetchingAlerts = false;
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationText = 'Location permission denied';
            _isLoading = false;
            _fetchingAlerts = false;
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationText = 'Location permission permanently denied';
          _isLoading = false;
          _fetchingAlerts = false;
        });
        return;
      }
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _position = pos;
        _locationText =
            'Lat: ${pos.latitude.toStringAsFixed(4)}, Lng: ${pos.longitude.toStringAsFixed(4)}';
        _isLoading = false;
      });
      // Fetch alerts from Firestore
      await _fetchAlertsFromFirestore(pos);
    } catch (e) {
      setState(() {
        _locationText = 'Location unavailable';
        _isLoading = false;
        _fetchingAlerts = false;
      });
    }
  }

  Future<void> _fetchAlertsFromFirestore(Position pos) async {
    setState(() => _fetchingAlerts = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('disease_alerts').get();
      final List<_DiseaseAlert> allAlerts =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return _DiseaseAlert(
              title: data['disease'] ?? 'Unknown',
              priority: data['priority'] ?? 'LOW',
              priorityColor: _priorityColor(data['priority'] ?? 'LOW'),
              location: data['village'] ?? 'Unknown',
              cases: data['cases'] ?? 0,
              time: _formatTime(data['timestamp']),
              bgColor: _priorityBgColor(data['priority'] ?? 'LOW'),
              lat: data['location']?['latitude']?.toDouble() ?? 0.0,
              lng: data['location']?['longitude']?.toDouble() ?? 0.0,
              radiusKm: 20, // Show alerts within 20km
            );
          }).toList();

      final visibleAlerts =
          allAlerts.where((alert) {
            final double dist =
                Geolocator.distanceBetween(
                  pos.latitude,
                  pos.longitude,
                  alert.lat,
                  alert.lng,
                ) /
                1000.0;
            return dist <= alert.radiusKm;
          }).toList();
      setState(() {
        _alerts = visibleAlerts.isNotEmpty ? visibleAlerts : allAlerts;
        _fetchingAlerts = false;
      });
    } catch (e) {
      setState(() {
        _alerts = [];
        _fetchingAlerts = false;
      });
    }
  }

  static Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.amber[700]!;
      default:
        return Colors.green;
    }
  }

  static Color _priorityBgColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFFEAEA);
      case 'MEDIUM':
        return const Color(0xFFFFF8E1);
      default:
        return const Color(0xFFE8F9ED);
    }
  }

  static String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt =
          timestamp is DateTime
              ? timestamp
              : (timestamp is String
                  ? DateTime.tryParse(timestamp)
                  : (timestamp.toDate?.call() ?? DateTime.now()));
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
      if (diff.inHours < 24) return '${diff.inHours} hours ago';
      return '${diff.inDays} days ago';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9ED),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.green[600],
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Health Alert Board',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'स्वास्थ्य अलर्ट बोर्ड - Local Disease Updates',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _locationText ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                onPressed: _fetchLocationAndAlerts,
                                tooltip: 'Refresh Location',
                              ),
                            ],
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Stats Row (mocked for now)
                Row(
                  children: [
                    _statCard(
                      icon: Icons.warning_amber_rounded,
                      color: Colors.red,
                      value:
                          _alerts
                              .where((a) => a.priority == 'HIGH')
                              .length
                              .toString(),
                      label: 'High Priority',
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      icon: Icons.notifications,
                      color: Colors.amber[700]!,
                      value:
                          _alerts
                              .where((a) => a.priority == 'MEDIUM')
                              .length
                              .toString(),
                      label: 'Medium Priority',
                    ),
                    const SizedBox(width: 12),
                    _statCard(
                      icon: Icons.groups,
                      color: Colors.green,
                      value:
                          _alerts
                              .fold<int>(0, (sum, a) => sum + a.cases)
                              .toString(),
                      label: 'Total Cases',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Alert Cards
                if (_fetchingAlerts)
                  const Center(child: CircularProgressIndicator()),
                if (!_fetchingAlerts && _alerts.isEmpty)
                  const Center(child: Text('No alerts found for your area.')),
                for (final alert in _alerts) ...[
                  _diseaseAlertCard(
                    context,
                    title: alert.title,
                    priority: alert.priority,
                    priorityColor: alert.priorityColor,
                    location: alert.location,
                    cases: alert.cases,
                    time: alert.time,
                    bgColor: alert.bgColor,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diseaseAlertCard(
    BuildContext context, {
    required String title,
    required String priority,
    required Color priorityColor,
    required String location,
    required int cases,
    required String time,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bgColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.groups, size: 18, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                '$cases cases',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today, size: 16, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiseaseAlert {
  final String title;
  final String priority;
  final Color priorityColor;
  final String location;
  final int cases;
  final String time;
  final Color bgColor;
  final double lat;
  final double lng;
  final double radiusKm;
  _DiseaseAlert({
    required this.title,
    required this.priority,
    required this.priorityColor,
    required this.location,
    required this.cases,
    required this.time,
    required this.bgColor,
    required this.lat,
    required this.lng,
    required this.radiusKm,
  });
}
