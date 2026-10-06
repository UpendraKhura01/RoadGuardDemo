import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../data/services/report_service.dart';
import '../../../data/services/location_service.dart';
import '../../../data/services/notification_service.dart';
import '../../providers/auth_provider.dart';

class MapScreen extends StatefulWidget {
  final String initialMode;
  const MapScreen({super.key, this.initialMode = 'Nearby'});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ReportService _reportService = ReportService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final MapController _mapController = MapController();

  List<Marker> _markers = [];
  Position? _currentPosition;
  bool _isLoading = true;
  List<Map<String, dynamic>> _reports = [];
  String? _errorMessage;
  late String _selectedMode;

  static const LatLng _defaultCenter = LatLng(20.5937, 78.9629);

  // Zoom levels per hierarchy
  static const Map<String, double> _zoomLevels = {
    'Nearby': 14.0,
    'City': 11.0,
    'District': 9.0,
    'State': 6.0,
    'Public': 5.0,
  };

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      // Push location update to backend
      if (_currentPosition != null) {
        await _notificationService.updateLocation(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (_) {}
    await _loadReports();
    if (_currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            _zoomLevels[_selectedMode] ?? 10.0,
          );
        }
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadReports() async {
    try {
      List<Map<String, dynamic>> reports;
      switch (_selectedMode) {
        case 'Nearby':
          reports = await _reportService.getNearbyReports();
          break;
        case 'City':
          reports = await _reportService.getCityReports();
          break;
        case 'District':
          reports = await _reportService.getDistrictReports();
          break;
        case 'State':
          // Always filter by state — Admin's registered state = their jurisdiction
          reports = await _reportService.getStateReports();
          break;
        default:
          final lat = _currentPosition?.latitude ?? _defaultCenter.latitude;
          final lng = _currentPosition?.longitude ?? _defaultCenter.longitude;
          final radius = _currentPosition != null ? 10.0 : 5000.0;
          reports = await _reportService.getPublicReports(lat: lat, lng: lng, radiusKm: radius);
      }
      if (mounted) {
        setState(() {
          _reports = reports;
          _markers = _createMarkers(reports);
        });
      }
    } catch (e) {
      // Fall back to public reports if location not set yet
      try {
        final lat = _currentPosition?.latitude ?? _defaultCenter.latitude;
        final lng = _currentPosition?.longitude ?? _defaultCenter.longitude;
        final reports = await _reportService.getPublicReports(lat: lat, lng: lng, radiusKm: 5000.0);
        if (mounted) {
          setState(() {
            _reports = reports;
            _markers = _createMarkers(reports);
          });
        }
      } catch (_) {
        if (mounted) setState(() => _errorMessage = 'Could not load reports.');
      }
    }
  }

  void _onModeChanged(String? mode) {
    if (mode == null || mode == _selectedMode) return;
    setState(() {
      _selectedMode = mode;
      _isLoading = true;
    });
    _loadReports().then((_) {
      if (_currentPosition != null && mounted) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          _zoomLevels[mode] ?? 10.0,
        );
      }
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<Marker> _createMarkers(List<Map<String, dynamic>> reports) {
    // Group reports within ~111m grid cells into clusters
    final Map<String, List<Map<String, dynamic>>> clusters = {};
    for (final r in reports) {
      if (r['latitude'] == null || r['longitude'] == null) continue;
      final lat = (r['latitude'] as num).toDouble();
      final lng = (r['longitude'] as num).toDouble();
      final key = '${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}';
      clusters.putIfAbsent(key, () => []).add(r);
    }
    return clusters.entries.map((entry) {
      final group = entry.value;
      final first = group.first;
      final lat = (first['latitude'] as num).toDouble();
      final lng = (first['longitude'] as num).toDouble();
      final count = group.length;
      final color = _markerColor(first['reportStatus']?.toString() ?? '');
      return Marker(
        point: LatLng(lat, lng),
        width: count > 1 ? 56 : 40,
        height: count > 1 ? 56 : 40,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => count > 1 ? _showClusterList(group) : _showReportSummary(first),
          child: Stack(clipBehavior: Clip.none, children: [
            Icon(Icons.location_pin, color: color, size: count > 1 ? 48 : 36,
                shadows: const [Shadow(blurRadius: 4, color: Colors.black38)]),
            if (count > 1)
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
                ),
              ),
          ]),
        ),
      );
    }).toList();
  }

  void _showClusterList(List<Map<String, dynamic>> reports) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.5, maxChildSize: 0.9, minChildSize: 0.3,
        builder: (ctx, scroll) => Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.place, color: Color(0xFF009688)),
              const SizedBox(width: 8),
              Text('${reports.length} Reports at this location',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ]),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              controller: scroll, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: reports.length,
              itemBuilder: (ctx, i) {
                final r = reports[i];
                final status = r['reportStatus']?.toString() ?? '';
                final color = _markerColor(status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(Icons.warning_amber_rounded, color: color, size: 22)),
                    title: Text(r['reportedCategory']?.toString().replaceAll('_', ' ') ?? 'Hazard',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (r['description'] != null && r['description'].toString().isNotEmpty)
                        Text(r['description'].toString(), maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      Text(r['createdAt']?.toString().substring(0, 10) ?? '',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ]),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(status.replaceAll('_', ' '),
                          style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
                    ),
                    onTap: () { Navigator.pop(ctx); _showReportSummary(r); },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Color _markerColor(String? status) {
    switch (status) {
      case 'VERIFIED': return Colors.green;
      case 'ASSIGNED': return Colors.blue;
      case 'IN_PROGRESS': return Colors.orange;
      case 'RESOLVED': return Colors.teal;
      default: return Colors.red;
    }
  }

  void _showReportSummary(Map<String, dynamic> report) {
    final status = report['reportStatus']?.toString() ?? 'Unknown';
    final color = _markerColor(status);
    final aiExplanation = report['aiExplanation']?.toString();
    final decisionReason = report['decisionReason']?.toString();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.55, maxChildSize: 0.9, minChildSize: 0.3,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            Row(children: [
              Expanded(child: Text(report['reportedCategory']?.toString().replaceAll('_', ' ') ?? 'Hazard',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Chip(label: Text(status.replaceAll('_', ' '), style: const TextStyle(fontSize: 12)),
                  backgroundColor: color.withValues(alpha: 0.15), side: BorderSide(color: color)),
            ]),
            const SizedBox(height: 8),
            if (report['description'] != null && report['description'].toString().isNotEmpty)
              Text(report['description'].toString(), style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            const SizedBox(height: 8),
            if (report['ward'] != null || report['block'] != null)
              Row(children: [
                const Icon(Icons.place_outlined, size: 16, color: Color(0xFF009688)),
                const SizedBox(width: 4),
                Expanded(child: Text(
                  [report['ward'], report['block'], report['district']].where((e) => e != null && e.toString().isNotEmpty).join(', '),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                )),
              ]),
            if ((aiExplanation != null && aiExplanation.isNotEmpty) ||
                (decisionReason != null && decisionReason.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF0FFF4), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF009688).withValues(alpha: 0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.psychology_outlined, color: Color(0xFF009688), size: 18),
                    SizedBox(width: 6),
                    Text('AI Analysis', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF009688), fontSize: 13)),
                  ]),
                  if (aiExplanation != null && aiExplanation.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(aiExplanation, style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                  ],
                  if (decisionReason != null && decisionReason.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Reason: $decisionReason', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  ],
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.userRole == 'ADMIN';
    final modes = ['Nearby', 'City', 'District', if (isAdmin) 'State'];

    return Scaffold(
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentPosition != null
                ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                : _defaultCenter,
            initialZoom: _zoomLevels[_selectedMode] ?? 5.0,
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadguard.app'),
            MarkerLayer(markers: _markers),
          ],
        ),

        // Dropdown mode selector
        Positioned(top: 12, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              const Icon(Icons.layers_outlined, color: Color(0xFF009688)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMode,
                    isExpanded: true,
                    style: const TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600, fontSize: 15),
                    onChanged: _onModeChanged,
                    items: modes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF009688))),
            ]),
          ),
        ),

        if (_errorMessage != null)
          Positioned(bottom: 20, left: 16, right: 16,
            child: Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300)),
              child: Text(_errorMessage!, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center),
            ),
          ),

        // Legend
        Positioned(bottom: 20, right: 16,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _legendItem(Colors.red, 'Submitted'),
              _legendItem(Colors.green, 'Verified'),
              _legendItem(Colors.blue, 'Assigned'),
              _legendItem(Colors.orange, 'In Progress'),
              _legendItem(Colors.teal, 'Resolved'),
            ]),
          ),
        ),

        // Report count badge
        Positioned(top: 70, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFF009688), borderRadius: BorderRadius.circular(20)),
            child: Text('${_reports.length} reports', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11)),
      ]),
    );
  }
}

