package com.roadguard.roadGuard_backend.Service;

import com.roadguard.roadGuard_backend.dto.AdminReviewRequestDto;
import com.roadguard.roadGuard_backend.dto.AdminReviewResponseDto;
import com.roadguard.roadGuard_backend.dto.UpdateReportStatusRequestDto;
import com.roadguard.roadGuard_backend.entity.User;
import org.springframework.security.core.Authentication;

public interface AdminService {

    AdminReviewResponseDto reviewReport(Long reportId, AdminReviewRequestDto adminReviewRequestDto, Authentication authentication);

    void updateReport(Long adminID, Long reportId, UpdateReportStatusRequestDto updates);
}
