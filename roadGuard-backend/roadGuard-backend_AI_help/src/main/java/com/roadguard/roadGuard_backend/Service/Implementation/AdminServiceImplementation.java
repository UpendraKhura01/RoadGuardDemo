package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.Repository.AdminReviewRepository;
import com.roadguard.roadGuard_backend.Repository.HazardReportRepository;
import com.roadguard.roadGuard_backend.Repository.StatusHistoryRepository;
import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.Service.AdminService;
import com.roadguard.roadGuard_backend.Service.NotificationService;
import com.roadguard.roadGuard_backend.dto.AdminReviewRequestDto;
import com.roadguard.roadGuard_backend.dto.AdminReviewResponseDto;
import com.roadguard.roadGuard_backend.dto.UpdateReportStatusRequestDto;
import com.roadguard.roadGuard_backend.entity.AdminReview;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.StatusHistory;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.NotificationType;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import com.roadguard.roadGuard_backend.entity.types.ReviewDecision;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AdminServiceImplementation implements AdminService {
    private final AdminReviewRepository adminReviewRepository;
    private final HazardReportRepository hazardReportRepository;
    private final StatusHistoryRepository statusHistoryRepository;
    private final NotificationService notificationService;
    private final ModelMapper modelMapper;
    private final UserRepository userRepository;

    @Transactional
    @Override
    public AdminReviewResponseDto reviewReport(Long reportId, AdminReviewRequestDto request, Authentication authentication) {

        HazardReport report = hazardReportRepository.findById(reportId).orElseThrow(() -> new RuntimeException("Report not found"));
        User admin = (User) authentication.getPrincipal();

        AdminReview review = adminReviewRepository.findByHazardReportId(reportId).orElseGet(AdminReview::new);
        ReportStatus oldStatus = report.getReportStatus();
        ReportStatus newStatus = statusFromDecision(request.getFinalDecision());
        review = AdminReview.builder()
                .hazardReport(report)
                .reviewedBy(admin)
                .finalDecision(request.getFinalDecision())
                .finalSeverity(request.getFinalSeverity())
                .finalCategory(request.getFinalCategory())
                .comment(request.getComment())
                .reviewedAt(LocalDateTime.now())
                .build();

        report.setReportStatus(newStatus);
        report.setFinalCategory(request.getFinalCategory());
        report.setFinalSeverity(request.getFinalSeverity());
        hazardReportRepository.save(report);

        AdminReview savedReview = adminReviewRepository.save(review);

        createStatusHistory(admin, report,oldStatus, newStatus, request.getComment());
        notificationService.createNotification(admin,
                "Report Status Updated",
                "The status of your report has been updated to " + newStatus,
                NotificationType.REPORT_STATUS_UPDATED);

        return modelMapper.map(review, AdminReviewResponseDto.class);
    }

    @Override
    @Transactional
    public void updateReport(Long adminId, Long reportId, UpdateReportStatusRequestDto updates) {
        HazardReport report = hazardReportRepository.findById(reportId).orElseThrow(() ->
                new RuntimeException("Report doesn't exist with that id" + reportId));

        User admin = userRepository.findById(adminId).orElseThrow(() ->
                new RuntimeException("Admin doesn't exist with that id" + adminId));

        ReportStatus oldStatus = report.getReportStatus();
        report.setReportStatus(updates.getNewStatus());
        hazardReportRepository.save(report);

        createStatusHistory(admin, report, oldStatus, updates.getNewStatus(), updates.getNotes());
        notificationService.createNotification(admin,
                "Report Status Updated",
                "The status of your report has been updated to " + updates.getNewStatus(),
                NotificationType.REPORT_STATUS_UPDATED);
    }

    @Transactional
    private void createStatusHistory(User admin,
                                     HazardReport report,
                                     ReportStatus oldStatus,
                                     ReportStatus newStatus,
                                     String comment) {
        StatusHistory statusHistory = StatusHistory.builder()
                .hazardReport(report)
                .lastStatus(oldStatus)
                .newStatus(newStatus)
                .notes(comment)
                .changedBy(admin)
                .build();
        statusHistoryRepository.save(statusHistory);
    }

    ReportStatus statusFromDecision(ReviewDecision decision) {
        return switch (decision) {
            case APPROVE -> ReportStatus.VERIFIED;
            case REJECT -> ReportStatus.REJECTED;
            case NEED_MORE_INFO -> ReportStatus.PENDING_REVIEW;
            case MARK_DUPLICATE -> ReportStatus.DUPLICATE;
        };
    }
}
