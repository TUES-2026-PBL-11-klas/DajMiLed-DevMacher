package com.elsys.server.controller;

import com.elsys.server.base.BaseControllerTest;
import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.RegisterRequest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Transactional
class AuthControllerTest extends BaseControllerTest {

    private static final String REGISTER = "/api/auth/register";
    private static final String LOGIN    = "/api/auth/login";

    private String json(Object obj) throws Exception {
        return objectMapper.writeValueAsString(obj);
    }

    // --- register ---

    @Test
    void register_validRequest_returns201WithToken() throws Exception {
        var req = new RegisterRequest("new@test.com", "John", "Doe", "password123");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.user.email").value("new@test.com"))
                .andExpect(jsonPath("$.user.firstName").value("John"));
    }

    @Test
    void register_invalidEmail_returns400WithFieldError() throws Exception {
        var req = new RegisterRequest("not-an-email", "John", "Doe", "password123");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors.email").isNotEmpty());
    }

    @Test
    void register_shortPassword_returns400WithFieldError() throws Exception {
        var req = new RegisterRequest("john@test.com", "John", "Doe", "short");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors.password").isNotEmpty());
    }

    @Test
    void register_blankFirstName_returns400WithFieldError() throws Exception {
        var req = new RegisterRequest("john@test.com", "", "Doe", "password123");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors.firstName").isNotEmpty());
    }

    @Test
    void register_duplicateEmail_returns409() throws Exception {
        var req = new RegisterRequest("dup@test.com", "John", "Doe", "password123");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated());

        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409));
    }

    @Test
    void register_malformedJson_returns400() throws Exception {
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{ bad json }"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Malformed or missing request body"));
    }

    @Test
    void register_wrongHttpMethod_returns405() throws Exception {
        mockMvc.perform(get(REGISTER))
                .andExpect(status().isMethodNotAllowed())
                .andExpect(jsonPath("$.status").value(405));
    }

    // --- login ---

    @Test
    void login_validCredentials_returns200WithToken() throws Exception {
        var reg = new RegisterRequest("login@test.com", "John", "Doe", "password123");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(reg)))
                .andExpect(status().isCreated());

        var login = new LoginRequest("login@test.com", "password123");
        mockMvc.perform(post(LOGIN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(login)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isNotEmpty())
                .andExpect(jsonPath("$.user.email").value("login@test.com"));
    }

    @Test
    void login_wrongPassword_returns401() throws Exception {
        var reg = new RegisterRequest("pw@test.com", "John", "Doe", "password123");
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(reg)))
                .andExpect(status().isCreated());

        var login = new LoginRequest("pw@test.com", "wrongpassword");
        mockMvc.perform(post(LOGIN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(login)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    void login_nonExistentUser_returns401() throws Exception {
        var login = new LoginRequest("ghost@test.com", "password123");
        mockMvc.perform(post(LOGIN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(login)))
                .andExpect(status().isUnauthorized());
    }

    // --- protected endpoints ---

    @Test
    void anyProtectedEndpoint_noToken_returns401() throws Exception {
        mockMvc.perform(get("/api/protected"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401))
                .andExpect(jsonPath("$.message").value("Authentication required"));
    }
}
