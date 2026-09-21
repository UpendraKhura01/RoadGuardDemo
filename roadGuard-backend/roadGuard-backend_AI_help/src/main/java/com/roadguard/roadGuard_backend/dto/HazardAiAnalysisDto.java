package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class HazardAiAnalysisDto {
    private String aiProvider;

    private Boolean roadImage;
    private Boolean validHazard;

    private HazardCategory hazardCategory;
    private Double confidence;
    private Severity severity;

    private Integer aiPriorityScore;
    private Boolean descriptionMatchesImage;
    private Boolean needsAdminReview;

    private String fakeLikelihood;
    private String explanation;
    private String rawResponse;

}
