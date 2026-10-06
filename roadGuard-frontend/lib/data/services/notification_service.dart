import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class NotificationService {
  final AuthService _authService = AuthService();
  final _client = http.Client();

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getMyNotifications}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get notifications: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting notifications: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.markAsRead}?notificationId=$notificationId'),
        headers: headers,
      );
    } catch (e) {
      // Silently fail — marking as read is non-critical
    }
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      final headers = await _authService.getAuthHeaders();
      await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateLocation}?latitude=$latitude&longitude=$longitude'),
        headers: headers,
      );
    } catch (e) {
      // Silently fail — location update is best-effort
    }
  }
}
