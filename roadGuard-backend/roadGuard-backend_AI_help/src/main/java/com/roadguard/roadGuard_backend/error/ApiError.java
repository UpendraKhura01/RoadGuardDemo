package com.roadguard.roadGuard_backend.error;

import lombok.Data;
import org.springframework.http.HttpStatus;

import java.time.LocalDate;

@Data
public class ApiError {
    private LocalDate timeStamp;
    private String exception;
    private HttpStatus httpStatusCode;

    public ApiError() {
        this.timeStamp = LocalDate.now();
    }

    public ApiError(String exception, HttpStatus httpStatusCode) {
        this();
        this.exception = exception;
        this.httpStatusCode = httpStatusCode;
    }
}
