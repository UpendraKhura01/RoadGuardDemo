package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Service.HazardReportService;
import com.roadguard.roadGuard_backend.dto.CitizenHazardReportResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/public")
@RequiredArgsConstructor
public class PublicHazardReportController {

    private final HazardReportService hazardReportService;

    @GetMapping("/reports")
    public ResponseEntity<List<CitizenHazardReportResponseDto>> getPublicReports(
            @RequestParam(required = false, defaultValue = "0.0") Double lat,
            @RequestParam(required = false, defaultValue = "0.0") Double lng,
            @RequestParam(required = false, defaultValue = "50000.0") Double radiusKm) {
        List<CitizenHazardReportResponseDto> reports = hazardReportService.getPublicReports(lat, lng, radiusKm);
        return ResponseEntity.ok(reports);
    }
}
