import 'package:flutter/material.dart';

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
          backgroundColor: color.withOpacity(0.2),
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/1.jpg',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ramesh Patel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Village: Shivpura, Gujarat'),
            const SizedBox(height: 24),
            _buildProfileItem(Icons.person, 'Personal Details'),
            _buildProfileItem(Icons.location_on, 'My Village'),
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
          // Handle profile item tap
        },
      ),
    );
  }
}
