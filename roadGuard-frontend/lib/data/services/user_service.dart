import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  final _client = http.Client();

  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getProfile}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting profile: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminUsers}'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get users: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting users: $e');
    }
  }
}
