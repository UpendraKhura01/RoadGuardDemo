import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/report_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ReportService _reportService = ReportService();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String _selectedStatus = 'ALL_ACTIVE';

  final List<String> _statusOptions = [
    'ALL_ACTIVE',
    'SUBMITTED',
    'PENDING_REVIEW',
    'VERIFIED',
    'ASSIGNED',
    'IN_PROGRESS',
    'RESOLVED',
    'REJECTED',
    'AI_REJECTED',
    'DUPLICATE',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> reports;
      if (_selectedStatus == 'ALL_ACTIVE') {
        reports = await _reportService.getAllAdminReports();
      } else {
        reports = await _reportService.getAdminReports(_selectedStatus);
      }
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reports: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
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
      case 'SUBMITTED':
      case 'PENDING_REVIEW':
        return Colors.amber[700] ?? Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // Opens a bottom sheet with full report details + actions
  void _showReportDetail(Map<String, dynamic> report) {
    final reportId = report['reportId'] != null ? (report['reportId'] as num).toInt() : 0;
    final statusStr = report['reportStatus']?.toString() ?? 'SUBMITTED';
    final statusColor = _getStatusColor(statusStr);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
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

              // Title row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Report #$reportId',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    label: Text(
                      statusStr.split('_').join(' '),
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    side: BorderSide(color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),

              // Detail rows
              _detailRow(Icons.person, 'Citizen',
                  report['userName'] ?? 'User #${report['userId'] ?? 'Unknown'}'),
              _detailRow(Icons.warning_amber, 'Category',
                  report['reportedCategory']?.toString() ?? 'Unknown'),
              _detailRow(Icons.description, 'Description',
                  report['description']?.toString() ?? 'No description'),
              _detailRow(Icons.location_on, 'Coordinates',
                  '${report['latitude']?.toString() ?? 'N/A'}, ${report['longitude']?.toString() ?? 'N/A'}'),
              _detailRow(Icons.map, 'Address',
                  report['address']?.toString() ?? 'N/A'),
              if (report['ward'] != null || report['city'] != null)
                _detailRow(Icons.location_city, 'Ward / City',
                    '${report['ward'] ?? ''} ${report['city'] ?? ''}'.trim()),
              _detailRow(Icons.access_time, 'Submitted',
                  (report['createdAt']?.toString() ?? 'N/A').replaceFirst('T', '  ')),

              // AI Assessment
              if (report['aiExplanation'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.psychology, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI: ${report['aiExplanation']}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Photo
              if (report['imageUrl'] != null &&
                  report['imageUrl'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Photo:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ApiConstants.formatImageUrl(report['imageUrl']?.toString()),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Could not load image'),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Review'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showReviewDialog(report);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Assign'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showAssignDialog(report);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.split('_').join(' ')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _loadReports();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: _loadReports,
              ),
            ],
          ),
        ),

        // Reports list
        Expanded(
          child: RefreshIndicator(
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
                            Text(
                              'No reports with status: $_selectedStatus',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          final statusStr = report['reportStatus']?.toString() ?? 'SUBMITTED';
                          final statusColor = _getStatusColor(statusStr);
                          final categoryStr = report['reportedCategory']?.toString() ?? 'Unknown Hazard';
                          final reportId = report['reportId'] != null
                              ? (report['reportId'] as num).toInt()
                              : index;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            // Wrap in InkWell for reliable tap on web
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showReportDetail(report),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: statusColor,
                                      child: const Icon(Icons.warning, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '#$reportId — $categoryStr',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            report['userName'] ??
                                                'User #${report['userId'] ?? 'Unknown'}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                          if (report['address'] != null)
                                            Text(
                                              report['address'].toString(),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Chip(
                                          label: Text(
                                            statusStr.split('_').join(' '),
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          backgroundColor: statusColor.withValues(alpha: 0.12),
                                          side: BorderSide(color: statusColor),
                                          padding: EdgeInsets.zero,
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
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
        ),
      ],
    );
  }

  void _showReviewDialog(Map<String, dynamic> report) {
    final reportId = (report['reportId'] as num).toInt();
    String selectedDecision = 'APPROVE';
    String selectedSeverity = 'MEDIUM';
    final categoryController = TextEditingController(
        text: report['reportedCategory']?.toString() ?? '');
    final commentController = TextEditingController();

    final decisions = ['APPROVE', 'REJECT', 'NEED_MORE_INFO', 'MARK_DUPLICATE'];
    final severities = ['HIGH', 'MEDIUM', 'LOW'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Review Report #$reportId'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Review Decision:'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedDecision,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: decisions
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedDecision = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Severity:'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: selectedSeverity,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: severities
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedSeverity = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Final Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Review Notes / Comment',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _reportService.reviewReport(
                    reportId: reportId,
                    finalDecision: selectedDecision,
                    finalSeverity: selectedSeverity,
                    finalCategory: categoryController.text.trim().isNotEmpty
                        ? categoryController.text.trim()
                        : (report['reportedCategory']?.toString() ?? 'OTHER'),
                    comment: commentController.text.trim().isEmpty
                        ? null
                        : commentController.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review submitted successfully')),
                  );
                  _loadReports();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(Map<String, dynamic> report) async {
    final reportId = (report['reportId'] as num).toInt();
    List<Map<String, dynamic>> contractors = [];
    try {
      contractors = await _reportService.getContractors();
    } catch (_) {}

    if (!mounted) return;

    int? selectedContractorId = contractors.isNotEmpty
        ? (contractors.first['id'] as num?)?.toInt()
        : null;

    final manualIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Contractor — Report #$reportId'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contractors.isNotEmpty) ...[
                  const Text('Select Contractor:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: selectedContractorId,
                    isExpanded: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: contractors.map((c) {
                      final cId = (c['id'] as num).toInt();
                      final cName = c['name']?.toString() ?? 'Contractor #$cId';
                      final cArea = c['area'] != null ? ' (${c['area']})' : '';
                      return DropdownMenuItem<int>(
                        value: cId,
                        child: Text('$cName$cArea', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) => setDialogState(() => selectedContractorId = val),
                  ),
                ] else ...[
                  const Text('No contractors found. Enter ID manually:'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: manualIdController,
                    decoration: const InputDecoration(
                      labelText: 'Contractor ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final targetId = selectedContractorId ??
                    int.tryParse(manualIdController.text.trim());
                if (targetId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select or enter a valid Contractor ID')),
                  );
                  return;
                }
                try {
                  await _reportService.assignContractor(
                    reportId: reportId,
                    contractorId: targetId,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contractor assigned successfully')),
                  );
                  _loadReports();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}