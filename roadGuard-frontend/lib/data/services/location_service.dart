import 'vpn_checker.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permissions
  Future<bool> requestLocationPermission() async {
    if (kIsWeb) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    }
    var status = await Permission.location.request();
    return status.isGranted;
  }

  // Get current position with high accuracy
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    bool permissionGranted = await requestLocationPermission();
    if (!permissionGranted) {
      throw Exception('Location permission denied. Please grant permission.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  // Check GPS accuracy
  bool isGpsAccuracyAcceptable(double accuracy) {
    // Accuracy in meters - accept if within 150 meters
    return accuracy <= 150.0;
  }

  // Detect if VPN might be active (basic check)
  Future<bool> isVpnDetected() async {
    return await checkVpnInterfaces();
  }

  // Check if location might be fake (using position.isMocked and physical heuristics)
  Future<bool> isFakeLocation(Position position) async {
    // 1. Android/iOS mock location provider flag
    if (position.isMocked) {
      return true;
    }

    // 2. Check if altitude is reasonable (between -500m and 9000m)
    if (position.altitude < -500 || position.altitude > 9000) {
      return true;
    }

    // 3. Check if speed is reasonable on ground (> 100 m/s = 360 km/h)
    if (position.speed > 100) {
      return true;
    }

    return false;
  }

  // Get location with security checks
  Future<Map<String, dynamic>> getSecureLocation() async {
    final position = await getCurrentPosition();
    
    // Security checks
    final vpnDetected = await isVpnDetected();
    final fakeLocation = await isFakeLocation(position);
    final gpsAccuracy = position.accuracy;
    final accuracyAcceptable = isGpsAccuracyAcceptable(gpsAccuracy);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': gpsAccuracy,
      'altitude': position.altitude,
      'speed': position.speed,
      'timestamp': position.timestamp.toIso8601String(),
      'vpnDetected': vpnDetected,
      'fakeLocation': fakeLocation,
      'gpsAccuracyAcceptable': accuracyAcceptable,
    };
  }

  // Calculate distance between two coordinates (in kilometers)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2));
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}