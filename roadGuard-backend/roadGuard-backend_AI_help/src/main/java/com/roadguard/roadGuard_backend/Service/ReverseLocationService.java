package com.roadguard.roadGuard_backend.Service;

import com.roadguard.roadGuard_backend.dto.LocationDetailsDto;
import com.roadguard.roadGuard_backend.dto.ResolveLocationDto;

public interface ReverseLocationService {
    LocationDetailsDto resolveLocation(ResolveLocationDto request);
}
