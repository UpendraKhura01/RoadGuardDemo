package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.AuthProvider;
import lombok.Data;

@Data
public class SignupRequestDto {

    String phoneNumber;
    String name;
    String password;
    AuthProvider authProvider;
    String otp;
}
