package com.elsys.server.controller;

import com.elsys.server.dto.request.ProjectTaskRequest;
import com.elsys.server.dto.response.ProjectTaskDto;
import com.elsys.server.entity.User;
import com.elsys.server.service.ProjectTaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects/{projectId}/tasks")
@RequiredArgsConstructor
public class ProjectTaskController {
    private final ProjectTaskService projectTaskService;

    @PostMapping
    public ResponseEntity<ProjectTaskDto> createTask(
            @PathVariable Long projectId,
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody ProjectTaskRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(projectTaskService.createTask(projectId, currentUser, request));
    }

    @PutMapping("/{taskId}")
    public ResponseEntity<ProjectTaskDto> updateTask(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody ProjectTaskRequest request) {
        return ResponseEntity.ok(projectTaskService.updateTask(taskId, currentUser, request));
    }

    @DeleteMapping("/{taskId}")
    public ResponseEntity<Void> deleteTask(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @AuthenticationPrincipal User currentUser) {
        projectTaskService.deleteTask(taskId, currentUser);
        return ResponseEntity.noContent().build();
    }

    @GetMapping
    public ResponseEntity<List<ProjectTaskDto>> getTasksByProject(@PathVariable Long projectId) {
        return ResponseEntity.ok(projectTaskService.getTasksByProject(projectId));
    }

    @GetMapping("/{taskId}")
    public ResponseEntity<ProjectTaskDto> getTask(
            @PathVariable Long projectId,
            @PathVariable Long taskId) {
        return ResponseEntity.ok(projectTaskService.getTask(taskId));
    }

    @PostMapping("/{taskId}/skills/{skillId}")
    public ResponseEntity<ProjectTaskDto> addSkillToTask(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @PathVariable Long skillId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(projectTaskService.addSkillToTask(taskId, skillId, currentUser));
    }

    @DeleteMapping("/{taskId}/skills/{skillId}")
    public ResponseEntity<ProjectTaskDto> removeSkillFromTask(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @PathVariable Long skillId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(projectTaskService.removeSkillFromTask(taskId, skillId, currentUser));
    }
}
