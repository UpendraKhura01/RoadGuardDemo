import 'package:flutter/material.dart';
import 'block_reports_screen.dart';
import 'my_reports_screen.dart';
import 'nearby_reports_screen.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _GridItem(label: 'Posted', icon: Icons.list_alt_rounded, color: const Color(0xFF607D8B),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsScreen()))),
      _GridItem(label: 'Voted', icon: Icons.thumb_up_alt_rounded, color: const Color(0xFF6A1B9A), onTap: () {}),
      _GridItem(label: 'Nearby', icon: Icons.near_me_rounded, color: const Color(0xFF009688),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyReportsScreen()))),
      _GridItem(label: 'Block', icon: Icons.location_city_rounded, color: const Color(0xFF1A237E),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlockReportsScreen()))),
      _GridItem(label: 'Your Activity', icon: Icons.person_pin_circle_rounded, color: const Color(0xFFBF360C),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReportsScreen()))),
      _GridItem(label: 'Search', icon: Icons.search_rounded, color: const Color(0xFF33691E),
          onTap: () {}),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Complaints',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: item.onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(item.icon, color: Colors.white, size: 32),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _GridItem({required this.label, required this.icon, required this.color, required this.onTap});
}


