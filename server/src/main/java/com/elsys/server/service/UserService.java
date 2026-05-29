package com.elsys.server.service;

import com.elsys.server.dto.request.TagRequest;
import com.elsys.server.dto.request.TagsUpdateRequest;
import com.elsys.server.dto.response.TagDto;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.TagCategory;
import com.elsys.server.entity.User;
import com.elsys.server.entity.UserTag;
import com.elsys.server.exception.TagAlreadyExistsException;
import com.elsys.server.exception.TagLimitExceededException;
import com.elsys.server.exception.TagNotFoundException;
import com.elsys.server.repository.UserRepository;
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

    public UserDto toDto(User user) {
        List<TagDto> tags = user.getTags() == null ? List.of() :
                user.getTags().stream()
                        .map(t -> new TagDto(t.getName(), t.getCategory()))
                        .toList();
        return new UserDto(user.getId(), user.getEmail(), user.getFirstName(), user.getLastName(), tags);
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
