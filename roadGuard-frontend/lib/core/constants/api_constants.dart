import 'package:flutter/foundation.dart';

class ApiConstants {
  // Platform-aware base URL: 10.0.2.2 for Android emulator, localhost for Web/Desktop
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/roadguard/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Connects directly to laptop backend via USB port forwarding (adb reverse tcp:8080 tcp:8080)
      return 'http://localhost:8080/roadguard/v1';
    }
    return 'http://localhost:8080/roadguard/v1';
  }

  // Resolves relative image paths like /uploads/reports/xyz.jpg to full backend URLs
  static String formatImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final root = baseUrl.replaceAll('/roadguard/v1', '');
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$root$cleanPath';
  }
  
  // Auth endpoints
  static const String sendOtp = '/auth/sendOtp';
  static const String verifyOtp = '/auth/login/phoneNumber';
  static const String signup = '/auth/signup/phoneNumber';
  static const String loginPassword = '/auth/login/password';
  
  // Citizen endpoints
  static const String createReport = '/citizen/report/create';
  static const String myReports = '/citizen/report/myReports';
  static const String getReportById = '/citizen/report/getReportById';
  
  // Public endpoints
  static const String publicReports = '/public/reports';
  
  // Admin endpoints
  static const String adminReports = '/admin/reports';
  static const String adminAllReports = '/admin/reports/all';
  static const String reviewReport = '/admin/reviewReport';
  static const String updateReportStatus = '/admin/updateReportStatus';
  static const String assignContractor = '/admin/assignContractor';
  static const String adminContractors = '/admin/contractors';
  
  // Storage keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
}