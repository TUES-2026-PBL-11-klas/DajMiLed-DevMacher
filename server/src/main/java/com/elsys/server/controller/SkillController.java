package com.elsys.server.controller;

import com.elsys.server.dto.request.SkillTagRequest;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.service.SkillTagService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
@RequiredArgsConstructor
public class SkillController {
    private final SkillTagService skillTagService;

    @PostMapping
    public ResponseEntity<SkillTagDto> createSkill(@Valid @RequestBody SkillTagRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(skillTagService.createSkill(request));
    }

    @GetMapping
    public ResponseEntity<List<SkillTagDto>> getAllSkills() {
        return ResponseEntity.ok(skillTagService.getAllSkills());
    }

    @GetMapping("/search")
    public ResponseEntity<List<SkillTagDto>> searchSkills(@RequestParam(required = false) String q) {
        return ResponseEntity.ok(skillTagService.searchSkills(q));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SkillTagDto> getSkillById(@PathVariable Long id) {
        return ResponseEntity.ok(skillTagService.getSkillById(id));
    }
}
