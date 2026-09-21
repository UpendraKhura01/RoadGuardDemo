package com.roadguard.roadGuard_backend.entity;

import com.roadguard.roadGuard_backend.entity.types.NotificationType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**The user who receives the notification.**/
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /**Short message title**/
    private String title;

    private String message;

    /**For frontend to show different colour**/
    @Enumerated(EnumType.STRING)
    private NotificationType notificationType;

    @Column(nullable = false)
    private Boolean isRead;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}
