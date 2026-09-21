package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.AuthProvider;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LoginResponseDto {

    private Long userId;
    private String token;

    private String name;
    private String email;
    private String phoneNumber;

    private String role;

}
