package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.entity.AiAssessment;
import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.StatusHistory;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import org.springframework.stereotype.Component;

@Component
public class HazardReportUtil {

    public void updateReportWithAiAssessment(HazardReport report, AiAssessment aiAssessment) {
        report.setAiSeverity(aiAssessment.getSeverity());
        report.setFinalCategory(aiAssessment.getHazardCategory());

        if(report.getFinalSeverity() == null){
            report.setFinalSeverity(aiAssessment.getSeverity());
        }
        if(report.getReportStatus() == ReportStatus.REJECTED){
            return;
        }
        FakeLikeliHood isFakeImage = aiAssessment.getFakeLikelihood();
        Boolean isValid = aiAssessment.getValidHazard();
        Boolean isRoad = aiAssessment.getIsRoadImage();

        if (isFakeImage == FakeLikeliHood.HIGH || Boolean.FALSE.equals(isValid) || Boolean.FALSE.equals(isRoad)) {
            report.setReportStatus(ReportStatus.AI_REJECTED);
            report.setPriorityScore(0);
        } else {
            report.setReportStatus(ReportStatus.PENDING_REVIEW);
        }
    }

    public void CreateHazardRequestHistory(HazardReport report,
                                            ReportStatus lastStatus,
                                            ReportStatus newStatus,
                                            User user,
                                            String explanation){
        StatusHistory statusHistory = StatusHistory.builder()
                .hazardReport(report)
                .lastStatus(lastStatus)
                .newStatus(newStatus)
                .changedBy(user)
                .notes(explanation)
                .build();
    }

}
