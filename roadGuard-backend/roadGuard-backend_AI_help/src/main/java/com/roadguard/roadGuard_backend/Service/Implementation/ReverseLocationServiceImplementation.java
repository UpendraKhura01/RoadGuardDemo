package com.roadguard.roadGuard_backend.Service.Implementation;

import com.roadguard.roadGuard_backend.Service.ReverseLocationService;
import com.roadguard.roadGuard_backend.dto.LocationDetailsDto;
import com.roadguard.roadGuard_backend.dto.LocationsDetailsRootDto;
import com.roadguard.roadGuard_backend.dto.ResolveLocationDto;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class ReverseLocationServiceImplementation implements ReverseLocationService {

    private final RestClient client;
    private final ModelMapper modelMapper;

    public LocationDetailsDto resolveLocation(ResolveLocationDto request) {
        Double longitude = request.getLongitude();
        Double latitude  = request.getLatitude();

        try {
            Map<String, Object> response = client.get()
                    .uri(uriBuilder -> uriBuilder.path("/reverse")
                            .queryParam("format", "jsonv2")
                            .queryParam("lat",  latitude)
                            .queryParam("lon",  longitude)
                            .build())
                    .retrieve()
                    .body(new ParameterizedTypeReference<Map<String, Object>>() {});

            if (response == null || !response.containsKey("address")) {
                throw new RuntimeException("Geocoding data is missing or incomplete in the response.");
            }

            // Raw address map from Nominatim
            Map<String, Object> address = (Map<String, Object>) response.get("address");
            String finalAddress = (String) response.get("display_name");

            // ModelMapper maps simple matching fields (village, county, state, road, postcode, country)
            LocationsDetailsRootDto rootDto = modelMapper.map(address, LocationsDetailsRootDto.class);

            // ward  -> "village" in Nominatim
            String ward  = rootDto.getVillage();

            // block -> "county" in Nominatim (city-level)
            String block = rootDto.getCounty();

            // district -> "state_district" in Nominatim (handled directly from raw map, not in DTO)
            String district = (String) address.getOrDefault("state_district", block);

            // state -> "state" in Nominatim (mapped directly by ModelMapper)
            String state = rootDto.getState();

            return LocationDetailsDto.builder()
                    .road(rootDto.getRoad())
                    .ward(ward)
                    .block(block)
                    .district(district)
                    .state(state)
                    .country(rootDto.getCountry())
                    .pinCode(rootDto.getPostcode())
                    .fullAddress(finalAddress)
                    .build();

        } catch (Exception e) {
            throw new RuntimeException("Error in getting location data:" + e);
        }
    }
}
