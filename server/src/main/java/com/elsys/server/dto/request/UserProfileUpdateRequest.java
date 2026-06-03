package com.elsys.server.dto.request;

import jakarta.validation.constraints.Size;

public record UserProfileUpdateRequest(
        @Size(min = 3, max = 30, message = "Username must be between 3 and 30 characters")
        String username,

        @Size(max = 50, message = "Discord tag cannot exceed 50 characters")
        String discordTag,

        @Size(max = 200, message = "GitHub link cannot exceed 200 characters")
        String githubLink,

        @Size(max = 1000, message = "Bio cannot exceed 1000 characters")
        String bio,

        @Size(max = 200, message = "Education cannot exceed 200 characters")
        String education
) {}
