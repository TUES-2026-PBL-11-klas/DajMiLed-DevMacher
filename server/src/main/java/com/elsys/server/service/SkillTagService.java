package com.elsys.server.service;

import com.elsys.server.dto.request.SkillTagRequest;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.exception.DuplicateResourceException;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.repository.SkillTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SkillTagService {
    private final SkillTagRepository skillTagRepository;

    public SkillTagDto toDto(SkillTag skillTag) {
        return new SkillTagDto(skillTag.getId(), skillTag.getName());
    }

    @Transactional
    public SkillTagDto createSkill(SkillTagRequest request) {
        String name = request.name().trim();
        if (skillTagRepository.existsByName(name)) {
            throw new DuplicateResourceException("Skill with name '" + name + "' already exists");
        }
        SkillTag skillTag = SkillTag.builder()
                .name(name)
                .build();
        return toDto(skillTagRepository.save(skillTag));
    }

    @Transactional(readOnly = true)
    public List<SkillTagDto> getAllSkills() {
        return skillTagRepository.findAll().stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public List<SkillTagDto> searchSkills(String query) {
        if (query == null || query.isBlank()) {
            return getAllSkills();
        }
        return skillTagRepository.findByNameContainingIgnoreCase(query.trim()).stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public SkillTagDto getSkillById(Long id) {
        return toDto(skillTagRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("SkillTag", id)));
    }
}
