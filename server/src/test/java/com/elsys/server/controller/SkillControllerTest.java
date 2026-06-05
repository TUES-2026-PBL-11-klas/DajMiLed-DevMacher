package com.elsys.server.controller;

import com.elsys.server.base.BaseControllerTest;
import com.elsys.server.dto.request.SkillTagRequest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Transactional
class SkillControllerTest extends BaseControllerTest {

    private String json(Object obj) throws Exception {
        return objectMapper.writeValueAsString(obj);
    }

    private String getToken(String email) throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new com.elsys.server.dto.request.RegisterRequest(email, "Test", "User", "password123"))))
                .andExpect(status().isCreated());

        String body = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new com.elsys.server.dto.request.LoginRequest(email, "password123"))))
                .andReturn().getResponse().getContentAsString();

        return objectMapper.readTree(body).get("token").asText();
    }

    @Test
    void createSkill_returns201() throws Exception {
        String token = getToken("admin@test.com");
        SkillTagRequest req = new SkillTagRequest("Java");

        mockMvc.perform(post("/api/skills")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("Java"));
    }

    @Test
    void getAllSkills_returnsList() throws Exception {
        mockMvc.perform(get("/api/skills"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void searchSkills_returnsFilteredList() throws Exception {
        String token = getToken("search@test.com");
        mockMvc.perform(post("/api/skills")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new SkillTagRequest("Python"))))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/api/skills/search").param("q", "py"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].name").value("Python"));
    }
}
