package com.roadguard.roadGuard_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class LocationDetailsDto {
    private String address;
    private String city;
    private String ward;
}
