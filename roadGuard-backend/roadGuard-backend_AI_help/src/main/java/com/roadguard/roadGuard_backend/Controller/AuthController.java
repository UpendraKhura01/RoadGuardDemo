package com.roadguard.roadGuard_backend.Controller;

import com.roadguard.roadGuard_backend.Security.AuthService;
import com.roadguard.roadGuard_backend.Service.OtpService;
import com.roadguard.roadGuard_backend.dto.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    private final OtpService otpService;

    @PostMapping("/sendOtp")
    public ResponseEntity<OtpResponse> sendOtp(@RequestBody OtpRequestDto requestDto) {
        OtpResponse otpResponse = otpService.sendOtp(requestDto.getPhoneNumber());
        return ResponseEntity.ok(otpResponse);
    }
    @PostMapping("/signup/phoneNumber")
    public ResponseEntity<SignupResponseDto> signupPhoneNumber(@RequestBody SignupRequestDto request){
        SignupResponseDto signupResponseDto = authService.signupPhoneNumber(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(signupResponseDto);
    }

    @PostMapping("/login/phoneNumber")
    public ResponseEntity<LoginResponseDto> otpLogin(@RequestBody OtpLoginRequestDto request){
        LoginResponseDto response = authService.loginPhoneNumber(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login/password")
    public ResponseEntity<LoginResponseDto> passwordLogin(@RequestBody passwordLoginRequestDto request){
        LoginResponseDto response = authService.passwordLogin(request);
        return ResponseEntity.ok(response);
    }
}
