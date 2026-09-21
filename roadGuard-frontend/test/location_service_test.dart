import 'package:flutter_test/flutter_test.dart';
import 'package:roadguard_frontend/data/services/location_service.dart';

void main() {
  late LocationService locationService;

  setUp(() {
    locationService = LocationService();
  });

  group('LocationService Tests', () {
    test('calculateDistance calculates correct distance between two points', () {
      // Coordinates of New York (40.7128, -74.0060) and Philadelphia (39.9526, -75.1652)
      // Distance is ~130 km
      final distance = locationService.calculateDistance(
        40.7128,
        -74.0060,
        39.9526,
        -75.1652,
      );

      expect(distance, greaterThan(120.0));
      expect(distance, lessThan(140.0));
    });

    test('calculateDistance returns 0 for same point', () {
      final distance = locationService.calculateDistance(
        18.7500,
        82.9130,
        18.7500,
        82.9130,
      );

      expect(distance, closeTo(0.0, 0.001));
    });

    test('isGpsAccuracyAcceptable accepts <= 150m and rejects > 150m', () {
      expect(locationService.isGpsAccuracyAcceptable(10.0), isTrue);
      expect(locationService.isGpsAccuracyAcceptable(50.0), isTrue);
      expect(locationService.isGpsAccuracyAcceptable(150.0), isTrue);
      expect(locationService.isGpsAccuracyAcceptable(150.1), isFalse);
      expect(locationService.isGpsAccuracyAcceptable(300.0), isFalse);
    });
  });
}