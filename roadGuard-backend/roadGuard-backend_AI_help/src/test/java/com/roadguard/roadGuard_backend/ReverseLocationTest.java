package com.roadguard.roadGuard_backend;

import com.roadguard.roadGuard_backend.Service.ReverseLocationService;
import com.roadguard.roadGuard_backend.dto.LocationDetailsDto;
import com.roadguard.roadGuard_backend.dto.ResolveLocationDto;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
public class ReverseLocationTest {

    @Autowired
    private ReverseLocationService reverseLocationService;

    @Test
    void resolveLocationTest() {
        ResolveLocationDto request = ResolveLocationDto.builder()
                .longitude(82.9153)
                .latitude(18.7419)
                .build();
        LocationDetailsDto result = reverseLocationService.resolveLocation(request);
        System.out.println(result);
    }

}
