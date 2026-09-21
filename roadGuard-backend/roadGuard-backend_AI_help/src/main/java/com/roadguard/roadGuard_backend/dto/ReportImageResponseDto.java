package com.roadguard.roadGuard_backend.dto;


import com.roadguard.roadGuard_backend.entity.types.ImageSource;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReportImageResponseDto {
    //uploaded image info

    private Long id;
    private Long reportId;

    private String imageUrl;
    private ImageSource imageSource;

    private Long fileSize;
    private String contentType;

    private Integer height;
    private Integer width;

    private LocalDateTime uploadedAt;
}
