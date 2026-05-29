package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.request.TagRequest;
import com.elsys.server.dto.request.TagsUpdateRequest;
import com.elsys.server.dto.response.UserDto;
import com.elsys.server.entity.TagCategory;
import com.elsys.server.entity.User;
import com.elsys.server.entity.UserTag;
import com.elsys.server.exception.TagAlreadyExistsException;
import com.elsys.server.exception.TagLimitExceededException;
import com.elsys.server.exception.TagNotFoundException;
import com.elsys.server.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.BDDMockito.*;

class UserServiceTest extends BaseUnitTest {

    @Mock UserRepository userRepository;
    @InjectMocks UserService userService;

    private User userWithTags(Set<UserTag> tags) {
        return User.builder()
                .email("john@test.com").firstName("John").lastName("Doe")
                .password("hashed").tags(tags).build();
    }

    private void givenUserWith(Set<UserTag> tags) {
        given(userRepository.findByEmail("john@test.com"))
                .willReturn(Optional.of(userWithTags(tags)));
    }

    // --- toDto ---

    @Test
    void toDto_mapsTagsCorrectly() {
        Set<UserTag> tags = Set.of(
                new UserTag(TagCategory.OWN, "Java"),
                new UserTag(TagCategory.SEARCHING_FOR, "Python")
        );
        UserDto dto = userService.toDto(userWithTags(tags));

        assertThat(dto.tags()).hasSize(2);
        assertThat(dto.tags()).extracting("name").containsExactlyInAnyOrder("Java", "Python");
    }

    @Test
    void toDto_nullTags_returnsEmptyList() {
        UserDto dto = userService.toDto(userWithTags(null));
        assertThat(dto.tags()).isEmpty();
    }

    // --- buildInitialTags ---

    @Test
    void buildInitialTags_createsBothCategories() {
        Set<UserTag> tags = userService.buildInitialTags(List.of("Java", "Spring"), List.of("Python"));

        assertThat(tags).hasSize(3);
        assertThat(tags).filteredOn(t -> t.getCategory() == TagCategory.OWN)
                .extracting("name").containsExactlyInAnyOrder("Java", "Spring");
        assertThat(tags).filteredOn(t -> t.getCategory() == TagCategory.SEARCHING_FOR)
                .extracting("name").containsExactly("Python");
    }

    @Test
    void buildInitialTags_nullLists_returnsEmpty() {
        assertThat(userService.buildInitialTags(null, null)).isEmpty();
    }

    @Test
    void buildInitialTags_deduplicatesWithinCategory() {
        Set<UserTag> tags = userService.buildInitialTags(List.of("Java", "Java", "Spring"), null);
        assertThat(tags).hasSize(2);
    }

    // --- addTag ---

    @Test
    void addTag_newTag_addsSuccessfully() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "Java"))));

        UserDto result = userService.addTag("john@test.com", new TagRequest("Kotlin", TagCategory.OWN));

        assertThat(result.tags()).extracting("name").contains("Java", "Kotlin");
    }

    @Test
    void addTag_duplicate_throwsTagAlreadyExists() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "Java"))));

        assertThatThrownBy(() -> userService.addTag("john@test.com", new TagRequest("Java", TagCategory.OWN)))
                .isInstanceOf(TagAlreadyExistsException.class);
    }

    @Test
    void addTag_sameName_differentCategory_succeeds() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "Java"))));

        UserDto result = userService.addTag("john@test.com", new TagRequest("Java", TagCategory.SEARCHING_FOR));

        assertThat(result.tags()).hasSize(2);
    }

    @Test
    void addTag_limitReached_throwsTagLimitExceeded() {
        Set<UserTag> full = IntStream.rangeClosed(1, 20)
                .mapToObj(i -> new UserTag(TagCategory.OWN, "tag" + i))
                .collect(Collectors.toSet());
        givenUserWith(new HashSet<>(full));

        assertThatThrownBy(() -> userService.addTag("john@test.com", new TagRequest("extra", TagCategory.OWN)))
                .isInstanceOf(TagLimitExceededException.class);
    }

    // --- deleteTag ---

    @Test
    void deleteTag_existingTag_removesIt() {
        givenUserWith(new HashSet<>(Set.of(
                new UserTag(TagCategory.OWN, "Java"),
                new UserTag(TagCategory.OWN, "Spring")
        )));

        UserDto result = userService.deleteTag("john@test.com", TagCategory.OWN, "Java");

        assertThat(result.tags()).extracting("name").containsExactly("Spring");
    }

    @Test
    void deleteTag_nonExistentTag_throwsTagNotFound() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "Java"))));

        assertThatThrownBy(() -> userService.deleteTag("john@test.com", TagCategory.OWN, "Ghost"))
                .isInstanceOf(TagNotFoundException.class);
    }

    @Test
    void deleteTag_wrongCategory_throwsTagNotFound() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "Java"))));

        assertThatThrownBy(() -> userService.deleteTag("john@test.com", TagCategory.SEARCHING_FOR, "Java"))
                .isInstanceOf(TagNotFoundException.class);
    }

    // --- updateTags (bulk replace) ---

    @Test
    void updateTags_replacesAllTags() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "OldTag"))));

        UserDto result = userService.updateTags("john@test.com",
                new TagsUpdateRequest(List.of("NewTag"), List.of("WantThis")));

        assertThat(result.tags()).extracting("name").containsExactlyInAnyOrder("NewTag", "WantThis");
        assertThat(result.tags()).noneMatch(t -> t.name().equals("OldTag"));
    }

    @Test
    void updateTags_emptyLists_clearsAll() {
        givenUserWith(new HashSet<>(Set.of(new UserTag(TagCategory.OWN, "Java"))));

        UserDto result = userService.updateTags("john@test.com", new TagsUpdateRequest(List.of(), List.of()));

        assertThat(result.tags()).isEmpty();
    }
}
