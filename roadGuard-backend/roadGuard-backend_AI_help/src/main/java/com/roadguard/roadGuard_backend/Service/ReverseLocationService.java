package com.roadguard.roadGuard_backend.Service;

import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.LocationDetailsDto;
import com.roadguard.roadGuard_backend.dto.LocationsDetailsRootDto;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ReverseLocationService {

    private final RestClient client;
    private final ModelMapper modelMapper;

    public LocationDetailsDto resolveLocation(CreateHazardRequestDto request){

        Double longitude = request.getLongitude();
        Double latitude = request.getLatitude();

        LocationsDetailsRootDto locationsDetailsRootDto;

        try {
            Map<String, Object> response = client.get()
                    .uri(uriBuilder -> uriBuilder.path("/reverse")
                            .queryParam("format", "jsonv2")
                            .queryParam("lat", latitude)
                            .queryParam("lon", longitude)
                            .build()
                    )
                    .retrieve().body(new ParameterizedTypeReference<Map<String, Object>>() {
                    });


            if (response == null || !response.containsKey("address")) {
                throw new RuntimeException("Geocoding data is missing or incomplete in the response.");
            }
            Map<String, Object> address = (Map<String, Object>) response.get("address");

            locationsDetailsRootDto = modelMapper.map(address, LocationsDetailsRootDto.class);

            String finalAddress = Optional.ofNullable((String) response.get("display_name"))
                    .orElse(request.getAddress());

            // city -> check town first (since Nominatim returned "town" in your example), fallback to request info
            String finalCity = Optional.ofNullable(locationsDetailsRootDto.getTown())
                    .orElse(request.getCity());

            // ward -> check county (e.g., "Koraput Town"), fallback to road (e.g., "NH26"), then request info
            String finalWard = Optional.ofNullable(locationsDetailsRootDto.getCounty())
                    .or(() -> Optional.ofNullable(locationsDetailsRootDto.getRoad()))
                    .orElse(request.getWard());
            return new LocationDetailsDto(finalAddress, finalCity, finalWard);
        }
        catch (Exception e){
            throw new RuntimeException("Error in getting location data:" + e);
        }
    }

}
