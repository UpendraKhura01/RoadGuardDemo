package com.roadguard.roadGuard_backend.Service.AIServices;

import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.HazardAiAnalysisDto;
import org.springframework.web.multipart.MultipartFile;
import com.roadguard.roadGuard_backend.dto.DirectAiResponseDto;

public interface AiProvider {

    String providerName();

    boolean supports(String provider);

    boolean isConfigured();

    DirectAiResponseDto analyzeRoadHazard(MultipartFile photo, CreateHazardRequestDto request);
}
