import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/report_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/camera_service.dart';

class ReportHazardScreen extends StatefulWidget {
  const ReportHazardScreen({super.key});

  @override
  State<ReportHazardScreen> createState() => _ReportHazardScreenState();
}

class _ReportHazardScreenState extends State<ReportHazardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  final ReportService _reportService = ReportService();
  final LocationService _locationService = LocationService();
  final CameraService _cameraService = CameraService();

  // Use XFile so it works on both web and mobile
  XFile? _selectedImage;
  // Cache bytes for web image preview
  Future<List<int>>? _imageByteFuture;

  Map<String, dynamic>? _locationData;
  bool _isLoading = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'POTHOLE',
    'BROKEN_TRAFFIC_SIGNAL',
    'OPEN_MANHOLE',
    'FALLEN_TREE',
    'WATERLOGGING',
    'BROKEN_STREETLIGHT',
    'DAMAGED_ROAD',
    'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _cameraService.initializeCameras();
    } catch (e) {
      // Camera initialization failed, will use image picker fallback
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        // On web we can't force camera-only, so allow gallery too on web
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _imageByteFuture = image.readAsBytes().then((b) => b.toList());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationData = await _locationService.getSecureLocation();

      if (locationData['vpnDetected'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('VPN detected. Please disable VPN.')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (locationData['fakeLocation'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fake location detected. Please enable GPS.')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (!locationData['gpsAccuracyAcceptable']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GPS accuracy too low. Please ensure better location.')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _locationData = locationData;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location captured successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo of the hazard')),
      );
      return;
    }

    if (_locationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture your location')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final imageBytes = await _selectedImage!.readAsBytes();

      await _reportService.createReport(
        imageBytes: imageBytes,
        imageName: _selectedImage!.name,
        latitude: _locationData!['latitude'],
        longitude: _locationData!['longitude'],
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Hazard Report',
        reportedCategory: _categoryController.text.isNotEmpty
            ? _categoryController.text
            : null,
        vpnDetected: _locationData!['vpnDetected'],
        fakeLocation: _locationData!['fakeLocation'],
        cameraOnly: !kIsWeb, // on web we can't force camera
        gpsAccuracy: _locationData!['accuracy'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _selectedImage = null;
            _imageByteFuture = null;
            _locationData = null;
            _descriptionController.clear();
            _categoryController.clear();
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryController.dispose();
    _cameraService.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text('Tap to capture photo', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        FutureBuilder<List<int>>(
          future: _imageByteFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                Uint8List.fromList(snapshot.data!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            }
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          style: IconButton.styleFrom(backgroundColor: Colors.black45),
          onPressed: () {
            setState(() {
              _selectedImage = null;
              _imageByteFuture = null;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Hazard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image capture section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Photo of Hazard',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildImagePreview(),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(kIsWeb ? 'Upload Photo' : 'Capture Photo'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (_locationData != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latitude: ${_locationData!['latitude'].toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Longitude: ${_locationData!['longitude'].toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Accuracy: ${_locationData!['accuracy'].toStringAsFixed(1)}m',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Location not captured',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getCurrentLocation,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.location_on),
                        label: Text(_isLoading ? 'Getting Location...' : 'Capture Location'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description section
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Category section
              DropdownButtonFormField<String>(
                initialValue: _categoryController.text.isNotEmpty
                    ? _categoryController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Hazard Category (Optional)',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.split('_').join(' ')),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              if (_isSubmitting)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Report'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
