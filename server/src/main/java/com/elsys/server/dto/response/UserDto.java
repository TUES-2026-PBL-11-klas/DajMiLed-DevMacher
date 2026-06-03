package com.elsys.server.dto.response;

import java.util.List;

public record UserDto(
        Long id,
        String email,
        String firstName,
        String lastName,
        String username,
        String discordTag,
        String githubLink,
        String bio,
        String education,
        List<TagDto> tags,
        List<SkillTagDto> skills
) {}
