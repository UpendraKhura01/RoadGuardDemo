package com.roadguard.roadGuard_backend.Service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;

@Service

public class ImageStoringService {

    @Value("${roadguard.upload-dir:uploads/reports}")
    private final Path uploadPath;

    public ImageStoringService(@Value("${roadguard.upload-dir:uploads/reports}") String uploadDir) {
        this.uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
    }


    public String storeReportImage(MultipartFile photo){
        validatePhoto(photo);
        try {
            Files.createDirectories(uploadPath);

            String extension = getExtension(photo.getOriginalFilename());
            String fileName = UUID.randomUUID() + extension;
            Path destination = uploadPath.resolve(fileName).normalize();

                try (InputStream inputStream = photo.getInputStream()){
                    Files.copy(inputStream, destination, StandardCopyOption.REPLACE_EXISTING);
                }

            return "/uploads/reports/" + fileName;
        }
        catch (IOException exception){
            throw new RuntimeException("Couldn't Store uploaded image", exception);
        }
    }

    private void validatePhoto(MultipartFile photo) {

        if(photo == null || photo.isEmpty()){
            throw new IllegalArgumentException("Photo is empty");
        }
        String contentType = photo.getContentType();

        if(contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")){
            throw new IllegalArgumentException("photo type is invalid");
        }
    }

    private String getExtension(String originalFileName) {
        String cleanName = StringUtils.cleanPath(originalFileName == null ? "" : originalFileName);
        int dotIndex = cleanName.lastIndexOf(".");

        if (dotIndex == -1) {
            return ".jpg";
        }

        return cleanName.substring(dotIndex).toLowerCase(Locale.ROOT);
    }

}
