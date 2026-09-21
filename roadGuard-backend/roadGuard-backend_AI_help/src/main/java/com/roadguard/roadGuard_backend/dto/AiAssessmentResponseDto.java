package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AiAssessmentResponseDto {
    //return Ai response
    private Long assessmentId;

    private Long reportId;

    private String provider;
    private Boolean isRoadImage;
    private Boolean validHazard;

    private HazardCategory hazardCategory;
    private Severity severity;

    private Double confidence;
    private String fakeLikelihood;

    private Integer aiPriorityScore;
    private Boolean descriptionMatchesImage;
    private Boolean needsAdminReview;

    private String explanation;

    private LocalDateTime createdAt;
}
