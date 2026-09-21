package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Repository.HazardReportRepository;
import com.roadguard.roadGuard_backend.Security.AuthUtil;
import com.roadguard.roadGuard_backend.Service.HazardReportService;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.HazardReportResponseDto;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/citizen/report")
@RequiredArgsConstructor
public class HazardReportController {
    private final HazardReportService hazardReportService;
    private final AuthUtil authUtil;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper = new com.fasterxml.jackson.databind.ObjectMapper()
            .configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

    @PostMapping(path = "/create", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<HazardReportResponseDto> createReport(
            Authentication authentication,
            @RequestPart("data") String dataJson,
            @RequestPart("photo") MultipartFile photo){
        if(photo == null || photo.isEmpty()){
            throw new IllegalArgumentException("Photo is mandatory:");
        }
        CreateHazardRequestDto request;
        try {
            request = objectMapper.readValue(dataJson, CreateHazardRequestDto.class);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid data format: " + e.getMessage(), e);
        }
        User user = authUtil.getAuthenticatedUser(authentication);
        Long userId = user.getId();
        HazardReportResponseDto response = hazardReportService.createReport(userId, request, photo);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/getReportById")
    public ResponseEntity<HazardReportResponseDto> getReportById(@RequestParam Long id){
        HazardReportResponseDto response = hazardReportService.getReportById(id);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/myReports")
    public ResponseEntity<List<HazardReportResponseDto>> getMyReports(Authentication authentication){
        List<HazardReportResponseDto> response = hazardReportService.getMyReports(authentication);

        return ResponseEntity.ok(response);
    }

    public ResponseEntity<List<HazardReportResponseDto>> getVerifiedReports(Authentication authentication){
        List<HazardReportResponseDto> verifiedReports = hazardReportService.getVerifiedReports(authentication);
        return ResponseEntity.ok(verifiedReports);
    }

}
