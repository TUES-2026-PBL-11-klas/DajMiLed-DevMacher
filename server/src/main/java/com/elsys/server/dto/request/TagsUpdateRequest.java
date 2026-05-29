package com.elsys.server.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record TagsUpdateRequest(

        @NotNull(message = "ownTags is required")
        @Size(max = 20, message = "Cannot have more than 20 own tags")
        List<@jakarta.validation.constraints.NotBlank(message = "Tag name cannot be blank")
             @Size(max = 50, message = "Tag name cannot exceed 50 characters") String> ownTags,

        @NotNull(message = "searchingForTags is required")
        @Size(max = 20, message = "Cannot have more than 20 searching-for tags")
        List<@jakarta.validation.constraints.NotBlank(message = "Tag name cannot be blank")
             @Size(max = 50, message = "Tag name cannot exceed 50 characters") String> searchingForTags
) {}
