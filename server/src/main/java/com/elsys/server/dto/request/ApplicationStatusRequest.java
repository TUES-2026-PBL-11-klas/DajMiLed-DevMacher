package com.elsys.server.dto.request;

import com.elsys.server.entity.ApplicationStatus;
import jakarta.validation.constraints.NotNull;

public record ApplicationStatusRequest(
        @NotNull(message = "Status is required")
        ApplicationStatus status
) {}
