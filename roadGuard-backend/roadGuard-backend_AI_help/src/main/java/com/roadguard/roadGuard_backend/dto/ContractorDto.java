package com.roadguard.roadGuard_backend.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContractorDto {
    private Long id;
    private String name;
    private String phoneNumber;
    private String email;
    private String specialization;
    private String area;
}
