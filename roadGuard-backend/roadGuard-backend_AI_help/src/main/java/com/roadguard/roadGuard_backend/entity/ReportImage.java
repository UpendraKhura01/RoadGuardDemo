package com.roadguard.roadGuard_backend.entity;

import com.roadguard.roadGuard_backend.entity.types.ImageSource;
import jakarta.persistence.*;
import lombok.*;


import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReportImage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @OneToOne(mappedBy = "reportImage")
    @JoinColumn(nullable = false)
    private HazardReport hazardReport;

    @Column(nullable = false)
    private String url;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ImageSource imageSource;

    private String contentType;

    private Long fileSize;
    private Integer height;
    private Integer width;

    private LocalDateTime uploadedAt;
}
