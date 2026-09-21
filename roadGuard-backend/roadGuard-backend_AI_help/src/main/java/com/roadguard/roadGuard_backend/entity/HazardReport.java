package com.roadguard.roadGuard_backend.entity;

import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Entity
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class HazardReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @OneToOne
    @JoinColumn(nullable = false)
    private ReportImage reportImage;

    private String description;

    @Enumerated(EnumType.STRING)
    private HazardCategory reportedCategory;

    @Enumerated(EnumType.STRING)
    private HazardCategory finalCategory;

    @Enumerated(EnumType.STRING)
    private Severity aiSeverity;

    @Enumerated(EnumType.STRING)
    private Severity finalSeverity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReportStatus reportStatus = ReportStatus.SUBMITTED;

    private Integer priorityScore;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    private Double latitude;

    private Double gpsAccuracyMeters;


    private String address;
    private String city;
    private String ward;

    @OneToOne(fetch = FetchType.LAZY)
    private ReportSecurityCheck reportSecurityCheck;

    @OneToOne(fetch = FetchType.LAZY)
    private AiAssessment aiAssessment;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "contractor_id")
    private Contractor contractor;

    private LocalDateTime createdAt;
    private LocalDateTime  updatedAt;
    private LocalDateTime resolvedAt;

    @PrePersist
    protected void onCreate(){
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;

        if(reportStatus == null){
            reportStatus = ReportStatus.SUBMITTED;
        }
        if(priorityScore == null){
            priorityScore = 0;
        }
    }
    @PreUpdate
    protected void onUpdate(){
        updatedAt = LocalDateTime.now();
    }


    protected void onResolve(){
        resolvedAt = LocalDateTime.now();
    }
}
