package com.roadguard.roadGuard_backend.Service.AIServices;

import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.DirectAiResponseDto;
import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

@Component
public class MockAIProvider implements AiProvider{
    @Override
    public String providerName() {
        return "mock";
    }

    @Override
    public boolean supports(String provider) {
        return true;
    }

    @Override
    public boolean isConfigured() {
        return true;
    }

    @Override
    public DirectAiResponseDto analyzeRoadHazard(MultipartFile photo, CreateHazardRequestDto request) {
        return DirectAiResponseDto.builder()
                .provider("mock")
                .hazardCategory(request.getReportedCategory())
                .validHazard(true)
                .aiConfidence(9.0)
                .isRoadImage(true)
                .descriptionMatchesImage(true)
                .needsAdminReview(false)
                .severity(Severity.HIGH)
                .aiPriorityScore(70)
                .fakeLikelihood(FakeLikeliHood.LOW)
                .explanation("Dummy explanation")
                .rawResponse("Test data")
                .build();
    }
}
