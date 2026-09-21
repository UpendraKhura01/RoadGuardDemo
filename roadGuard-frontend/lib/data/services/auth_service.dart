import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

  // Send OTP for phone number verification
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sendOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  // Verify OTP and login
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeTokens(data['token']);
        return data;
      } else {
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Signup with phone and password
  Future<Map<String, dynamic>> signup(String phoneNumber, String password, String name, String otp) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.signup}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'name': name,
          'otp': otp,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storeTokens(data['token']);
        return data;
      } else {
        throw Exception('Failed to signup: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  // Login with password
  Future<Map<String, dynamic>> loginWithPassword(String phoneNumber, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeTokens(data['token']);
        return data;
      } else {
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error logging in: $e');
    }
  }

  // Store tokens securely
  Future<void> _storeTokens(String token) async {
    await _storage.write(key: ApiConstants.accessToken, value: token);
    
    // Decode JWT to get user info
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    await _storage.write(key: ApiConstants.userId, value: decodedToken['sub'].toString());
    await _storage.write(key: ApiConstants.userRole, value: decodedToken['role'] ?? 'CITIZEN');
  }

  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.accessToken);
  }

  // Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: ApiConstants.userId);
  }

  // Get user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: ApiConstants.userRole);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Check if token is expired
    return !JwtDecoder.isExpired(token);
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: ApiConstants.accessToken);
    await _storage.delete(key: ApiConstants.userId);
    await _storage.delete(key: ApiConstants.userRole);
  }

  // Get authorization header
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
