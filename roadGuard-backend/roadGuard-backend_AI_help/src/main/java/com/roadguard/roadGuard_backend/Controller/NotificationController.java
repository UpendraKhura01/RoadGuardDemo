package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Service.NotificationService;
import com.roadguard.roadGuard_backend.dto.NotificationResponseDto;
import com.roadguard.roadGuard_backend.entity.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notification")
@RequiredArgsConstructor
public class NotificationController {
    private final NotificationService notificationService;

    @GetMapping("/getMyNotifications")
    public ResponseEntity<List<NotificationResponseDto>> getNotifications(Authentication authentication) {
        return ResponseEntity.ok(notificationService.getNotifications(authentication));
    }
    @PostMapping("/markAsRead")
    public ResponseEntity<NotificationResponseDto> markAsRead(Authentication authentication, @RequestParam Long notificationId) {
        return ResponseEntity.ok(notificationService.markAsRead(authentication, notificationId));
    }
}
