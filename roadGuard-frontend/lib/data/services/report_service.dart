import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class ReportService {
  final AuthService _authService = AuthService();
  final _client = http.Client();

  // Create a new hazard report
  // Uses bytes instead of File so it works on both Flutter Web and Android
  Future<Map<String, dynamic>> createReport({
    required Uint8List imageBytes,
    required String imageName,
    required double latitude,
    required double longitude,
    required String description,
    String? reportedCategory,
    bool? vpnDetected,
    bool? fakeLocation,
    bool? cameraOnly,
    double? gpsAccuracy,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createReport}'),
      );

      request.headers.addAll(headers);

      // Add image using bytes — works on both Web and Android
      // Must set contentType explicitly or backend rejects with "photo type is invalid"
      final ext = imageName.toLowerCase().endsWith('.png') ? 'png' : 'jpeg';
      request.files.add(http.MultipartFile.fromBytes(
        'photo',
        imageBytes,
        filename: imageName,
        contentType: MediaType('image', ext),
      ));

      // Add report data as JSON
      final reportData = {
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'reportedCategory': reportedCategory,
        'vpnDetected': vpnDetected ?? false,
        'fakeLocation': fakeLocation ?? false,
        'cameraOnly': cameraOnly ?? true,
        'gpsAccuracy': gpsAccuracy,
        // capturedAt omitted — backend LocalDateTime parsing not configured;
        // the database records created_at automatically
      };

      request.fields['data'] = jsonEncode(reportData);

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }

  // Get user's reports
  Future<List<Map<String, dynamic>>> getMyReports() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.myReports}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get reports: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting reports: $e');
    }
  }

  // Get report by ID
  Future<Map<String, dynamic>> getReportById(int reportId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getReportById}?id=$reportId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting report: $e');
    }
  }

  // Get public reports (for map view)
  Future<List<Map<String, dynamic>>> getPublicReports({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.publicReports}?lat=$lat&lng=$lng&radiusKm=$radiusKm'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get public reports: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting public reports: $e');
    }
  }

  // Get admin reports by status
  Future<List<Map<String, dynamic>>> getAdminReports(String status) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminReports}?status=$status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get admin reports: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting admin reports: $e');
    }
  }

  // Get ALL active admin reports (excludes REJECTED, AI_REJECTED, RESOLVED)
  Future<List<Map<String, dynamic>>> getAllAdminReports() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminAllReports}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get all admin reports: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting all admin reports: $e');
    }
  }

  // Review report (admin only)
  Future<Map<String, dynamic>> reviewReport({
    required dynamic reportId,
    required String finalDecision,
    required String finalSeverity,
    required String finalCategory,
    String? comment,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.reviewReport}?reportId=$reportId'),
        headers: headers,
        body: jsonEncode({
          'finalDecision': finalDecision,
          'finalSeverity': finalSeverity,
          'finalCategory': finalCategory,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to review report: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error reviewing report: $e');
    }
  }

  // Update report status (admin only)
  Future<void> updateReportStatus({
    required dynamic reportId,
    required String newStatus,
    String? notes,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateReportStatus}?reportId=$reportId'),
        headers: headers,
        body: jsonEncode({
          'newStatus': newStatus,
          'notes': notes,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update report status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating report status: $e');
    }
  }

  // Assign contractor to report (admin only)
  Future<void> assignContractor({
    required dynamic reportId,
    required dynamic contractorId,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.assignContractor}'),
        headers: headers,
        body: jsonEncode({
          'reportId': reportId,
          'contractorId': contractorId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to assign contractor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error assigning contractor: $e');
    }
  }

  // Get all contractors (admin only)
  Future<List<Map<String, dynamic>>> getContractors() async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminContractors}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get contractors: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting contractors: $e');
    }
  }

  // Create contractor (admin only)
  Future<Map<String, dynamic>> createContractor({
    required String name,
    required String phoneNumber,
    String? email,
    String? specialization,
    String? area,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminContractors}'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'phoneNumber': phoneNumber,
          'email': email,
          'specialization': specialization,
          'area': area,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create contractor: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating contractor: $e');
    }
  }
}