package com.roadguard.roadGuard_backend.Service.AIServices;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.roadguard.roadGuard_backend.dto.CreateHazardRequestDto;
import com.roadguard.roadGuard_backend.dto.DirectAiResponseDto;
import com.roadguard.roadGuard_backend.dto.GeminiResponseDto;
import com.roadguard.roadGuard_backend.entity.types.FakeLikeliHood;
import com.roadguard.roadGuard_backend.entity.types.HazardCategory;
import com.roadguard.roadGuard_backend.entity.types.Severity;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
public class GeminiAIProvider implements AiProvider {

    @Value("${roadguard.ai.gemini.model-id}")
    private String modelId;

    @Value("${roadguard.ai.gemini.api-key}")
    private String apiKey;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private WebClient webClient;

    @Value("${roadguard.ai.gemini.api-key}")
    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
        this.webClient = WebClient.builder()
                .baseUrl("https://generativelanguage.googleapis.com/v1beta/models")
                .build();
    }

    @Override
    public String providerName() {
        return "gemini";
    }

    @Override
    public boolean supports(String provider) {
        return "gemini".equalsIgnoreCase(provider);
    }

    @Override
    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank()
                && !apiKey.equals("your-gemini-api-key");
    }

    @Override
    public DirectAiResponseDto analyzeRoadHazard(MultipartFile photo, CreateHazardRequestDto request) {
        try {
            byte[] imageBytes = photo.getBytes();
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);

            Map<String, Object> requestBody = buildRequestBody(base64Image, request);

            String response = webClient.post()
                    .uri(uriBuilder -> uriBuilder
                            .path("/{modelId}:generateContent")
                            .queryParam("key", apiKey)
                            .build(modelId))
                    .contentType(MediaType.APPLICATION_JSON)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            return parseGeminiResponse(response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to process image for Gemini API: " + e.getMessage(), e);
        }
    }

    private Map<String, Object> buildRequestBody(String base64Image, CreateHazardRequestDto request) {
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("contents", buildContents(base64Image, request));
        requestBody.put("generationConfig", buildGenerationConfig());
        return requestBody;
    }

    private Object[] buildContents(String base64Image, CreateHazardRequestDto request) {
        Map<String, Object> textPart = new HashMap<>();
        textPart.put("text", buildPrompt(request));

        Map<String, Object> inlineData = new HashMap<>();
        inlineData.put("mime_type", "image/jpeg");
        inlineData.put("data", base64Image);

        Map<String, Object> imagePart = new HashMap<>();
        imagePart.put("inline_data", inlineData);

        Map<String, Object> content = new HashMap<>();
        content.put("parts", new Object[]{textPart, imagePart});

        return new Object[]{content};
    }

    private Map<String, Object> buildGenerationConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("temperature", 0.4);
        config.put("topK", 32);
        config.put("topP", 0.95);
        config.put("maxOutputTokens", 8192);
        config.put("response_mime_type", "application/json");
        return config;
    }

    private String buildPrompt(CreateHazardRequestDto request) {
        return new StringBuilder()
                .append("Analyze this road hazard image and provide a detailed assessment. ")
                .append("Return the response in JSON format with these fields:\n")
                .append("{\n")
                .append("  \"hazardCategory\": \"POTHOLE|BROKEN_TRAFFIC_SIGNAL|FALLEN_TREE|WATERLOGGING|OPEN_MANHOLE|BROKEN_STREETLIGHT|OTHER|UNRELATED\",\n")
                .append("  \"severity\": \"LOW|MEDIUM|HIGH|CRITICAL\",\n")
                .append("  \"isRoadImage\": true/false,\n")
                .append("  \"validHazard\": true/false,\n")
                .append("  \"confidence\": 0.0-10.0,\n")
                .append("  \"fakeLikelihood\": \"LOW|MEDIUM|HIGH\",\n")
                .append("  \"descriptionMatchesImage\": true/false,\n")
                .append("  \"needsAdminReview\": true/false,\n")
                .append("  \"explanation\": \"detailed explanation\"\n")
                .append("}\n")
                .append(request.getDescription() != null ? "\nUser description: " + request.getDescription() : "")
                .append("\nLocation: Lat=").append(request.getLatitude())
                .append(", Lon=").append(request.getLongitude())
                .toString();
    }

    private DirectAiResponseDto parseGeminiResponse(String response) {
        try {
            JsonNode root = objectMapper.readTree(response);
            String rawResponse = root.path("candidates")
                    .get(0)
                    .path("content")
                    .path("parts")
                    .get(0)
                    .path("text")
                    .asText();

            String jsonContent = extractJson(rawResponse);
            GeminiResponseDto geminiResponse = objectMapper.readValue(jsonContent, GeminiResponseDto.class);

            return DirectAiResponseDto.builder()
                    .provider("gemini")
                    .rawResponse(rawResponse)
                    .hazardCategory(mapToHazardCategory(geminiResponse.getHazardCategory()))
                    .severity(mapToSeverity(geminiResponse.getSeverity()))
                    .isRoadImage(geminiResponse.getIsRoadImage() != null ? geminiResponse.getIsRoadImage() : true)
                    .validHazard(geminiResponse.getValidHazard() != null ? geminiResponse.getValidHazard() : true)
                    .aiConfidence(geminiResponse.getConfidence() != null ? geminiResponse.getConfidence() : 7.0)
                    .fakeLikelihood(mapToFakeLikelihood(geminiResponse.getFakeLikelihood()))
                    .descriptionMatchesImage(geminiResponse.getDescriptionMatchesImage() != null ? geminiResponse.getDescriptionMatchesImage() : true)
                    .needsAdminReview(geminiResponse.getNeedsAdminReview() != null ? geminiResponse.getNeedsAdminReview() : false)
                    .explanation(geminiResponse.getExplanation() != null ? geminiResponse.getExplanation() : "Gemini AI assessment completed")
                    .build();

        } catch (Exception e) {
            throw new RuntimeException("Failed to parse Gemini response", e);
        }
    }

    private String extractJson(String response) {
        int jsonStart = response.indexOf("{");
        int jsonEnd = response.lastIndexOf("}");
        if (jsonStart >= 0 && jsonEnd > jsonStart) {
            return response.substring(jsonStart, jsonEnd + 1);
        }
        return response;
    }

    private HazardCategory mapToHazardCategory(String category) {
        if (category == null) return HazardCategory.OTHER;
        try {
            return HazardCategory.valueOf(category.toUpperCase());
        } catch (IllegalArgumentException e) {
            return HazardCategory.OTHER;
        }
    }

    private Severity mapToSeverity(String severity) {
        if (severity == null) return Severity.MEDIUM;
        try {
            return Severity.valueOf(severity.toUpperCase());
        } catch (IllegalArgumentException e) {
            return Severity.MEDIUM;
        }
    }

    private FakeLikeliHood mapToFakeLikelihood(String fakeLikelihood) {
        if (fakeLikelihood == null) return FakeLikeliHood.LOW;
        try {
            return FakeLikeliHood.valueOf(fakeLikelihood.toUpperCase());
        } catch (IllegalArgumentException e) {
            return FakeLikeliHood.LOW;
        }
    }
}
