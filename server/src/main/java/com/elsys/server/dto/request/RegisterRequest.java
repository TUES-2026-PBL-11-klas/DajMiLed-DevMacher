package com.elsys.server.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public record RegisterRequest(

        @NotBlank(message = "Email is required")
        @Email(message = "Email must be valid")
        String email,

        @NotBlank(message = "First name is required")
        @Size(min = 2, max = 50, message = "First name must be between 2 and 50 characters")
        String firstName,

        @NotBlank(message = "Last name is required")
        @Size(min = 2, max = 50, message = "Last name must be between 2 and 50 characters")
        String lastName,

        @NotBlank(message = "Password is required")
        @Size(min = 8, max = 100, message = "Password must be at least 8 characters")
        String password,

        @Size(max = 20, message = "Cannot have more than 20 own tags")
        List<@NotBlank(message = "Tag name cannot be blank")
             @Size(max = 50, message = "Tag name cannot exceed 50 characters") String> ownTags,

        @Size(max = 20, message = "Cannot have more than 20 searching-for tags")
        List<@NotBlank(message = "Tag name cannot be blank")
             @Size(max = 50, message = "Tag name cannot exceed 50 characters") String> searchingForTags
) {
    public RegisterRequest(String email, String firstName, String lastName, String password) {
        this(email, firstName, lastName, password, null, null);
    }
}
