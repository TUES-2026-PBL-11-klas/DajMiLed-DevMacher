package com.elsys.server.controller;

import com.elsys.server.base.BaseControllerTest;
import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.ProjectRequest;
import com.elsys.server.dto.request.ProjectTaskRequest;
import com.elsys.server.dto.request.RegisterRequest;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Transactional
class ProjectTaskControllerTest extends BaseControllerTest {

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

    private Long createProject(String token) throws Exception {
        String res = mockMvc.perform(post("/api/projects")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new ProjectRequest("Proj", "Desc"))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return objectMapper.readTree(res).get("id").asLong();
    }

    @Test
    void createTask_returns201() throws Exception {
        String token = getToken("taskowner@test.com");
        Long projectId = createProject(token);
        ProjectTaskRequest req = new ProjectTaskRequest("Task 1", "Desc");

        mockMvc.perform(post("/api/projects/" + projectId + "/tasks")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Task 1"));
    }

    @Test
    void updateTask_returns200() throws Exception {
        String token = getToken("taskowner2@test.com");
        Long projectId = createProject(token);
        ProjectTaskRequest req = new ProjectTaskRequest("Task 1", "Desc");

        String res = mockMvc.perform(post("/api/projects/" + projectId + "/tasks")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long taskId = objectMapper.readTree(res).get("id").asLong();
        ProjectTaskRequest updateReq = new ProjectTaskRequest("Updated Task", "Desc");

        mockMvc.perform(put("/api/projects/" + projectId + "/tasks/" + taskId)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Updated Task"));
    }

    @Test
    void getTasksByProject_returnsList() throws Exception {
        String token = getToken("taskowner3@test.com");
        Long projectId = createProject(token);

        mockMvc.perform(get("/api/projects/" + projectId + "/tasks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
}
