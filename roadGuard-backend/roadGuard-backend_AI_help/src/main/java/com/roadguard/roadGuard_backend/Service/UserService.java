package com.roadguard.roadGuard_backend.Service;

import org.springframework.security.core.Authentication;

public interface UserService {
    void updateLocation(Authentication authentication, Double longitude, Double latitude);

    com.roadguard.roadGuard_backend.dto.UserProfileDto getUserProfile(Authentication authentication);
    java.util.List<com.roadguard.roadGuard_backend.dto.UserProfileDto> getAllUsers();
}
