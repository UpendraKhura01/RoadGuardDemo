package com.roadguard.roadGuard_backend.dto;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class passwordLoginRequestDto {
    private String phoneNumber;
    private String password;
}
