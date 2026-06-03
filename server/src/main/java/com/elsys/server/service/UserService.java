package com.elsys.server.service;

import com.elsys.server.dto.request.TagRequest;
import com.elsys.server.dto.request.TagsUpdateRequest;
import com.elsys.server.dto.response.TagDto;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.TagCategory;
import com.elsys.server.entity.User;
import com.elsys.server.entity.UserTag;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.dto.request.UserProfileUpdateRequest;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.exception.TagAlreadyExistsException;
import com.elsys.server.exception.TagLimitExceededException;
import com.elsys.server.exception.TagNotFoundException;
import com.elsys.server.exception.DuplicateResourceException;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.repository.UserRepository;
import com.elsys.server.repository.SkillTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final int MAX_TAGS_PER_CATEGORY = 20;

    private final UserRepository userRepository;
    private final SkillTagRepository skillTagRepository;
    private final SkillTagService skillTagService;

    public UserDto toDto(User user) {
        List<TagDto> tags = user.getTags() == null ? List.of() :
                user.getTags().stream()
                        .map(t -> new TagDto(t.getName(), t.getCategory()))
                        .toList();
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
                tags,
                skills
        );
    }

    @Transactional(readOnly = true)
    public List<TagDto> listTags(String email) {
        User user = findByEmailOrThrow(email);
        return user.getTags() == null ? List.of() :
                user.getTags().stream()
                        .map(t -> new TagDto(t.getName(), t.getCategory()))
                        .toList();
    }

    @Transactional
    public UserDto addTag(String email, TagRequest request) {
        User user = findByEmailOrThrow(email);

        Set<UserTag> current = mutableCopy(user.getTags());
        String name = request.name().trim();
        UserTag newTag = new UserTag(request.category(), name);

        long countInCategory = current.stream()
                .filter(t -> t.getCategory() == request.category())
                .count();
        if (countInCategory >= MAX_TAGS_PER_CATEGORY) {
            throw new TagLimitExceededException(request.category());
        }
        if (!current.add(newTag)) {
            throw new TagAlreadyExistsException(name, request.category());
        }

        user.updateTags(current);
        return toDto(user);
    }

    @Transactional
    public UserDto deleteTag(String email, TagCategory category, String name) {
        User user = findByEmailOrThrow(email);

        Set<UserTag> current = mutableCopy(user.getTags());
        if (!current.remove(new UserTag(category, name.trim()))) {
            throw new TagNotFoundException(name, category);
        }

        user.updateTags(current);
        return toDto(user);
    }

    @Transactional
    public UserDto updateTags(String email, TagsUpdateRequest request) {
        User user = findByEmailOrThrow(email);

        Set<UserTag> newTags = new HashSet<>();
        newTags.addAll(toUserTags(request.ownTags(), TagCategory.OWN));
        newTags.addAll(toUserTags(request.searchingForTags(), TagCategory.SEARCHING_FOR));

        user.updateTags(newTags);
        return toDto(user);
    }

    public Set<UserTag> buildInitialTags(List<String> ownTagNames, List<String> searchingForTagNames) {
        Set<UserTag> tags = new HashSet<>();
        tags.addAll(toUserTags(ownTagNames, TagCategory.OWN));
        tags.addAll(toUserTags(searchingForTagNames, TagCategory.SEARCHING_FOR));
        return tags;
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

    private User findByEmailOrThrow(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalStateException("Authenticated user not found: " + email));
    }

    private Set<UserTag> mutableCopy(Set<UserTag> tags) {
        return tags == null ? new HashSet<>() : new HashSet<>(tags);
    }

    private Set<UserTag> toUserTags(List<String> names, TagCategory category) {
        if (names == null) return Set.of();
        return names.stream()
                .filter(s -> s != null && !s.isBlank())
                .map(String::trim)
                .distinct()
                .map(name -> new UserTag(category, name))
                .collect(Collectors.toSet());
    }
}
