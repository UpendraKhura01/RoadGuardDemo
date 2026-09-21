package com.roadguard.roadGuard_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationsDetailsRootDto {

    public String road;
    public String town;
    public String county;
    public String state_district;
    public String state;
    public String postcode;
    public String country;
    public String country_code;

}
