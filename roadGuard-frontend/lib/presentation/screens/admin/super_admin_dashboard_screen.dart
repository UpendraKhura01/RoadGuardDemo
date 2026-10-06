import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'admin_users_screen.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    Center(child: Text('Manage Admins Panel (Coming Soon)', style: TextStyle(fontSize: 24, color: Colors.grey))),
    AdminUsersScreen(),
  ];

  final List<String> _titles = [
    'Manage Admins',
    'Citizen Directory',
  ];

  final List<IconData> _icons = [
    Icons.admin_panel_settings_outlined,
    Icons.people_outline,
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: isDesktop ? null : AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF311B92),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: isDesktop ? null : _buildSidebar(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildTopBar(context),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(_titles[_currentIndex], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF311B92))),
          const Spacer(),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: 16),
          CircleAvatar(backgroundColor: Colors.deepPurple.shade100, child: const Icon(Icons.security, color: Colors.deepPurple)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return Container(
      width: 260,
      color: const Color(0xFF1A1A2E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Row(
              children: [
                Icon(Icons.gavel, color: Colors.purpleAccent, size: 32),
                SizedBox(width: 12),
                Text('System Owner', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 24, bottom: 8),
            child: Text('SUPER ADMIN', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _screens.length,
              itemBuilder: (context, index) {
                final isSelected = _currentIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tileColor: isSelected ? Colors.purpleAccent.withValues(alpha: 0.15) : Colors.transparent,
                    leading: Icon(_icons[index], color: isSelected ? Colors.purpleAccent : Colors.grey[400]),
                    title: Text(_titles[index], style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400], fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                    onTap: () {
                      setState(() => _currentIndex = index);
                      if (!MediaQuery.of(context).size.width.isFinite || MediaQuery.of(context).size.width <= 800) {
                        Navigator.pop(context); 
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: OutlinedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
