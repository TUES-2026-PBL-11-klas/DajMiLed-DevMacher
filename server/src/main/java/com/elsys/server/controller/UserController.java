package com.elsys.server.controller;

import com.elsys.server.dto.request.UserProfileUpdateRequest;
import com.elsys.server.dto.response.ApplicationDto;
import com.elsys.server.dto.response.ProjectTaskDto;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.User;
import com.elsys.server.service.ApplicationService;
import com.elsys.server.service.ProjectTaskService;
import com.elsys.server.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final ApplicationService applicationService;
    private final ProjectTaskService projectTaskService;

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getUserById(id));
    }

    @GetMapping("/me")
    public ResponseEntity<UserDto> getMe(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(userService.toDto(currentUser));
    }

    @GetMapping("/me/applications")
    public ResponseEntity<List<ApplicationDto>> getMyApplications(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(applicationService.getMyApplications(currentUser.getId()));
    }

    @GetMapping("/me/relevant-tasks")
    public ResponseEntity<List<ProjectTaskDto>> getRelevantTasks(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(projectTaskService.getRelevantTasks(currentUser));
    }

    @PutMapping("/me")
    public ResponseEntity<UserDto> updateProfile(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody UserProfileUpdateRequest request) {
        return ResponseEntity.ok(userService.updateProfile(currentUser.getUsername(), request));
    }

    @PostMapping("/me/skills/{skillId}")
    public ResponseEntity<UserDto> addSkill(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long skillId) {
        return ResponseEntity.ok(userService.addSkillToUser(currentUser.getUsername(), skillId));
    }

    @DeleteMapping("/me/skills/{skillId}")
    public ResponseEntity<UserDto> removeSkill(
            @AuthenticationPrincipal User currentUser,
            @PathVariable Long skillId) {
        return ResponseEntity.ok(userService.removeSkillFromUser(currentUser.getUsername(), skillId));
    }

    @GetMapping("/me/skills")
    public ResponseEntity<List<SkillTagDto>> getMySkills(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(userService.getUserSkills(currentUser.getUsername()));
    }
}
