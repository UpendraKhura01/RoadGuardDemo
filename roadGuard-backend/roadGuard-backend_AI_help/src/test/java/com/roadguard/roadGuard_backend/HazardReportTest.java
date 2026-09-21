package com.roadguard.roadGuard_backend;


import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.Service.HazardReportService;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.HazardReportResponseDto;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.AuthProvider;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Roles;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.mock.web.MockMultipartFile;


import java.time.LocalDateTime;

@SpringBootTest
public class HazardReportTest {

    @Autowired
    private HazardReportService hazardReportService;

    @Autowired
    private UserRepository userRepository;

    @Test
    @Transactional
    public void testCreateHazardReport() {
        CreateHazardRequestDto request;
        request = CreateHazardRequestDto.builder()
                .description("A big pot hole test")
                .ward("Dmj test")
                .city("Dmj Test")
                .address("Bhejaput city, Dmj")
                .reportedCategory(HazardCategory.POTHOLE)
                .cameraOnly(true)
                .fakeLocation(false)
                .capturedAt(LocalDateTime.of(2026, 9, 10, 21, 27))
                .latitude(18.750)
                .longitude(82.913)
                .gpsAccuracy(10.0)
                .vpnDetected(false)
                .build();

        User user = User.builder()
                .name("Upendra")
                .gmail("demo@gmail.com")
                .phoneNumber("7684081234")
                .isVerified(true)
                .roles(Roles.CITIZEN)
                .reputationScore(100L)
                .authProvider(AuthProvider.EMAIL)
                .build();
        userRepository.save(user);

        MockMultipartFile photo = new MockMultipartFile(
                "testPhoto",
                "test.txt",
                "image/jpeg",
                "image content".getBytes());

        HazardReportResponseDto response = hazardReportService.createReport(user.getId(), request, photo);
        System.out.println(response);
    }
}
