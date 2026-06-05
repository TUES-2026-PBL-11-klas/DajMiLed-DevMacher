package com.elsys.server.dto.response;

public record ApplicationDto(
        Long id,
        Long taskId,
        Long applicantId,
        String status
) {}
