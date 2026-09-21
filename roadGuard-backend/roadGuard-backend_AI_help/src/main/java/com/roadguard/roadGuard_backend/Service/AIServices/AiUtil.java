package com.roadguard.roadGuard_backend.Service.AIServices;

import com.roadguard.roadGuard_backend.dto.AiAssessmentResponseDto;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.DirectAiResponseDto;
import com.roadguard.roadGuard_backend.dto.HazardAiAnalysisDto;
import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Component
@RequiredArgsConstructor
public class AiUtil {

    private final List<AiProvider> providers;

    @Value("${roadguard.ai.provider}")
    private String aiProvider;

    @Value("${roadguard.ai.fallbackEnabled}")
    private boolean fallbackEnabled;

    public AiProvider findProvider(String providerName) {
        return providers.stream()
                .filter(provider -> provider.supports(providerName))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Provider not found"));
    }

    public DirectAiResponseDto AiAssessReportWithProvider(CreateHazardRequestDto request, MultipartFile photo) {
        AiProvider provider = findProvider(aiProvider);

        if(provider.isConfigured()){
            try {
                return dataStandardizing(provider.analyzeRoadHazard(photo, request), provider.providerName());
            } catch (Exception e) {
                System.err.println("AI Provider " + aiProvider + " failed: " + e.getMessage() + ". Falling back to mock.");
            }
        }
        if (fallbackEnabled){
            AiProvider fallbackProvider = findProvider("mock");
            DirectAiResponseDto fallback = dataStandardizing(fallbackProvider.analyzeRoadHazard(photo, request),
                    fallbackProvider.providerName());
            fallback.setRawResponse("Main AI provider " + aiProvider + " is not working so Using Mock provider:");

            return fallback;
        }
        throw new IllegalStateException("Ai provider " + aiProvider + " is not working");
    }

    public DirectAiResponseDto dataStandardizing(DirectAiResponseDto aiResponse, String aiProvider){
        // Handling Raw data from AI response and making Sure no Irregularities is present in data
        // Multiple Ai return different data structure, this method standardize and unifies the data
        //It is just a security layer to prevent any irregularities

        if (aiResponse == null){
            throw new IllegalStateException("Ai Error : AI response is Empty:");
        }
        if(aiResponse.getProvider() == null || aiResponse.getProvider().isBlank()){
            aiResponse.setProvider(aiProvider);
        }
        if (aiResponse.getHazardCategory() == null){
            aiResponse.setHazardCategory(HazardCategory.OTHER);
        }
        if(aiResponse.getValidHazard() == null){
            aiResponse.setValidHazard(aiResponse.getHazardCategory() != HazardCategory.UNRELATED);
        }
        if(aiResponse.getAiConfidence() == null){
            aiResponse.setAiConfidence(0.0);
        }

        if(aiResponse.getIsRoadImage() == null){
            aiResponse.setIsRoadImage(aiResponse.getHazardCategory() != HazardCategory.UNRELATED);
        }
        if (aiResponse.getDescriptionMatchesImage() == null){
            aiResponse.setDescriptionMatchesImage(true);
        }
        if(aiResponse.getNeedsAdminReview() == null){
            aiResponse.setNeedsAdminReview(aiResponse.getAiConfidence() < 8.0);
        }
        if (aiResponse.getSeverity() == null){
            aiResponse.setSeverity(Severity.MEDIUM);
        }

        if(aiResponse.getAiPriorityScore() == null){
            aiResponse.setAiPriorityScore(defaultAiPriorityScore(aiResponse.getSeverity(), aiResponse.getHazardCategory()));
        }
        if (aiResponse.getFakeLikelihood() == null){
            aiResponse.setFakeLikelihood(Boolean.TRUE.equals(aiResponse.getValidHazard()) ? FakeLikeliHood.LOW : FakeLikeliHood.HIGH);
        }
        if (aiResponse.getExplanation() == null || aiResponse.getExplanation().isBlank()){
            aiResponse.setExplanation("Ai Assessment Completed");
        }
        return aiResponse;
    }

    private Integer defaultAiPriorityScore(Severity severity, HazardCategory category) {
        if(category == HazardCategory.UNRELATED){
            return 0;
        }
        if(severity == null){
            return 40;
        }
        return switch (severity){
            case LOW -> 40;
            case MEDIUM -> 60;
            case HIGH -> 80;
            case CRITICAL -> 90;

        };
    }

}
