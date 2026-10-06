package com.roadguard.roadGuard_backend.Configuration;

import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.AuthProvider;
import com.roadguard.roadGuard_backend.entity.types.Roles;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@RequiredArgsConstructor
@Component
public class adminSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;

    @org.springframework.beans.factory.annotation.Value("${admin.phone:9999999999}")
    private String adminPhone;
    @org.springframework.beans.factory.annotation.Value("${admin.password:admin123}")
    private String adminPassword;
    
    // Super admin credentials commented out for now
    // @org.springframework.beans.factory.annotation.Value("${superadmin.phone:#{null}}")
    // private String superAdminPhone;
    // @org.springframework.beans.factory.annotation.Value("${superadmin.password:#{null}}")
    // private String superAdminPassword;

    @Override
    public void run(String... args) {
        // Drop the old PostgreSQL CHECK constraint that restricts roles to just CITIZEN, AUTHORITY, ADMIN
        try {
            jdbcTemplate.execute("ALTER TABLE app_user DROP CONSTRAINT IF EXISTS app_user_roles_check");
        } catch (Exception e) {
            System.out.println("Could not drop constraint (might not exist): " + e.getMessage());
        }
        if (userRepository.findByPhoneNumber(adminPhone).isEmpty()) {
            User admin = User.builder()
                    .name("Local Admin")
                    .phoneNumber(adminPhone)
                    .password(passwordEncoder.encode(adminPassword))
                    .authProvider(AuthProvider.PHONE)
                    .roles(Roles.ADMIN)
                    .isVerified(true)
                    .reputationScore(100L)
                    .build();
            userRepository.save(admin);
            System.out.println(">>> ADMIN ACCOUNT INITIALIZED <<<");
        }

        // Only create Super Admin if the credentials were provided securely via Environment Variables
        /*
        if (superAdminPhone != null && superAdminPassword != null && userRepository.findByPhoneNumber(superAdminPhone).isEmpty()) {
            User superAdmin = User.builder()
                    .name("Super Admin")
                    .phoneNumber(superAdminPhone)
                    .password(passwordEncoder.encode(superAdminPassword))
                    .authProvider(AuthProvider.PHONE)
                    .roles(Roles.SUPER_ADMIN)
                    .isVerified(true)
                    .reputationScore(999L)
                    .build();
            userRepository.save(superAdmin);
            System.out.println(">>> SUPER ADMIN ACCOUNT INITIALIZED <<<");
        }
        */
    }
}
