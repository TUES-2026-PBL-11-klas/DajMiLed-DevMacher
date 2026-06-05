package com.elsys.server.dto.response;

import java.util.List;

public record MatchedTaskDto(
        Long taskId,
        Long projectId,
        String projectTitle,
        String ownerName,
        String title,
        String description,
        List<SkillTagDto> requiredSkills
) {}
