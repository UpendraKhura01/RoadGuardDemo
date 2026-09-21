package com.roadguard.roadGuard_backend.Service.AIServices;

import com.roadguard.roadGuard_backend.Repository.AiAssessmentRepository;
import com.roadguard.roadGuard_backend.dto.AiAssessmentResponseDto;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.DirectAiResponseDto;
import com.roadguard.roadGuard_backend.entity.AiAssessment;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


@Service
@RequiredArgsConstructor
public class AiAssessmentServiceImplementation implements  AiAssessmentService{

    private final AiUtil aiUtil;
    private final AiAssessmentRepository aiAssessmentRepository;
    private final ModelMapper modelMapper;

    @Override
    @Transactional
    public AiAssessment assessReport(HazardReport report, CreateHazardRequestDto request, MultipartFile photo) {

        DirectAiResponseDto response = aiUtil.AiAssessReportWithProvider(request, photo);
        AiAssessment assessment = aiAssessmentRepository.findByHazardReportId(report.getId())
                .orElseGet(AiAssessment::new);

        AiAssessment aiAssessment = AiAssessment.builder()
                .hazardReport(report)
                .provider(response.getProvider())
                .isRoadImage(response.getIsRoadImage())
                .hazardCategory(response.getHazardCategory())
                .validHazard(response.getValidHazard())
                .confidence(response.getAiConfidence())
                .severity(response.getSeverity())
                .aiPriorityScore(response.getAiPriorityScore())
                .descriptionMatchesImage(response.getDescriptionMatchesImage())
                .needsAdminReview(response.getNeedsAdminReview())
                .fakeLikelihood(response.getFakeLikelihood())
                .explanation(response.getExplanation())
                .rawResponse(response.getRawResponse())
                .build();

        return aiAssessmentRepository.save(aiAssessment);

    }

    @Override
    public AiAssessmentResponseDto getAiAssessment(Long reportId) {
        AiAssessment aiAssessment = aiAssessmentRepository.findByHazardReportId(reportId)
                .orElseThrow(() -> new IllegalArgumentException("AiAssessment not found"));

        AiAssessmentResponseDto responseDto = modelMapper.map(aiAssessment, AiAssessmentResponseDto.class);
        responseDto.setAssessmentId(aiAssessment.getId());
        responseDto.setReportId(aiAssessment.getHazardReport().getId());
        return responseDto;
    }

}
