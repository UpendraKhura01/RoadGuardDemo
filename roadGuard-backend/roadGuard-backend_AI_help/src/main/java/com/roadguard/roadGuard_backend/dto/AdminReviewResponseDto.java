package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ReviewDecision;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AdminReviewResponseDto {

    private Long id;
    private Long reportId;

    private Long reviewedById;
    private String reviewedByName;

    private HazardCategory finalCategory;
    private Severity finalSeverity;
    private ReviewDecision finalDecision;

    private String comment;
    private LocalDateTime reviewedAt;



}
