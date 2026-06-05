package com.elsys.server.dto.response;

import java.time.LocalDateTime;
import java.util.List;

public record ProjectDto(
        Long id,
        UserSummaryDto owner,
        String title,
        String description,
        LocalDateTime createdAt,
        List<ProjectTaskDto> tasks,
        List<SkillTagDto> skills
) {}
