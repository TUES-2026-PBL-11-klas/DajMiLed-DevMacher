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
class UserControllerTest extends BaseControllerTest {

    private static final String REGISTER = "/api/auth/register";
    private static final String LOGIN    = "/api/auth/login";
    private static final String ME       = "/api/users/me";

    private String json(Object obj) throws Exception {
        return objectMapper.writeValueAsString(obj);
    }

    private String getToken(String email) throws Exception {
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new RegisterRequest(email, "Test", "User", "password123"))))
                .andExpect(status().isCreated());

        String body = mockMvc.perform(post(LOGIN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new LoginRequest(email, "password123"))))
                .andReturn().getResponse().getContentAsString();

        return objectMapper.readTree(body).get("token").asText();
    }

    // --- GET /me ---

    @Test
    void getMe_authenticated_returnsProfile() throws Exception {
        String token = getToken("me@test.com");
        mockMvc.perform(get(ME).header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("me@test.com"))
                .andExpect(jsonPath("$.skills").isArray());
    }

    @Test
    void getMe_noToken_returns401() throws Exception {
        mockMvc.perform(get(ME)).andExpect(status().isUnauthorized());
    }

    // --- GET /me/skills ---

    @Test
    void getMySkills_returnsSkillArray() throws Exception {
        String token = getToken("skills@test.com");
        mockMvc.perform(get(ME + "/skills").header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void getMySkills_noToken_returns401() throws Exception {
        mockMvc.perform(get(ME + "/skills")).andExpect(status().isUnauthorized());
    }
}
