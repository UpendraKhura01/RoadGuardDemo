package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.Repository.UserRepository;
import com.roadguard.roadGuard_backend.Service.ReverseLocationService;
import com.roadguard.roadGuard_backend.Service.UserService;
import com.roadguard.roadGuard_backend.dto.LocationDetailsDto;
import com.roadguard.roadGuard_backend.dto.ResolveLocationDto;
import com.roadguard.roadGuard_backend.entity.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImplementation implements UserService {

    private final UserRepository userRepository;
    private final ReverseLocationService reverseLocationService;
    private final ModelMapper modelMapper;

    @Override
    @Transactional
    public void updateLocation(Authentication authentication, Double longitude, Double latitude) {
        User user = (User) authentication.getPrincipal();

        user.setLongitude(longitude);
        user.setLatitude(latitude);

        ResolveLocationDto req = ResolveLocationDto.builder()
                .longitude(longitude)
                .latitude(latitude)
                .build();

        LocationDetailsDto locationDetails = reverseLocationService.resolveLocation(req);

        // Explicitly set all fields — ModelMapper misses state/district due to naming differences
        user.setRoad(locationDetails.getRoad());
        user.setWard(locationDetails.getWard());
        user.setBlock(locationDetails.getBlock());
        user.setDistrict(locationDetails.getDistrict());
        user.setState(locationDetails.getState());
        user.setPinCode(locationDetails.getPinCode());
        user.setFullAddress(locationDetails.getFullAddress());
        userRepository.save(user);
    }

    @Override
    public com.roadguard.roadGuard_backend.dto.UserProfileDto getUserProfile(Authentication authentication) {
        User user = (User) authentication.getPrincipal();
        return modelMapper.map(user, com.roadguard.roadGuard_backend.dto.UserProfileDto.class);
    }

    @Override
    public java.util.List<com.roadguard.roadGuard_backend.dto.UserProfileDto> getAllUsers() {
        return userRepository.findAll().stream()
                .map(user -> modelMapper.map(user, com.roadguard.roadGuard_backend.dto.UserProfileDto.class))
                .collect(java.util.stream.Collectors.toList());
    }
}
