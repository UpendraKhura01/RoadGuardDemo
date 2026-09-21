package com.roadguard.roadGuard_backend.Repository;

import com.roadguard.roadGuard_backend.entity.StatusHistory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StatusHistoryRepository extends JpaRepository<StatusHistory, Long> {
}