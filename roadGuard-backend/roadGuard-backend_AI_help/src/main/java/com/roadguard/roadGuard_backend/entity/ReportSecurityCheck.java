package com.roadguard.roadGuard_backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ReportSecurityCheck {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    private HazardReport hazardReport;

    private Boolean cameraOnly;
    private Boolean fakeLocation;
    private Boolean vpnDetected;

    private String decisionReason;
}
