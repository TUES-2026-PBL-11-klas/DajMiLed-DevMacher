package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.RegisterRequest;
import com.elsys.server.dto.response.AuthResponse;
import com.elsys.server.entity.User;
import com.elsys.server.exception.EmailAlreadyExistsException;
import com.elsys.server.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.*;

class AuthServiceTest extends BaseUnitTest {

    @Mock UserRepository userRepository;
    @Mock PasswordEncoder passwordEncoder;
    @Mock JwtService jwtService;
    @Mock AuthenticationManager authenticationManager;
    @InjectMocks AuthService authService;

    @Test
    void register_newEmail_returnsAuthResponse() {
        var req = new RegisterRequest("john@test.com", "John", "Doe", "password123");
        given(userRepository.existsByEmail(req.email())).willReturn(false);
        given(passwordEncoder.encode(req.password())).willReturn("hashed");
        given(userRepository.save(any(User.class))).willAnswer(inv -> inv.getArgument(0));
        given(jwtService.generateToken(any())).willReturn("token");
        given(jwtService.getExpirationMs()).willReturn(3600000L);

        AuthResponse response = authService.register(req);

        assertThat(response.token()).isEqualTo("token");
        assertThat(response.tokenType()).isEqualTo("Bearer");
        assertThat(response.user().email()).isEqualTo("john@test.com");
        assertThat(response.user().firstName()).isEqualTo("John");
    }

    @Test
    void register_existingEmail_throwsAndNeverSaves() {
        var req = new RegisterRequest("taken@test.com", "A", "B", "password123");
        given(userRepository.existsByEmail(req.email())).willReturn(true);

        assertThatThrownBy(() -> authService.register(req))
                .isInstanceOf(EmailAlreadyExistsException.class)
                .hasMessageContaining("taken@test.com");

        then(userRepository).should(never()).save(any());
    }

    @Test
    void login_validCredentials_returnsAuthResponse() {
        var req = new LoginRequest("john@test.com", "password123");
        User user = User.builder()
                .email("john@test.com").firstName("John").lastName("Doe")
                .password("hashed").build();
        given(userRepository.findByEmail(req.email())).willReturn(Optional.of(user));
        given(jwtService.generateToken(user)).willReturn("token");
        given(jwtService.getExpirationMs()).willReturn(3600000L);

        AuthResponse response = authService.login(req);

        assertThat(response.token()).isEqualTo("token");
        then(authenticationManager).should().authenticate(any(UsernamePasswordAuthenticationToken.class));
    }

    @Test
    void login_badCredentials_propagatesException() {
        var req = new LoginRequest("john@test.com", "wrongpassword");
        given(authenticationManager.authenticate(any()))
                .willThrow(new BadCredentialsException("bad credentials"));

        assertThatThrownBy(() -> authService.login(req))
                .isInstanceOf(BadCredentialsException.class);
    }
}
