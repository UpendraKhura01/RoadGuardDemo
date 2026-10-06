package com.roadguard.roadGuard_backend.entity;

import com.roadguard.roadGuard_backend.entity.types.AuthProvider;
import com.roadguard.roadGuard_backend.entity.types.Roles;
import jakarta.persistence.*;

import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@Entity
@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "App_User")
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String password;


    private String gmail;

    @Column(unique = true, nullable = false)
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AuthProvider authProvider;

    @Enumerated(EnumType.STRING)
    private Roles roles;

    @JoinColumn(nullable = false)
    private Boolean isVerified = false;

    @Column(nullable = false)
    @Builder.Default
    private Long reputationScore = 0L;

    // Location fields
    private Double longitude;
    private Double latitude;
    private String road;
    private String ward;
    private String block;
    private String district;
    private String state;
    private String pinCode;
    private String fullAddress;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority("ROLE_" + (roles != null ? roles.name() : "CITIZEN"));
        return List.of(authority);
    }

    @Override
    public String getUsername() {
        return phoneNumber;
    }
}
