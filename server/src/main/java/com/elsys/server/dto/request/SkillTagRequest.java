package com.elsys.server.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record SkillTagRequest(
        @NotBlank(message = "Skill name is required")
        @Size(max = 50, message = "Skill name cannot exceed 50 characters")
        String name
) {}
