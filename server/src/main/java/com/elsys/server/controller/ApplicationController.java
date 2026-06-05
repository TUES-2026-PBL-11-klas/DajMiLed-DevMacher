package com.elsys.server.controller;

import com.elsys.server.dto.request.ApplicationStatusRequest;
import com.elsys.server.dto.response.ApplicationDto;
import com.elsys.server.entity.User;
import com.elsys.server.service.ApplicationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects/{projectId}/tasks/{taskId}/applications")
@RequiredArgsConstructor
public class ApplicationController {
    private final ApplicationService applicationService;

    @PostMapping
    public ResponseEntity<ApplicationDto> apply(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(applicationService.apply(taskId, currentUser));
    }

    @GetMapping
    public ResponseEntity<List<ApplicationDto>> getByTask(
            @PathVariable Long projectId,
            @PathVariable Long taskId) {
        return ResponseEntity.ok(applicationService.getByTask(taskId));
    }

    @GetMapping("/{applicationId}")
    public ResponseEntity<ApplicationDto> getById(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @PathVariable Long applicationId) {
        return ResponseEntity.ok(applicationService.getById(applicationId));
    }

    @PutMapping("/{applicationId}")
    public ResponseEntity<ApplicationDto> updateStatus(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @PathVariable Long applicationId,
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody ApplicationStatusRequest request) {
        return ResponseEntity.ok(applicationService.updateStatus(applicationId, currentUser, request));
    }

    @DeleteMapping("/{applicationId}")
    public ResponseEntity<Void> withdraw(
            @PathVariable Long projectId,
            @PathVariable Long taskId,
            @PathVariable Long applicationId,
            @AuthenticationPrincipal User currentUser) {
        applicationService.withdraw(applicationId, currentUser);
        return ResponseEntity.noContent().build();
    }
}
