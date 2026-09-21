package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.Repository.HazardReportRepository;
import com.roadguard.roadGuard_backend.Repository.ReportImageRepository;
import com.roadguard.roadGuard_backend.Repository.ReportSecurityCheckRepository;
import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.Security.AuthUtil;
import com.roadguard.roadGuard_backend.Service.*;
import com.roadguard.roadGuard_backend.Service.AIServices.AiAssessmentService;
import com.roadguard.roadGuard_backend.dto.CitizenHazardReportResponseDto;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.HazardReportResponseDto;
import com.roadguard.roadGuard_backend.dto.LocationDetailsDto;
import com.roadguard.roadGuard_backend.entity.*;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.ImageSource;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HazardReportServiceImplementation implements HazardReportService {

    private final ImageStoringService imageStoringService;
    private final ReportSecurityCheckService reportSecurityCheckService;
    private final UserRepository userRepository;
    private final ReverseLocationService reverseLocationService;
    private final HazardReportRepository hazardReportRepository;
    private final ReportImageRepository reportImageRepository;
    private final ReportSecurityCheckRepository reportSecurityCheckRepository;
    private final AiAssessmentService aiAssessmentService;
    private final HazardReportUtil hazardReportUtil;
    private final NotificationService notificationService;
    private final ModelMapper modelMapper;
    private final AuthUtil authUtil;

    @Transactional
    public HazardReportResponseDto createReport(Long userid,
                                                CreateHazardRequestDto request,
                                                MultipartFile photo){
        User user = userRepository.findById(userid)
                .orElseThrow(() -> new IllegalArgumentException("User not found with user id :" + userid));

        ReportStatus initialStatus = reportSecurityCheckService.decideInitialStatus(request);
        LocationDetailsDto locationsDetailsDto = reverseLocationService.resolveLocation(request);

        String imageUrl = imageStoringService.storeReportImage(photo);
        ReportImage image = ReportImage.builder()
                .url(imageUrl)
                .imageSource(ImageSource.CAMERA)
                .contentType(photo.getContentType())
                .fileSize(photo.getSize())
                .build();
        ReportImage savedImage = reportImageRepository.save(image);

        HazardReport hazardReport = HazardReport.builder()
                .reportStatus(initialStatus)
                .reportImage(savedImage)
                .description(request.getDescription())
                .user(user)
                .priorityScore(CalculateInitialScore(request.getReportedCategory(), initialStatus))
                .reportedCategory(request.getReportedCategory())
                .address(locationsDetailsDto.getAddress())
                .ward(locationsDetailsDto.getWard())
                .city(locationsDetailsDto.getCity())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .createdAt(request.getCapturedAt())
                .gpsAccuracyMeters(request.getGpsAccuracy())
                .build();

        HazardReport savedReport = hazardReportRepository.save(hazardReport);

        ReportSecurityCheck reportSecurityCheck = reportSecurityCheckService.buildSecurityCheck(savedReport, request);
        reportSecurityCheckRepository.save(reportSecurityCheck);
        savedReport.setReportSecurityCheck(reportSecurityCheck);

        ReportStatus beforeAi = savedReport.getReportStatus();

        AiAssessment aiAssessment = aiAssessmentService.assessReport(savedReport, request, photo);

        savedReport.setAiAssessment(aiAssessment);
        hazardReportUtil.updateReportWithAiAssessment(savedReport, aiAssessment);

        savedReport.setPriorityScore(aiAssessment.getAiPriorityScore());

        // update report with AiAssessment report, and it is in transactional context so it is atomic
        savedReport = hazardReportRepository.save(savedReport);
        if(beforeAi != aiAssessment.getHazardReport().getReportStatus()){
            hazardReportUtil.CreateHazardRequestHistory(savedReport,
                    beforeAi,
                    aiAssessment.getHazardReport().getReportStatus(),
                    user, aiAssessment.getExplanation());
        }
        notificationService.CreateReportSubmittedNotification(user, savedReport);

        HazardReportResponseDto responseDto = modelMapper.map(savedReport, HazardReportResponseDto.class);
        responseDto.setImageUrl(imageUrl);

        return responseDto;
    }

    @Override
    public HazardReportResponseDto getReportById(Long id) {
        HazardReport report = hazardReportRepository.findById(id).orElse(null);
        if(report == null){
            throw new IllegalArgumentException("No report found with id " + id);
        }
        HazardReportResponseDto response = modelMapper.map(report, HazardReportResponseDto.class);
        if (report.getReportImage() != null) {
            response.setImageUrl(report.getReportImage().getUrl());
        }
        return response;
    }

    @Override
    public List<HazardReportResponseDto> getMyReports(Authentication authentication) {
        User user = authUtil.getAuthenticatedUser(authentication);
        List<HazardReport> reports = hazardReportRepository.findByUser(user);

        return reports.stream()
                .map(report -> {
                    HazardReportResponseDto dto = modelMapper.map(report, HazardReportResponseDto.class);
                    if (report.getReportImage() != null) {
                        dto.setImageUrl(report.getReportImage().getUrl());
                    }
                    return dto;
                })
                .toList();
    }

    @Override
    public List<HazardReportResponseDto> getVerifiedReports(Authentication authentication) {
        List<HazardReport> reports = hazardReportRepository.findByReportStatus(ReportStatus.VERIFIED);
        return reports.stream()
                .map(report -> {
                    HazardReportResponseDto dto = modelMapper.map(report, HazardReportResponseDto.class);
                    if (report.getReportImage() != null) {
                        dto.setImageUrl(report.getReportImage().getUrl());
                    }
                    return dto;
                })
                .toList();
    }

    @Override
    public List<HazardReportResponseDto> getReportsByStatus(ReportStatus status) {
        List<HazardReport> reports = hazardReportRepository.findByReportStatus(status);
        return reports.stream()
                .map(report -> {
                    HazardReportResponseDto dto = modelMapper.map(report, HazardReportResponseDto.class);
                    if (report.getReportImage() != null) {
                        dto.setImageUrl(report.getReportImage().getUrl());
                    }
                    return dto;
                })
                .toList();
    }

    @Override
    public List<HazardReportResponseDto> getAllActiveReports() {
        List<ReportStatus> excluded = List.of(ReportStatus.REJECTED, ReportStatus.AI_REJECTED, ReportStatus.RESOLVED);
        List<HazardReport> reports = hazardReportRepository.findByReportStatusNotIn(excluded);
        return reports.stream()
                .map(report -> {
                    HazardReportResponseDto dto = modelMapper.map(report, HazardReportResponseDto.class);
                    if (report.getReportImage() != null) {
                        dto.setImageUrl(report.getReportImage().getUrl());
                    }
                    return dto;
                })
                .toList();
    }

    @Override
    public List<CitizenHazardReportResponseDto> getPublicReports(Double lat, Double lng, Double radiusKm) {
        List<HazardReport> allReports = hazardReportRepository.findAll();

        return allReports.stream()
                .filter(report -> report.getReportStatus() != null
                        && report.getReportStatus() != ReportStatus.REJECTED
                        && report.getReportStatus() != ReportStatus.AI_REJECTED)
                .filter(report -> isWithinRadius(report.getLatitude(), report.getLongitude(), lat, lng, radiusKm))
                .map(report -> CitizenHazardReportResponseDto.builder()
                        .reportId(report.getId())
                        .description(report.getDescription())
                        .reportedCategory(report.getReportedCategory())
                        .reportStatus(report.getReportStatus())
                        .longitude(report.getLongitude())
                        .latitude(report.getLatitude())
                        .createdAt(report.getCreatedAt())
                        .address(report.getAddress())
                        .city(report.getCity())
                        .ward(report.getWard())
                        .imageUrl(report.getReportImage() != null ? report.getReportImage().getUrl() : null)
                        .build())
                .collect(Collectors.toList());
    }

    private boolean isWithinRadius(Double reportLat, Double reportLng, Double centerLat, Double centerLng, Double radiusKm) {
        if (reportLat == null || reportLng == null || centerLat == null || centerLng == null || radiusKm == null) {
            return false;
        }

        double earthRadius = 6371;
        double dLat = Math.toRadians(centerLat - reportLat);
        double dLng = Math.toRadians(centerLng - reportLng);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                   Math.cos(Math.toRadians(reportLat)) * Math.cos(Math.toRadians(centerLat)) *
                   Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = earthRadius * c;

        return distance <= radiusKm;
    }

    private Integer CalculateInitialScore(HazardCategory reportedCategory, ReportStatus initialStatus) {
        if(initialStatus == ReportStatus.REJECTED || initialStatus == ReportStatus.AI_REJECTED || reportedCategory == null){
            return 0;
        }
        return switch (reportedCategory){
            case OPEN_MANHOLE -> 90;
            case BROKEN_TRAFFIC_SIGNAL -> 80;
            case FALLEN_TREE -> 75;
            case WATERLOGGING -> 65;
            case POTHOLE, DAMAGED_ROAD -> 60;
            case BROKEN_STREETLIGHT -> 40;
            case OTHER -> 30;
            case UNRELATED -> 0;
        };
    }
}
