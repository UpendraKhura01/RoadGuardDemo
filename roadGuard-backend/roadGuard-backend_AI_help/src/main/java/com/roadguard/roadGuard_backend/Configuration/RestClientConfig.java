package com.roadguard.roadGuard_backend.Configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.web.client.RestClient;

@Configuration
public class RestClientConfig {

    @Value("${roadguard.geocoding.baseUrl}")
    private String baseUrl;

    @Bean
    public RestClient restClient(){
        return RestClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader(HttpHeaders.USER_AGENT, "RoadGuard/1.0")
                .build();
    }
}
