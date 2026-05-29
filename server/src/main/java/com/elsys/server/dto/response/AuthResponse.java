package com.elsys.server.dto.response;

public record AuthResponse(
        String token,
        String tokenType,
        long expiresIn,
        UserDto user
) {}
