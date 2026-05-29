package com.elsys.server.service;

import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.RegisterRequest;
import com.elsys.server.dto.response.AuthResponse;
import com.elsys.server.entity.User;
import com.elsys.server.exception.EmailAlreadyExistsException;
import com.elsys.server.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserService userService;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new EmailAlreadyExistsException(request.email());
        }

        User user = User.builder()
                .email(request.email())
                .firstName(request.firstName())
                .lastName(request.lastName())
                .password(passwordEncoder.encode(request.password()))
                .tags(userService.buildInitialTags(request.ownTags(), request.searchingForTags()))
                .build();

        userRepository.save(user);
        return toAuthResponse(jwtService.generateToken(user), user);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found: " + request.email()));

        return toAuthResponse(jwtService.generateToken(user), user);
    }

    private AuthResponse toAuthResponse(String token, User user) {
        return new AuthResponse(token, "Bearer", jwtService.getExpirationMs(), userService.toDto(user));
    }
}
