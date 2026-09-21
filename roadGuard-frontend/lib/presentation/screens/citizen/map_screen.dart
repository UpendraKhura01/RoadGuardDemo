import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/report_service.dart';
import '../../../data/services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ReportService _reportService = ReportService();
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();

  List<Marker> _markers = [];
  Position? _currentPosition;
  bool _isLoading = true;
  List<Map<String, dynamic>> _nearbyReports = [];
  String? _errorMessage;

  // Default center: India
  static const LatLng _defaultCenter = LatLng(20.5937, 78.9629);
  static const double _defaultZoom = 5.0;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Try to get location, but don't block map loading if it fails
    try {
      _currentPosition = await _locationService.getCurrentPosition();
    } catch (_) {
      // Location unavailable — map will show with default center
    }

    // Load reports — use current position if available, otherwise use default
    await _loadNearbyReports();

    // Move map to user position if we got it
    if (_currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            14,
          );
        }
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbyReports() async {
    try {
      // Use current position or a wide search from India center
      final lat = _currentPosition?.latitude ?? _defaultCenter.latitude;
      final lng = _currentPosition?.longitude ?? _defaultCenter.longitude;
      // Use wide radius if no location so all reports appear
      final radiusKm = _currentPosition != null ? 10.0 : 5000.0;

      final reports = await _reportService.getPublicReports(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );

      if (mounted) {
        setState(() {
          _nearbyReports = reports;
          _markers = _createMarkers(reports);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load reports. Is the backend running?';
        });
      }
    }
  }

  List<Marker> _createMarkers(List<Map<String, dynamic>> reports) {
    return reports
        .where((r) => r['latitude'] != null && r['longitude'] != null)
        .map((report) {
      final lat = (report['latitude'] as num).toDouble();
      final lng = (report['longitude'] as num).toDouble();
      final status = report['reportStatus']?.toString() ?? '';

      return Marker(
        point: LatLng(lat, lng),
        width: 40,
        height: 40,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _showReportSummary(report),
          child: Icon(
            Icons.location_pin,
            color: _markerColor(status),
            size: 36,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black38)],
          ),
        ),
      );
    }).toList();
  }

  Color _markerColor(String? status) {
    switch (status) {
      case 'VERIFIED':
        return Colors.green;
      case 'ASSIGNED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'RESOLVED':
        return Colors.teal;
      default:
        return Colors.red;
    }
  }

  void _showReportSummary(Map<String, dynamic> report) {
    final status = report['reportStatus']?.toString() ?? 'Unknown';
    final color = _markerColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Category + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    report['reportedCategory']?.toString() ?? 'Hazard',
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
            const SizedBox(height: 8),

            // Description
            if (report['description'] != null &&
                report['description'].toString().isNotEmpty)
              Text(
                report['description'].toString(),
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            const SizedBox(height: 8),

            // Address
            if (report['address'] != null)
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report['address'].toString(),
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),

            // Time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  (report['createdAt']?.toString() ?? '')
                      .replaceFirst('T', '  '),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            // Photo
            if (report['imageUrl'] != null &&
                report['imageUrl'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ApiConstants.formatImageUrl(report['imageUrl']?.toString()),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : _defaultCenter;

    final zoom = _currentPosition != null ? 14.0 : _defaultZoom;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadguard.app',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),

          // Refresh button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _initializeMap,
              tooltip: 'Refresh',
              child: const Icon(Icons.refresh),
            ),
          ),

          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _legend(Colors.red, 'Submitted'),
                    _legend(Colors.green, 'Verified'),
                    _legend(Colors.blue, 'Assigned'),
                    _legend(Colors.orange, 'In Progress'),
                    _legend(Colors.teal, 'Resolved'),
                  ],
                ),
              ),
            ),
          ),

          // Error or empty message
          if (_errorMessage != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            )
          else if (_nearbyReports.isEmpty)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    _currentPosition != null
                        ? 'No hazards reported near your location'
                        : 'Allow location access to see nearby hazards',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),

          // Report count badge
          if (_nearbyReports.isNotEmpty)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Text(
                      '${_nearbyReports.length} hazard${_nearbyReports.length == 1 ? '' : 's'} found — tap a pin for details',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_pin, color: color, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
