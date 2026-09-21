package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.Repository.OtpRepository;
import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.Service.OtpService;
import com.roadguard.roadGuard_backend.dto.OtpResponse;
import com.roadguard.roadGuard_backend.entity.Otp;
import com.roadguard.roadGuard_backend.entity.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class OtpServiceImplementation implements OtpService {

    public static final int OTP_EXPIRATION_MINUTES = 5;
    private final OtpRepository otpRepository;
    private final SecureRandom secureRandom = new SecureRandom();
    private final UserRepository userRepository;


    @Override
    public OtpResponse sendOtp(String phoneNumber) {
        verifyNumber(phoneNumber);
        String otp = generateOtp(phoneNumber);
        OtpResponse otpResponse = new OtpResponse();
        otpResponse.setMessage("Your Otp is " + otp);
        return otpResponse;
    }

    @Override
    public String generateOtp(String number) {
        verifyNumber(number);
        String otp = String.format("%06d", secureRandom.nextInt(1000000));

        otpRepository.deleteByPhoneNumber(number);
        Otp newOtpRecord = Otp.builder()
                .otp(otp)
                .phoneNumber(number)
                .expiresAt(LocalDateTime.now().plusMinutes(OTP_EXPIRATION_MINUTES))
                .build();

        otpRepository.save(newOtpRecord);
        return otp;
    }

    private void verifyNumber(String number) {
        if(number ==  null || number.isBlank() || number.length() < 10){
            throw new IllegalArgumentException("Provider Valid Phone number :" + number);
        }
    }

    @Override
    @Transactional
    public void verifyOtp(String otp, String number) {
        Otp otpRecord = otpRepository.findByPhoneNumber(number).orElse(null);
        if(otpRecord == null){
            throw new IllegalArgumentException("Please click get Otp");
        }
        if(otpRecord.getExpiresAt().isBefore(LocalDateTime.now())){
            throw new IllegalArgumentException("Otp has expired:");
        }

        if(!otpRecord.getOtp().equals(otp)){
            throw new BadCredentialsException("Otp is invalid");
        }

        otpRepository.delete(otpRecord);
    }
}
