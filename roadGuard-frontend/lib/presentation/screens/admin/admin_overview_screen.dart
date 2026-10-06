import 'package:flutter/material.dart';
import '../../../data/services/report_service.dart';

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  
  int _total = 0, _pending = 0, _verified = 0, _assigned = 0, _inProgress = 0, _resolved = 0, _rejected = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final reports = await _reportService.getAllAdminReports();
      int pending=0, verified=0, assigned=0, inProgress=0, resolved=0, rejected=0;
      
      for(var r in reports) {
        switch(r['reportStatus']) {
          case 'PENDING':
          case 'SUBMITTED':
          case 'PENDING_REVIEW': pending++; break;
          case 'VERIFIED': verified++; break;
          case 'ASSIGNED': assigned++; break;
          case 'IN_PROGRESS': inProgress++; break;
          case 'RESOLVED': resolved++; break;
          case 'REJECTED':
          case 'AI_REJECTED': rejected++; break;
        }
      }
      
      if (mounted) {
        setState(() {
          _reports = reports;
          _total = reports.length;
          _pending = pending;
          _verified = verified;
          _assigned = assigned;
          _inProgress = inProgress;
          _resolved = resolved;
          _rejected = rejected;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // light gray background like web
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome, Admin', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            const Text("Here's what's happening with road hazards in your city today.", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            
            // Stat Cards Row
            isDesktop ? Row(
              children: [
                Expanded(child: _buildStatCard('Total Reports', '$_total', Icons.analytics, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Pending Review', '$_pending', Icons.pending_actions, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('In Progress', '$_inProgress', Icons.engineering, Colors.blueAccent)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Resolved', '$_resolved', Icons.check_circle, Colors.green)),
              ],
            ) : Column(
              children: [
                Row(children: [
                  Expanded(child: _buildStatCard('Total', '$_total', Icons.analytics, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Pending', '$_pending', Icons.pending_actions, Colors.orange)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _buildStatCard('Progress', '$_inProgress', Icons.engineering, Colors.blueAccent)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Resolved', '$_resolved', Icons.check_circle, Colors.green)),
                ]),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Layout Row (Map + Recent Activity)
            isDesktop ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRecentActivityTable()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildDistributionCard()),
              ],
            ) : Column(
              children: [
                _buildDistributionCard(),
                const SizedBox(height: 24),
                _buildRecentActivityTable(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hazard Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 20),
          _distRow('Pending / Submitted', _pending, Colors.orange),
          const SizedBox(height: 12),
          _distRow('Assigned / Verified', _verified + _assigned, Colors.blue),
          const SizedBox(height: 12),
          _distRow('In Progress', _inProgress, Colors.purple),
          const SizedBox(height: 12),
          _distRow('Resolved', _resolved, Colors.green),
          const SizedBox(height: 12),
          _distRow('Rejected / AI Rejected', _rejected, Colors.red),
        ],
      ),
    );
  }

  Widget _distRow(String label, int count, Color color) {
    double perc = _total == 0 ? 0 : count / _total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text('$count', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: perc, backgroundColor: color.withValues(alpha: 0.1), color: color, minHeight: 6, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }

  Widget _buildRecentActivityTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Hazard Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          if (_reports.isEmpty) const Text('No recent activity.') else 
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reports.length > 10 ? 10 : _reports.length,
              itemBuilder: (context, index) {
                final r = _reports[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: Colors.grey[100], child: const Icon(Icons.warning, color: Colors.blueAccent, size: 20)),
                  title: Text('${r['reportedCategory'] ?? 'Hazard'} - ${r['city'] ?? r['ward'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(r['createdAt']?.toString().substring(0,10) ?? '', style: const TextStyle(fontSize: 12)),
                  trailing: Chip(
                    label: Text(r['reportStatus']?.toString() ?? 'SUBMITTED', style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    side: const BorderSide(color: Colors.blue),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
