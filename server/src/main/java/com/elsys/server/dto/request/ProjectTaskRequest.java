package com.elsys.server.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ProjectTaskRequest(
        @NotBlank(message = "Title is required")
        @Size(max = 200, message = "Title cannot exceed 200 characters")
        String title,

        @Size(max = 5000, message = "Description cannot exceed 5000 characters")
        String description
) {}
