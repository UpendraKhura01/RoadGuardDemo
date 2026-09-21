package com.roadguard.roadGuard_backend.Repository;

import com.roadguard.roadGuard_backend.entity.Contractor;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ContractorRepository extends JpaRepository<Contractor, Long> {
}
