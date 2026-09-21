package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ReviewDecision;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data

public class AdminReviewRequestDto { //Admin reviews a complaint

    private HazardCategory finalCategory;

    private Severity finalSeverity;

    private ReviewDecision finalDecision;

    private String comment;

}
