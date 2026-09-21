package com.roadguard.roadGuard_backend.Service;

import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.ReportSecurityCheck;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import org.springframework.stereotype.Service;

@Service
public class ReportSecurityCheckService {

    public ReportSecurityCheck createSecurityCheck(HazardReport hazardReport,
                                                   CreateHazardRequestDto createHazardRequestDto){
        return ReportSecurityCheck.builder()
                .hazardReport(hazardReport)
                .cameraOnly(createHazardRequestDto.getCameraOnly())
                .fakeLocation(createHazardRequestDto.getFakeLocation())
                .vpnDetected(createHazardRequestDto.getVpnDetected())
                .decisionReason(buildDecisionRequest(createHazardRequestDto))
                .build();
    }

    public ReportStatus decideInitialStatus(CreateHazardRequestDto createHazardRequestDto) {

        if (createHazardRequestDto.getCameraOnly() != Boolean.TRUE) {
            return ReportStatus.REJECTED;

        } else if (createHazardRequestDto.getFakeLocation() == Boolean.TRUE) {
            return ReportStatus.REJECTED;

        } else if (createHazardRequestDto.getVpnDetected() == Boolean.TRUE) {
            return ReportStatus.PENDING_REVIEW;
        } else if (createHazardRequestDto.getGpsAccuracy() == null) {
            return ReportStatus.PENDING_REVIEW;
        }

        return ReportStatus.SUBMITTED;
    }
    private String buildDecisionRequest(CreateHazardRequestDto createHazardRequestDto) {
        if(createHazardRequestDto.getCameraOnly() != Boolean.TRUE){
            return "Report rejected because photo wasn't captured using Direct Camera Flow:";
        }
        if(createHazardRequestDto.getFakeLocation().equals(Boolean.TRUE)){
            return "Report rejected because fake/mock location was detected:";
        }
        if(createHazardRequestDto.getVpnDetected().equals(Boolean.TRUE)){
            return "Report rejected because Vpn detected";
        }
        if(createHazardRequestDto.getGpsAccuracy() > 500){
            return "Report rejected because gpsAccuracy is very poor";
        }

        return "Security checks passed";
    }

    public ReportSecurityCheck buildSecurityCheck(HazardReport hazardReport, CreateHazardRequestDto request) {
        return ReportSecurityCheck.builder()
                .hazardReport(hazardReport)
                .cameraOnly(Boolean.TRUE.equals(request.getCameraOnly()))
                .decisionReason(buildDecisionRequest(request))
                .fakeLocation(Boolean.TRUE.equals(request.getFakeLocation()))
                .vpnDetected(Boolean.TRUE.equals(request.getVpnDetected()))
                .build();
    }

    private Integer calculateRiskScore(CreateHazardRequestDto request){
        int riskScore = 0;
         final Integer MaxGpsAccuracy = 500;


        if(!Boolean.TRUE.equals(request.getCameraOnly())){
            riskScore += 40;
        }

        if(Boolean.TRUE.equals(request.getVpnDetected())){
            riskScore += 30;
        }

        if(Boolean.TRUE.equals(request.getFakeLocation())){
            riskScore += 30;
        }
        if(request.getGpsAccuracy() == null){
            riskScore += 10;
        }else if(request.getGpsAccuracy() > MaxGpsAccuracy){
            riskScore += 20;
        }

        return riskScore;
    }
}
