import 'package:flutter/material.dart';
import '../../../data/services/report_service.dart';

class AdminContractorsScreen extends StatefulWidget {
  const AdminContractorsScreen({super.key});

  @override
  State<AdminContractorsScreen> createState() => _AdminContractorsScreenState();
}

class _AdminContractorsScreenState extends State<AdminContractorsScreen> {
  final ReportService _reportService = ReportService();
  List<Map<String, dynamic>> _contractors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContractors();
  }

  Future<void> _loadContractors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contractors = await _reportService.getContractors();
      if (mounted) {
        setState(() {
          _contractors = contractors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contractors: $e')),
        );
      }
    }
  }

  void _showAddContractorDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final specializationController = TextEditingController();
    final areaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contractor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(labelText: 'Specialization (e.g. Road Repair)'),
              ),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(labelText: 'Area / Zone'),
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
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Phone Number are required')),
                );
                return;
              }

              try {
                await _reportService.createContractor(
                  name: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  specialization: specializationController.text.trim().isEmpty ? null : specializationController.text.trim(),
                  area: areaController.text.trim().isEmpty ? null : areaController.text.trim(),
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contractor added successfully')),
                  );
                  _loadContractors();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding contractor: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadContractors,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _contractors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No contractors found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "+" to add a contractor',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _contractors.length,
                    itemBuilder: (context, index) {
                      final contractor = _contractors[index];
                      final name = contractor['name']?.toString() ?? 'Contractor';
                      final phone = contractor['phoneNumber']?.toString() ?? 'N/A';
                      final spec = contractor['specialization']?.toString() ?? 'General';
                      final area = contractor['area']?.toString() ?? 'All areas';
                      final status = contractor['status']?.toString() ?? 'ACTIVE';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'C'),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: $phone'),
                              Text('Specialization: $spec'),
                              Text('Area: $area'),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              status,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: status == 'ACTIVE'
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContractorDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}