package com.roadguard.roadGuard_backend.entity;


import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
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
public class AiAssessment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String provider;

    @OneToOne
    @JoinColumn(name = "report_id", nullable = false)
    private HazardReport hazardReport;

    @Enumerated(EnumType.STRING)
    private HazardCategory hazardCategory;

    private Boolean validHazard;
    private Boolean isRoadImage;
    private Boolean descriptionMatchesImage;
    private Boolean needsAdminReview;
    private Double confidence;
    private Integer aiPriorityScore;

    private FakeLikeliHood fakeLikelihood;

    @Column(length = 2000)
    private String explanation;

    @Column(columnDefinition = "TEXT")
    private String rawResponse;

    @Enumerated(EnumType.STRING)
    private Severity severity;

    private LocalDateTime createdAt;

    @PrePersist
    private void onCreate(){
        createdAt = LocalDateTime.now();
    }
}
