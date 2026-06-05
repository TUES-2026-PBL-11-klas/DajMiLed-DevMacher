package com.elsys.server.controller;

import com.elsys.server.base.BaseControllerTest;
import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.ProjectRequest;
import com.elsys.server.dto.request.RegisterRequest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Transactional
class ProjectControllerTest extends BaseControllerTest {

    private String json(Object obj) throws Exception {
        return objectMapper.writeValueAsString(obj);
    }

    private String getToken(String email) throws Exception {
        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new RegisterRequest(email, "Test", "User", "password123"))))
                .andExpect(status().isCreated());

        String body = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new LoginRequest(email, "password123"))))
                .andReturn().getResponse().getContentAsString();

        return objectMapper.readTree(body).get("token").asText();
    }

    @Test
    void createProject_returns201() throws Exception {
        String token = getToken("owner@test.com");
        ProjectRequest req = new ProjectRequest("My Project", "Desc");

        mockMvc.perform(post("/api/projects")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("My Project"));
    }

    @Test
    void getAllProjects_returnsList() throws Exception {
        mockMvc.perform(get("/api/projects"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    @Test
    void updateProject_returns200() throws Exception {
        String token = getToken("owner2@test.com");
        ProjectRequest req = new ProjectRequest("My Project", "Desc");

        String res = mockMvc.perform(post("/api/projects")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long id = objectMapper.readTree(res).get("id").asLong();
        ProjectRequest updateReq = new ProjectRequest("Updated", "New Desc");

        mockMvc.perform(put("/api/projects/" + id)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Updated"));
    }

    @Test
    void deleteProject_returns204() throws Exception {
        String token = getToken("owner3@test.com");
        ProjectRequest req = new ProjectRequest("My Project", "Desc");

        String res = mockMvc.perform(post("/api/projects")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long id = objectMapper.readTree(res).get("id").asLong();

        mockMvc.perform(delete("/api/projects/" + id)
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNoContent());
    }
}
