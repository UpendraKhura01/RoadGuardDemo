package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class GeminiResponseDto {
    private String hazardCategory;
    private String severity;
    private Boolean isRoadImage;
    private Boolean validHazard;
    private Double confidence;
    private String fakeLikelihood;
    private Boolean descriptionMatchesImage;
    private Boolean needsAdminReview;
    private String explanation;
}
