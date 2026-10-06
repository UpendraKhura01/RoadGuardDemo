import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'report_hazard_screen.dart';
import 'map_screen.dart';
import 'complaints_screen.dart';
import 'notifications_screen.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();

  final List<Widget> _screens = const [
    _HomeTab(),
    NotificationsScreen(),
    ComplaintsScreen(),
    _ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _requestLocationOnStartup();
  }

  Future<void> _requestLocationOnStartup() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        await _notificationService.updateLocation(position.latitude, position.longitude);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF009688);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHazardScreen()));
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', index: 0, current: _currentIndex, onTap: _onTap),
              _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Notification', index: 1, current: _currentIndex, onTap: _onTap),
              const SizedBox(width: 48), // FAB space
              _NavItem(icon: Icons.list_alt_outlined, activeIcon: Icons.list_alt, label: 'Complaints', index: 2, current: _currentIndex, onTap: _onTap),
              _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', index: 3, current: _currentIndex, onTap: _onTap),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final void Function(int) onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label,
      required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == index;
    const teal = Color(0xFF009688);
    return InkWell(
      onTap: () => onTap(index),
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isActive ? activeIcon : icon, color: isActive ? teal : Colors.grey, size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? teal : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Hero banner
            Container(
              height: 190,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E7D32), Color(0xFF00897B)],
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: const Stack(children: [
                Positioned(right: -20, bottom: -20,
                  child: Opacity(opacity: 0.15,
                    child: Icon(Icons.shield_outlined, size: 180, color: Colors.white))),
                Padding(padding: EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text('RoadGuard AI', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    SizedBox(height: 8),
                    Text('Report hazards instantly.', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    Text('Make your community safer.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ])),
              ]),
            ),

            // Welcome card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$greeting,', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Active Citizen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                  const SizedBox(height: 6),
                  Text('What would you like to do today?', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ]),
              ),
            ),

            // Action cards row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.add_a_photo_outlined,
                    title: 'Report\nHazard',
                    subtitle: 'Capture and upload',
                    gradient: const LinearGradient(colors: [Color(0xFF009688), Color(0xFF26A69A)]),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportHazardScreen())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.map_outlined,
                    title: 'Live\nMap',
                    subtitle: 'Hazards near you',
                    gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF42A5F5)]),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen())),
                  ),
                ),
              ]),
            ),

            // Quick map section
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 16, 8),
              child: Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
            ),

            // Map preview card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen())),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.green.shade50],
                    ),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.explore, size: 48, color: Colors.teal.shade700),
                      const SizedBox(height: 8),
                      Text('Explore Map Activity', style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Gradient gradient;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle,
      required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Colors.white, size: 32),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, height: 1.1)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ),
    );
  }
}

// ─── Profile Tab ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _userService.getMyProfile();
      if (mounted) setState(() { _profile = profile; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _profile == null
          ? const Center(child: Text('Failed to load profile'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50, 
                    backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 60, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 16),
                  Text(_profile!['name']?.toString() ?? 'Citizen', 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_profile!['phoneNumber']?.toString() ?? '', 
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  
                  const SizedBox(height: 32),
                  
                  _buildProfileCard(
                    title: 'Reputation Score',
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber.shade700,
                    value: '${_profile!['reputationScore'] ?? 0} points',
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    title: 'Email',
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue,
                    value: _profile!['gmail']?.toString() ?? 'Not provided',
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    title: 'Current Ward',
                    icon: Icons.location_city_outlined,
                    iconColor: Colors.purple,
                    value: _profile!['ward']?.toString() ?? 'Unknown',
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    title: 'District & State',
                    icon: Icons.map_outlined,
                    iconColor: Colors.teal,
                    value: [
                      _profile!['district'], 
                      _profile!['state']
                    ].where((e) => e != null && e.toString().isNotEmpty).join(', ').isEmpty 
                        ? 'Unknown' 
                        : [
                            _profile!['district'], 
                            _profile!['state']
                          ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard({required String title, required IconData icon, required Color iconColor, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
