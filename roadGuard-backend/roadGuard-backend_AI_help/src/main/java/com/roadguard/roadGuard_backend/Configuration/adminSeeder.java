package com.roadguard.roadGuard_backend.Configuration;

import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.AuthProvider;
import com.roadguard.roadGuard_backend.entity.types.Roles;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@RequiredArgsConstructor
@Component
public class adminSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    @Override
    public void run(String... args) {
        String adminPhone = "9999999999";
        if (userRepository.findByPhoneNumber(adminPhone).isEmpty()) {
            User admin = User.builder()
                    .name("System Admin")
                    .phoneNumber(adminPhone)
                    .password(passwordEncoder.encode("admin123"))
                    .authProvider(AuthProvider.PHONE)
                    .roles(Roles.ADMIN)
                    .isVerified(true)
                    .reputationScore(100L)
                    .build();
            userRepository.save(admin);
            System.out.println(">>> ADMIN ACCOUNT INITIALIZED SUCCESSFULLY <<<");
        }
    }
}
