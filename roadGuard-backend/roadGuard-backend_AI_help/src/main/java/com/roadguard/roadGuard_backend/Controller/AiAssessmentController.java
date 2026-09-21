package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Service.AIServices.AiAssessmentService;
import com.roadguard.roadGuard_backend.dto.AiAssessmentResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/AiAssessment")
@RequiredArgsConstructor
public class AiAssessmentController {
    private final AiAssessmentService aiAssessmentService;

    @GetMapping("/getAiAssessment")
    public ResponseEntity<AiAssessmentResponseDto> getAiAssessment(@RequestParam Long reportId) {
        return ResponseEntity.ok(aiAssessmentService.getAiAssessment(reportId));
    }
}
