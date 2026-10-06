
class ApiConstants {
  // Platform-aware base URL: 10.0.2.2 for Android emulator, localhost for Web/Desktop
  static String get baseUrl {
    // return 'https://roadguarddemo.onrender.com/roadguard/v1';
    return 'http://10.253.54.55:8080/roadguard/v1';
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
  
  // Citizen report endpoints
  static const String createReport = '/citizen/report/create';
  static const String myReports = '/citizen/report/myReports';
  static const String getReportById = '/citizen/report/getReportById';
  static const String nearbyReports = '/citizen/report/nearbyReports';
  static const String cityReports = '/citizen/report/cityReports';
  static const String districtReports = '/citizen/report/DistrictReports';

  // User endpoints
  static const String updateLocation = '/User/update_location';
  static const String getProfile = '/User/me';
  
  // Public endpoints
  static const String publicReports = '/public/reports';
  
  // Admin endpoints
  static const String adminReports = '/admin/reports';
  static const String adminAllReports = '/admin/reports/all';
  static const String reviewReport = '/admin/reviewReport';
  static const String updateReportStatus = '/admin/updateReportStatus';
  static const String assignContractor = '/admin/assignContractor';
  static const String adminContractors = '/admin/contractors';
  static const String adminStateReports = '/admin/StateReports';
  static const String adminUsers = '/admin/users';

  // Notification endpoints
  static const String getMyNotifications = '/notification/getMyNotifications';
  static const String markAsRead = '/notification/markAsRead';

  // Storage keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
}