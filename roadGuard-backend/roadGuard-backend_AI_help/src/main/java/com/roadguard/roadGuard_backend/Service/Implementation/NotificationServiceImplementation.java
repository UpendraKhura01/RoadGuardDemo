package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.Repository.NotificationRepository;
import com.roadguard.roadGuard_backend.Service.NotificationService;
import com.roadguard.roadGuard_backend.dto.NotificationResponseDto;
import com.roadguard.roadGuard_backend.entity.AiAssessment;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.Notification;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.NotificationType;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.Nullable;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.List;

import static com.roadguard.roadGuard_backend.entity.types.ReportStatus.*;

@Service
@RequiredArgsConstructor
public class NotificationServiceImplementation implements NotificationService {

    private final NotificationRepository notificationRepository;
    private final ModelMapper modelMapper;

    @Override
    public Notification createNotification(User user, String title, String message, NotificationType notificationType) {
        return notificationRepository.save(Notification.builder()
                .user(user)
                .title(title)
                .message(message)
                .notificationType(notificationType)
                .isRead(false)
                .build());
    }

    @Override
    public Notification CreateReportSubmittedNotification(User user, HazardReport report) {
        String title = switch (report.getReportStatus()){
            case REJECTED -> "Report Rejected";
            case AI_REJECTED -> "Report Rejected by AI";
            case PENDING_REVIEW -> "Report Sent for Review";
            default -> "Report Submitted";
        };

        String message = switch (report.getReportStatus()){
            case REJECTED -> "Report Rejected because it didn't pass through Security Tests";
            case AI_REJECTED -> {
                AiAssessment assessment = report.getAiAssessment();
                yield "Report Rejected by AI: " + (assessment != null ? assessment.getExplanation() : "AI Rejected this report");

            }
            case PENDING_REVIEW -> "Your Report has been sent for admin Review";
            default -> "Your report Has been submitted successfully";
        };
        NotificationType notificationType= (report.getReportStatus() == REJECTED) ? NotificationType.REPORT_REJECTED : NotificationType.REPORT_SUBMITTED;

        return createNotification(user, title, message, notificationType);
    }

    @Override
    public @Nullable List<NotificationResponseDto> getNotifications(Authentication authentication) {
        User user = (User) authentication.getPrincipal();
        List<Notification> notifications = notificationRepository.findByUser(user);
        return notifications.stream()
                .map(notification -> modelMapper.map(notification, NotificationResponseDto.class))
                .toList();
    }

    @Override
    public @Nullable NotificationResponseDto markAsRead(Authentication authentication, Long notificationId) {
        User user = (User) authentication.getPrincipal();
        Long userId = user.getId();
        Notification notification = notificationRepository.findById(notificationId).orElseThrow();
        if (!notification.getUser().getId().equals(userId)) {
            throw new IllegalArgumentException("Notification does not belong to this user.");
        }
        notification.setIsRead(true);
        return modelMapper.map(notification, NotificationResponseDto.class);
    }
}
