package com.elsys.server.dto.response;

public record UserDto(
        Long id,
        String email,
        String firstName,
        String lastName
) {}
