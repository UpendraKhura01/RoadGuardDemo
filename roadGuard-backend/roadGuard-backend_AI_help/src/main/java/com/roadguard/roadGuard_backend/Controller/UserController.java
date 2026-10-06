package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Service.UserService;
import com.roadguard.roadGuard_backend.dto.ApiMessageResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/User")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/update_location")
    public ResponseEntity<ApiMessageResponseDto> updateLocation(Authentication authentication,
                                                                @RequestParam Double longitude,
                                                                @RequestParam Double latitude) {
        userService.updateLocation(authentication, longitude, latitude);
        return ResponseEntity.ok(new ApiMessageResponseDto("Location has been updated"));
    }

    @GetMapping("/me")
    public ResponseEntity<com.roadguard.roadGuard_backend.dto.UserProfileDto> getProfile(Authentication authentication) {
        return ResponseEntity.ok(userService.getUserProfile(authentication));
    }
}
