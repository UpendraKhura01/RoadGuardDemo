package com.roadguard.roadGuard_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class UserProfileDto {
    private Long id;
    private String name;
    private String phoneNumber;
    private String gmail;
    private Long reputationScore;
    private String ward;
    private String block;
    private String district;
    private String state;
    private String fullAddress;
}
