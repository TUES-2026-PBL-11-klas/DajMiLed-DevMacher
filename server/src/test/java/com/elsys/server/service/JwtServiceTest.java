package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;

import static org.assertj.core.api.Assertions.*;

class JwtServiceTest extends BaseUnitTest {

    private static final String SECRET = "test-secret-key-that-is-long-enough-for-hmac-sha256-algorithm";

    private JwtService jwtService;
    private UserDetails userDetails;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "secret", SECRET);
        ReflectionTestUtils.setField(jwtService, "expirationMs", 3600000L);
        userDetails = new User("john@test.com", "password", List.of());
    }

    @Test
    void generateToken_extractUsername_matches() {
        String token = jwtService.generateToken(userDetails);
        assertThat(jwtService.extractUsername(token)).isEqualTo("john@test.com");
    }

    @Test
    void isTokenValid_validToken_returnsTrue() {
        String token = jwtService.generateToken(userDetails);
        assertThat(jwtService.isTokenValid(token, userDetails)).isTrue();
    }

    @Test
    void isTokenValid_wrongUser_returnsFalse() {
        String token = jwtService.generateToken(userDetails);
        UserDetails other = new User("other@test.com", "password", List.of());
        assertThat(jwtService.isTokenValid(token, other)).isFalse();
    }

    @Test
    void isTokenValid_expiredToken_returnsFalse() {
        ReflectionTestUtils.setField(jwtService, "expirationMs", -1000L);
        String token = jwtService.generateToken(userDetails);
        assertThat(jwtService.isTokenValid(token, userDetails)).isFalse();
    }

    @Test
    void isTokenValid_tamperedToken_returnsFalse() {
        String token = jwtService.generateToken(userDetails) + "tampered";
        assertThat(jwtService.isTokenValid(token, userDetails)).isFalse();
    }
}
