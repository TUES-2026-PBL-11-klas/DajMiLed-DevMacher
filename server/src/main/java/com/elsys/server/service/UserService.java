package com.elsys.server.service;

import com.elsys.server.dto.request.UserProfileUpdateRequest;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.entity.User;
import com.elsys.server.exception.DuplicateResourceException;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.repository.SkillTagRepository;
import com.elsys.server.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final SkillTagRepository skillTagRepository;
    private final SkillTagService skillTagService;

    public UserDto toDto(User user) {
        List<SkillTagDto> skills = user.getSkills() == null ? List.of() :
                user.getSkills().stream()
                        .map(skillTagService::toDto)
                        .toList();
        return new UserDto(
                user.getId(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getProfileUsername(),
                user.getDiscordTag(),
                user.getGithubLink(),
                user.getBio(),
                user.getEducation(),
                skills
        );
    }

    @Transactional
    public UserDto updateProfile(String email, UserProfileUpdateRequest request) {
        User user = findByEmailOrThrow(email);

        if (request.username() != null && !request.username().equals(user.getProfileUsername())) {
            if (userRepository.existsByUsername(request.username())) {
                throw new DuplicateResourceException("Username '" + request.username() + "' is already taken");
            }
        }

        user.updateProfile(
                request.username(),
                request.discordTag(),
                request.githubLink(),
                request.bio(),
                request.education()
        );

        userRepository.save(user);
        return toDto(user);
    }

    @Transactional
    public UserDto addSkillToUser(String email, Long skillId) {
        User user = findByEmailOrThrow(email);
        SkillTag skill = skillTagRepository.findById(skillId)
                .orElseThrow(() -> new ResourceNotFoundException("SkillTag", skillId));

        Set<SkillTag> currentSkills = user.getSkills() == null ? new HashSet<>() : new HashSet<>(user.getSkills());
        currentSkills.add(skill);
        user.updateSkills(currentSkills);

        userRepository.save(user);
        return toDto(user);
    }

    @Transactional
    public UserDto removeSkillFromUser(String email, Long skillId) {
        User user = findByEmailOrThrow(email);
        SkillTag skill = skillTagRepository.findById(skillId)
                .orElseThrow(() -> new ResourceNotFoundException("SkillTag", skillId));

        Set<SkillTag> currentSkills = user.getSkills() == null ? new HashSet<>() : new HashSet<>(user.getSkills());
        currentSkills.remove(skill);
        user.updateSkills(currentSkills);

        userRepository.save(user);
        return toDto(user);
    }

    @Transactional(readOnly = true)
    public List<SkillTagDto> getUserSkills(String email) {
        User user = findByEmailOrThrow(email);
        return user.getSkills() == null ? List.of() :
                user.getSkills().stream().map(skillTagService::toDto).toList();
    }

    @Transactional(readOnly = true)
    public UserDto getUserById(Long id) {
        User user = userRepository.findByIdWithSkills(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
        return toDto(user);
    }

    private User findByEmailOrThrow(String email) {
        return userRepository.findByEmailWithSkills(email)
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found: " + email));
    }
}
