package com.elsys.server.dto.request;

import com.elsys.server.entity.TagCategory;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record TagRequest(

        @NotBlank(message = "Tag name is required")
        @Size(max = 50, message = "Tag name cannot exceed 50 characters")
        String name,

        @NotNull(message = "Category is required (OWN or SEARCHING_FOR)")
        TagCategory category
) {}
