package com.elsys.server.dto.response;

import java.util.List;

public record ProjectTaskDto(
        Long id,
        String title,
        String description,
        List<SkillTagDto> requiredSkills
) {}
