package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateReportStatusRequestDto {

    private ReportStatus newStatus;
    private String notes;

}
