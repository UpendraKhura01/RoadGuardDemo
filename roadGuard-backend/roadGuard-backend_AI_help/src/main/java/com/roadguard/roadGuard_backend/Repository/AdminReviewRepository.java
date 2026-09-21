package com.roadguard.roadGuard_backend.Repository;

import com.roadguard.roadGuard_backend.entity.AdminReview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminReviewRepository extends JpaRepository<AdminReview, Long> {
    Optional<AdminReview> findByHazardReportId(Long reportId);
}