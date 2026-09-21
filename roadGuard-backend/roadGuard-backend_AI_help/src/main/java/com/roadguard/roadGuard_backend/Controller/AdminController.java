package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Repository.ContractorRepository;
import com.roadguard.roadGuard_backend.Repository.HazardReportRepository;
import com.roadguard.roadGuard_backend.Service.AdminService;
import com.roadguard.roadGuard_backend.Service.HazardReportService;
import com.roadguard.roadGuard_backend.dto.*;
import com.roadguard.roadGuard_backend.entity.Contractor;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;
    private final HazardReportService hazardReportService;
    private final ContractorRepository contractorRepository;
    private final HazardReportRepository hazardReportRepository;

    @GetMapping("/reports")
    public ResponseEntity<List<HazardReportResponseDto>> getReportsByStatus(@RequestParam ReportStatus status){
        List<HazardReportResponseDto> reports = hazardReportService.getReportsByStatus(status);
        return ResponseEntity.ok(reports);
    }

    @GetMapping("/reports/all")
    public ResponseEntity<List<HazardReportResponseDto>> getAllActiveReports(){
        List<HazardReportResponseDto> reports = hazardReportService.getAllActiveReports();
        return ResponseEntity.ok(reports);
    }

    @PostMapping("/reviewReport")
    public ResponseEntity<AdminReviewResponseDto> reviewReport(@RequestParam Long reportId,
                                                                   @RequestBody AdminReviewRequestDto adminReviewRequestDto,
                                                                   Authentication authentication){
        AdminReviewResponseDto response = adminService.reviewReport(reportId, adminReviewRequestDto, authentication);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/updateReportStatus")
    public ResponseEntity<ApiMessageResponseDto> updateReport(Authentication authentication,
                                                              @RequestParam Long reportId,
                                                              @RequestBody UpdateReportStatusRequestDto updates){
        User admin = (User) authentication.getPrincipal();
        Long adminId = admin.getId();
        adminService.updateReport(adminId, reportId, updates);

        return ResponseEntity.ok(new ApiMessageResponseDto("Report Status Updated"));
    }

    // ─── Contractors ─────────────────────────────────────────────────────────

    @GetMapping("/contractors")
    public ResponseEntity<List<ContractorDto>> getContractors() {
        List<ContractorDto> contractors = contractorRepository.findAll().stream()
                .map(c -> ContractorDto.builder()
                        .id(c.getId())
                        .name(c.getName())
                        .phoneNumber(c.getPhoneNumber())
                        .email(c.getEmail())
                        .specialization(c.getSpecialization())
                        .area(c.getArea())
                        .build())
                .toList();
        return ResponseEntity.ok(contractors);
    }

    @PostMapping("/contractors")
    public ResponseEntity<ContractorDto> createContractor(@RequestBody ContractorDto dto) {
        Contractor contractor = Contractor.builder()
                .name(dto.getName())
                .phoneNumber(dto.getPhoneNumber())
                .email(dto.getEmail())
                .specialization(dto.getSpecialization())
                .area(dto.getArea())
                .build();
        Contractor saved = contractorRepository.save(contractor);
        dto.setId(saved.getId());
        return ResponseEntity.ok(dto);
    }

    @PostMapping("/assignContractor")
    public ResponseEntity<ApiMessageResponseDto> assignContractor(@RequestBody AssignContractorRequestDto request) {
        HazardReport report = hazardReportRepository.findById(request.getReportId())
                .orElseThrow(() -> new IllegalArgumentException("Report not found: " + request.getReportId()));
        Contractor contractor = contractorRepository.findById(request.getContractorId())
                .orElseThrow(() -> new IllegalArgumentException("Contractor not found: " + request.getContractorId()));

        report.setContractor(contractor);
        // If report is VERIFIED or PENDING_REVIEW, move to ASSIGNED
        if (report.getReportStatus() == ReportStatus.VERIFIED
                || report.getReportStatus() == ReportStatus.PENDING_REVIEW
                || report.getReportStatus() == ReportStatus.SUBMITTED) {
            report.setReportStatus(ReportStatus.ASSIGNED);
        }
        hazardReportRepository.save(report);
        return ResponseEntity.ok(new ApiMessageResponseDto("Contractor assigned successfully"));
    }
}
