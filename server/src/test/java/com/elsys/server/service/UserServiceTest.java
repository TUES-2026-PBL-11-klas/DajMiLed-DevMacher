package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.entity.User;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.repository.SkillTagRepository;
import com.elsys.server.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.Optional;
import java.util.Set;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.BDDMockito.*;

class UserServiceTest extends BaseUnitTest {

    @Mock UserRepository userRepository;
    @Mock SkillTagRepository skillTagRepository;
    @Mock SkillTagService skillTagService;
    @InjectMocks UserService userService;

    private User userWithSkills(Set<SkillTag> skills) {
        return User.builder()
                .email("john@test.com").firstName("John").lastName("Doe")
                .password("hashed").skills(skills).build();
    }

    private void givenUserWith(Set<SkillTag> skills) {
        given(userRepository.findByEmailWithSkills("john@test.com"))
                .willReturn(Optional.of(userWithSkills(skills)));
    }

    // --- toDto ---

    @Test
    void toDto_nullSkills_returnsEmptyList() {
        UserDto dto = userService.toDto(userWithSkills(null));
        assertThat(dto.skills()).isEmpty();
    }

    @Test
    void toDto_withSkills_mapsCorrectly() {
        SkillTag java = SkillTag.builder().name("java").build();
        given(skillTagService.toDto(java)).willReturn(new com.elsys.server.dto.response.SkillTagDto(null, "java"));

        UserDto dto = userService.toDto(userWithSkills(Set.of(java)));

        assertThat(dto.skills()).hasSize(1);
        assertThat(dto.skills().get(0).name()).isEqualTo("java");
    }

    // --- addSkillToUser ---

    @Test
    void addSkillToUser_existingSkill_addsIt() {
        SkillTag java = SkillTag.builder().name("java").build();
        givenUserWith(new java.util.HashSet<>());
        given(skillTagRepository.findById(1L)).willReturn(Optional.of(java));
        given(userRepository.save(any(User.class))).willAnswer(inv -> inv.getArgument(0));

        userService.addSkillToUser("john@test.com", 1L);

        then(userRepository).should().save(any(User.class));
    }

    @Test
    void addSkillToUser_unknownSkillId_throws() {
        givenUserWith(new java.util.HashSet<>());
        given(skillTagRepository.findById(99L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> userService.addSkillToUser("john@test.com", 99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    // --- removeSkillFromUser ---

    @Test
    void removeSkillFromUser_existingSkill_removesIt() {
        SkillTag java = SkillTag.builder().name("java").build();
        givenUserWith(new java.util.HashSet<>(Set.of(java)));
        given(skillTagRepository.findById(1L)).willReturn(Optional.of(java));
        given(userRepository.save(any(User.class))).willAnswer(inv -> inv.getArgument(0));

        userService.removeSkillFromUser("john@test.com", 1L);

        then(userRepository).should().save(any(User.class));
    }
}
