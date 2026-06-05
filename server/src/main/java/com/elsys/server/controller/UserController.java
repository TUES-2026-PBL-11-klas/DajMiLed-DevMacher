package com.elsys.server.controller;

import com.elsys.server.dto.request.TagRequest;
import com.elsys.server.dto.request.TagsUpdateRequest;
import com.elsys.server.dto.request.UserProfileUpdateRequest;
import com.elsys.server.dto.response.ApplicationDto;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.dto.response.TagDto;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.TagCategory;
import com.elsys.server.entity.User;
import com.elsys.server.service.ApplicationService;
import com.elsys.server.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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

    @GetMapping("/me/tags")
    public ResponseEntity<List<TagDto>> getTags(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(userService.listTags(currentUser.getUsername()));
    }

    @PostMapping("/me/tags")
    public ResponseEntity<UserDto> addTag(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody TagRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(userService.addTag(currentUser.getUsername(), request));
    }

    @DeleteMapping("/me/tags/{category}/{name}")
    public ResponseEntity<UserDto> deleteTag(
            @AuthenticationPrincipal User currentUser,
            @PathVariable TagCategory category,
            @PathVariable String name) {
        return ResponseEntity.ok(userService.deleteTag(currentUser.getUsername(), category, name));
    }

    @PutMapping("/me/tags")
    public ResponseEntity<UserDto> replaceTags(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody TagsUpdateRequest request) {
        return ResponseEntity.ok(userService.updateTags(currentUser.getUsername(), request));
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
