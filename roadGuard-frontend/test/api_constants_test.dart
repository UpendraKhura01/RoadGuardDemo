import 'package:flutter_test/flutter_test.dart';
import 'package:roadguard_frontend/core/constants/api_constants.dart';

void main() {
  group('ApiConstants Tests', () {
    test('baseUrl returns valid HTTP URL', () {
      expect(ApiConstants.baseUrl, startsWith('http://'));
      expect(ApiConstants.baseUrl, contains(':8080/roadguard/v1'));
    });

    test('Endpoint paths are non-empty and well-formed', () {
      expect(ApiConstants.sendOtp, equals('/auth/sendOtp'));
      expect(ApiConstants.verifyOtp, equals('/auth/login/phoneNumber'));
      expect(ApiConstants.signup, equals('/auth/signup/phoneNumber'));
      expect(ApiConstants.loginPassword, equals('/auth/login/password'));
      expect(ApiConstants.createReport, equals('/citizen/report/create'));
      expect(ApiConstants.myReports, equals('/citizen/report/myReports'));
      expect(ApiConstants.publicReports, equals('/public/reports'));
      expect(ApiConstants.adminReports, equals('/admin/reports'));
      expect(ApiConstants.adminContractors, equals('/admin/contractors'));
      expect(ApiConstants.assignContractor, equals('/admin/assignContractor'));
      expect(ApiConstants.reviewReport, equals('/admin/reviewReport'));
    });
  });
}