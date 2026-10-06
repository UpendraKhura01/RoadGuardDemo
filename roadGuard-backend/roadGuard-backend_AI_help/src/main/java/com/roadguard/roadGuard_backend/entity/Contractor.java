package com.roadguard.roadGuard_backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "contractor")
@NoArgsConstructor
@AllArgsConstructor
@Data
@Builder
public class Contractor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(name = "phone_number", nullable = false)
    private String phoneNumber;

    private String email;

    private String specialization;

    private String area;
}
