package com.elsys.server.controller;

import com.elsys.server.base.BaseControllerTest;
import com.elsys.server.dto.request.ApplicationStatusRequest;
import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.ProjectRequest;
import com.elsys.server.dto.request.ProjectTaskRequest;
import com.elsys.server.dto.request.RegisterRequest;
import com.elsys.server.entity.ApplicationStatus;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Transactional
class ApplicationControllerTest extends BaseControllerTest {

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

    private Long createProjectAndTask(String token) throws Exception {
        String resProj = mockMvc.perform(post("/api/projects")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new ProjectRequest("Proj", "Desc"))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        Long projectId = objectMapper.readTree(resProj).get("id").asLong();

        String resTask = mockMvc.perform(post("/api/projects/" + projectId + "/tasks")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new ProjectTaskRequest("Task 1", "Desc"))))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        return objectMapper.readTree(resTask).get("id").asLong();
    }

    @Test
    void apply_returns201() throws Exception {
        String ownerToken = getToken("appowner@test.com");
        Long taskId = createProjectAndTask(ownerToken);

        String applicantToken = getToken("applicant@test.com");

        mockMvc.perform(post("/api/projects/1/tasks/" + taskId + "/applications")
                        .header("Authorization", "Bearer " + applicantToken))
                .andExpect(status().isCreated());
    }

    @Test
    void updateStatus_returns200() throws Exception {
        String ownerToken = getToken("appowner2@test.com");
        Long taskId = createProjectAndTask(ownerToken);

        String applicantToken = getToken("applicant2@test.com");

        String resApp = mockMvc.perform(post("/api/projects/1/tasks/" + taskId + "/applications")
                        .header("Authorization", "Bearer " + applicantToken))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        Long appId = objectMapper.readTree(resApp).get("id").asLong();

        mockMvc.perform(put("/api/projects/1/tasks/" + taskId + "/applications/" + appId)
                        .header("Authorization", "Bearer " + ownerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new ApplicationStatusRequest(ApplicationStatus.ACCEPTED))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ACCEPTED"));
    }

    @Test
    void getByTask_returnsList() throws Exception {
        String ownerToken = getToken("appowner3@test.com");
        Long taskId = createProjectAndTask(ownerToken);

        mockMvc.perform(get("/api/projects/1/tasks/" + taskId + "/applications")
                        .header("Authorization", "Bearer " + ownerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
}
