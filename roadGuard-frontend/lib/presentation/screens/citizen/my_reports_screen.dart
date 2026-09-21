import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/report_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final ReportService _reportService = ReportService();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await _reportService.getMyReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'VERIFIED':
      case 'RESOLVED':
        return Colors.green;
      case 'ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'REJECTED':
      case 'AI_REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showReportDetail(Map<String, dynamic> report) {
    final status = report['reportStatus']?.toString() ?? 'SUBMITTED';
    final color = _statusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.35,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      report['reportedCategory']?.toString() ?? 'Unknown Hazard',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    label: Text(
                      status.split('_').join(' '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: color.withValues(alpha: 0.15),
                    side: BorderSide(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),

              _row(Icons.description, 'Description',
                  report['description']?.toString() ?? 'No description'),
              _row(Icons.location_on, 'Coordinates',
                  '${report['latitude']?.toString() ?? 'N/A'}, ${report['longitude']?.toString() ?? 'N/A'}'),
              if (report['address'] != null)
                _row(Icons.map, 'Address', report['address'].toString()),
              if (report['city'] != null || report['ward'] != null)
                _row(Icons.location_city, 'Area',
                    '${report['ward'] ?? ''} ${report['city'] ?? ''}'.trim()),
              _row(
                Icons.access_time,
                'Submitted',
                (report['createdAt']?.toString() ?? 'N/A')
                    .replaceFirst('T', '  '),
              ),

              // Photo
              if (report['imageUrl'] != null &&
                  report['imageUrl'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Photo:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ApiConstants.formatImageUrl(report['imageUrl']?.toString()),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 60,
                      alignment: Alignment.center,
                      color: Colors.grey[100],
                      child: const Text('Image unavailable'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: Text('$label:',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No reports yet',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text(
                          'Start reporting hazards to make roads safer',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final status =
                          report['reportStatus']?.toString() ?? 'SUBMITTED';
                      final color = _statusColor(status);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showReportDetail(report),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  child: const Icon(Icons.warning,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report['reportedCategory']
                                                ?.toString() ??
                                            'Unknown Hazard',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        report['description']?.toString() ??
                                            'No description',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        (report['createdAt']?.toString() ?? '')
                                            .replaceFirst('T', '  '),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Chip(
                                      label: Text(
                                        status.split('_').join(' '),
                                        style:
                                            const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor:
                                          color.withValues(alpha: 0.12),
                                      side: BorderSide(color: color),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const Icon(Icons.chevron_right,
                                        color: Colors.grey),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
