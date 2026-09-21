package com.roadguard.roadGuard_backend.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AssignContractorRequestDto {
    private Long reportId;
    private Long contractorId;
}
