package com.roadguard.roadGuard_backend.Service;

import com.roadguard.roadGuard_backend.dto.OtpResponse;

public interface OtpService {

    OtpResponse sendOtp(String phoneNumber);
    String generateOtp(String number);
    void verifyOtp(String otp, String phoneNumber);
}
