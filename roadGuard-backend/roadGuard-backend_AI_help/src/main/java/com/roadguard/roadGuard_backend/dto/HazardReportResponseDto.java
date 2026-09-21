package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
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
public class HazardReportResponseDto {

    private Long reportId;
    private Long userId;
    private String userName;

    private String description;
    private HazardCategory reportedCategory;
    private HazardCategory finalCategory;


    private Severity aiSeverity;
    private Severity finalSeverity;

    private ReportStatus reportStatus;

    private Double longitude;
    private Double latitude;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String address;
    private String city;
    private String ward;

    private String imageUrl;

    private String decisionReason;
    private String aiExplanation;

}
