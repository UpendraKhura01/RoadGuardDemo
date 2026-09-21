package com.roadguard.roadGuard_backend.entity;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ReviewDecision;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;


@Entity
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AdminReview {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "hazard_id")
    private HazardReport hazardReport;

    @ManyToOne
    private User reviewedBy;
    /**
     *   Here user refers to the admin
     *   One admin can have multiple review reports
     *   So it is not user but admin
     *   admin = user + role
     */

    @Enumerated(EnumType.STRING)
    private ReviewDecision finalDecision;

    @Enumerated(EnumType.STRING)
    private Severity finalSeverity;

    @Enumerated(EnumType.STRING)
    private HazardCategory finalCategory;

    private String comment;

    private LocalDateTime reviewedAt;

}
