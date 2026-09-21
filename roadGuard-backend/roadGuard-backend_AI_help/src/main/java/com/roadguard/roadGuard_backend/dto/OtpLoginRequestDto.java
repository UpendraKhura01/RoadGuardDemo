package com.roadguard.roadGuard_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class OtpLoginRequestDto {
    private String phoneNumber;
    private String otp;
}
