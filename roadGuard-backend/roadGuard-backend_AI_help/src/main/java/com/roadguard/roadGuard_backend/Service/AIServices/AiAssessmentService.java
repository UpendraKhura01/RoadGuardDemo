package com.roadguard.roadGuard_backend.Service.AIServices;

import com.roadguard.roadGuard_backend.dto.AiAssessmentResponseDto;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.entity.AiAssessment;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import org.springframework.web.multipart.MultipartFile;

public interface AiAssessmentService {

    public AiAssessment assessReport(HazardReport report, CreateHazardRequestDto request, MultipartFile photo);
    public AiAssessmentResponseDto getAiAssessment(Long reportId);
}
