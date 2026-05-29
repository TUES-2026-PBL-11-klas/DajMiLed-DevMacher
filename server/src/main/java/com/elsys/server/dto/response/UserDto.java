package com.elsys.server.dto.response;

import java.util.List;

public record UserDto(
        Long id,
        String email,
        String firstName,
        String lastName,
        List<TagDto> tags
) {}
