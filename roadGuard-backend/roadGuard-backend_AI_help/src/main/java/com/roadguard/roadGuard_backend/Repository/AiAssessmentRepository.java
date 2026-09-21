package com.roadguard.roadGuard_backend.Repository;

import com.roadguard.roadGuard_backend.entity.AiAssessment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AiAssessmentRepository extends JpaRepository<AiAssessment, Long> {
    Optional<AiAssessment> findByHazardReportId(Long id);
}