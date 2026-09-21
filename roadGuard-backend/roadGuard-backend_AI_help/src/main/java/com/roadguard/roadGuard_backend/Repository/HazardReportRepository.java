package com.roadguard.roadGuard_backend.Repository;

import com.roadguard.roadGuard_backend.entity.HazardReport;
import com.roadguard.roadGuard_backend.entity.User;
import com.roadguard.roadGuard_backend.entity.types.ReportStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HazardReportRepository extends JpaRepository<HazardReport, Long> {
    List<HazardReport> findByUser(User user);

    List<HazardReport> findByReportStatus(ReportStatus reportStatus);

    List<HazardReport> findByReportStatusNotIn(List<ReportStatus> statuses);
}