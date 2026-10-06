import 'package:flutter/material.dart';
import '../../../data/services/report_service.dart';
import 'map_screen.dart';

class NearbyReportsScreen extends StatefulWidget {
  const NearbyReportsScreen({super.key});

  @override
  State<NearbyReportsScreen> createState() => _NearbyReportsScreenState();
}

class _NearbyReportsScreenState extends State<NearbyReportsScreen> {
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getNearbyReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading reports: $e')));
      }
    }
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.teal));
    if (_reports.isEmpty) return _buildEmptyState('No reports found in your ward.');

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: Colors.teal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) {
          final r = _reports[index];
          final status = r['reportStatus']?.toString() ?? 'PENDING';
          final color = status == 'RESOLVED' ? Colors.green : (status == 'IN_PROGRESS' ? Colors.blue : Colors.orange);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Show detail logic goes here
                _showReportSummary(r, context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(Icons.warning_amber_rounded, color: color, size: 22)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r['reportedCategory']?.toString().replaceAll('_', ' ') ?? 'Unknown Hazard',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text('${r['ward'] ?? ''}'.trim().isEmpty
                          ? (r['address']?.toString() ?? '')
                          : '${r['ward'] ?? ''}'.trim(),
                          style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(r['createdAt']?.toString().substring(0, 10) ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: color.withValues(alpha: 0.4))),
                      child: Text(status.replaceAll('_', ' '), style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
                  ]
                )
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  void _showReportSummary(Map<String, dynamic> report, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetailSheet(report, context),
    );
  }

  Widget _buildDetailSheet(Map<String, dynamic> report, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(height: 5, width: 40, margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(report['reportedCategory']?.toString().replaceAll('_', ' ') ?? 'Unknown',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(report['description'] ?? 'No description provided.',
                      style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  if (report['fakeLikelihood'] != null || report['severity'] != null)
                    Card(
                      color: Colors.blueGrey.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.blueGrey, size: 20),
                                SizedBox(width: 8),
                                Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (report['validHazard'] != null)
                              Text('Valid Hazard: ${report['validHazard']}'),
                            if (report['isRoadImage'] != null)
                              Text('Is Road Image: ${report['isRoadImage']}'),
                            if (report['fakeLikelihood'] != null)
                              Text('Fake Likelihood: ${report['fakeLikelihood']}'),
                            if (report['severity'] != null)
                              Text('Severity: ${report['severity']}'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text('Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${report['fullAddress'] ?? report['address'] ?? 'Location not available'}',
                      style: TextStyle(color: Colors.grey[700], height: 1.4)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Ward Reports (${_reports.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white, elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.map_outlined), tooltip: 'View on map',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapScreen(initialMode: 'Nearby')))),
        ],
      ),
      body: _buildList(),
    );
  }
}
