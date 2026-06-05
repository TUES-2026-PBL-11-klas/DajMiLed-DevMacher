package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.request.SkillTagRequest;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.exception.DuplicateResourceException;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.repository.SkillTagRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;

class SkillTagServiceTest extends BaseUnitTest {

    @Mock SkillTagRepository skillTagRepository;
    @InjectMocks SkillTagService skillTagService;

    @Test
    void createSkill_newName_savesAndReturnsDto() {
        SkillTagRequest req = new SkillTagRequest("Java");
        SkillTag tag = SkillTag.builder().id(1L).name("Java").build();

        given(skillTagRepository.existsByName("Java")).willReturn(false);
        given(skillTagRepository.save(any(SkillTag.class))).willReturn(tag);

        SkillTagDto result = skillTagService.createSkill(req);

        assertThat(result.name()).isEqualTo("Java");
    }

    @Test
    void createSkill_existingName_throwsException() {
        SkillTagRequest req = new SkillTagRequest("Java");

        given(skillTagRepository.existsByName("Java")).willReturn(true);

        assertThatThrownBy(() -> skillTagService.createSkill(req))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    void getAllSkills_returnsList() {
        SkillTag tag = SkillTag.builder().id(1L).name("java").build();

        given(skillTagRepository.findAll()).willReturn(List.of(tag));

        List<SkillTagDto> result = skillTagService.getAllSkills();

        assertThat(result).hasSize(1);
    }

    @Test
    void searchSkills_withQuery_returnsFilteredList() {
        SkillTag tag = SkillTag.builder().id(1L).name("java").build();

        given(skillTagRepository.findByNameContainingIgnoreCase("java")).willReturn(List.of(tag));

        List<SkillTagDto> result = skillTagService.searchSkills("java");

        assertThat(result).hasSize(1);
    }

    @Test
    void searchSkills_emptyQuery_returnsAll() {
        SkillTag tag = SkillTag.builder().id(1L).name("java").build();

        given(skillTagRepository.findAll()).willReturn(List.of(tag));

        List<SkillTagDto> result = skillTagService.searchSkills("   ");

        assertThat(result).hasSize(1);
    }

    @Test
    void getSkillById_existing_returnsDto() {
        SkillTag tag = SkillTag.builder().id(1L).name("java").build();

        given(skillTagRepository.findById(1L)).willReturn(Optional.of(tag));

        SkillTagDto result = skillTagService.getSkillById(1L);

        assertThat(result.name()).isEqualTo("java");
    }

    @Test
    void getSkillById_nonExisting_throwsException() {
        given(skillTagRepository.findById(1L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> skillTagService.getSkillById(1L))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
