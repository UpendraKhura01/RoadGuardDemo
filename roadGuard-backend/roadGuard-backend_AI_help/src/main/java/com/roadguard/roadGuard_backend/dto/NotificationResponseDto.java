package com.roadguard.roadGuard_backend.dto;

import com.roadguard.roadGuard_backend.entity.types.NotificationType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class NotificationResponseDto {

    private Long reportId;

    private String title;
    private String message;
    private NotificationType notificationType;

    private LocalDateTime createdAt;
    private Boolean isRead;
}
