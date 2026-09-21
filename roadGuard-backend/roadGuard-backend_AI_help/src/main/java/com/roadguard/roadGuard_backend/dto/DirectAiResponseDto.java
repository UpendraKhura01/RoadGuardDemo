package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
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
public class DirectAiResponseDto {

    private String provider;

    private Integer aiPriorityScore; // between : 0 to 100
    private Severity severity;
    private Double aiConfidence;// between : 0 to 10

    private HazardCategory hazardCategory;

    private Boolean isRoadImage;
    private Boolean validHazard;
    private Boolean descriptionMatchesImage;
    private Boolean needsAdminReview;

    private FakeLikeliHood fakeLikelihood;
    private String explanation;
    private String rawResponse;
}
