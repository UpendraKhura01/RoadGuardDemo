package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CitizenHazardReportResponseDto {

    private Long reportId;
    private String description;
    private HazardCategory reportedCategory;
    private ReportStatus reportStatus;
    private Double longitude;
    private Double latitude;
    private LocalDateTime createdAt;
    private String address;
    private String city;
    private String ward;
    private String imageUrl;
}
