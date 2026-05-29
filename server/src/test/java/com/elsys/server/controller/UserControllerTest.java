package com.elsys.server.controller;

import com.elsys.server.base.BaseControllerTest;
import com.elsys.server.dto.request.LoginRequest;
import com.elsys.server.dto.request.RegisterRequest;
import com.elsys.server.dto.request.TagRequest;
import com.elsys.server.dto.request.TagsUpdateRequest;
import com.elsys.server.entity.TagCategory;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@Transactional
class UserControllerTest extends BaseControllerTest {

    private static final String REGISTER = "/api/auth/register";
    private static final String LOGIN    = "/api/auth/login";
    private static final String ME       = "/api/users/me";
    private static final String ME_TAGS  = "/api/users/me/tags";

    private String json(Object obj) throws Exception {
        return objectMapper.writeValueAsString(obj);
    }

    private String getToken(String email) throws Exception {
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new RegisterRequest(email, "Test", "User", "password123"))))
                .andExpect(status().isCreated());

        String body = mockMvc.perform(post(LOGIN)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new LoginRequest(email, "password123"))))
                .andReturn().getResponse().getContentAsString();

        return objectMapper.readTree(body).get("token").asText();
    }

    // --- GET /me ---

    @Test
    void getMe_authenticated_returnsProfile() throws Exception {
        String token = getToken("me@test.com");
        mockMvc.perform(get(ME).header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("me@test.com"))
                .andExpect(jsonPath("$.tags").isArray());
    }

    @Test
    void getMe_noToken_returns401() throws Exception {
        mockMvc.perform(get(ME)).andExpect(status().isUnauthorized());
    }

    // --- GET /me/tags ---

    @Test
    void getTags_returnsTagArray() throws Exception {
        String token = getToken("list@test.com");
        mockMvc.perform(get(ME_TAGS).header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }

    // --- POST /me/tags ---

    @Test
    void addTag_newTag_returns201WithTag() throws Exception {
        String token = getToken("add@test.com");
        mockMvc.perform(post(ME_TAGS)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("Java", TagCategory.OWN))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.tags[?(@.name=='Java' && @.category=='OWN')]").exists());
    }

    @Test
    void addTag_duplicate_returns409() throws Exception {
        String token = getToken("dup@test.com");
        var req = json(new TagRequest("Java", TagCategory.OWN));

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON).content(req))
                .andExpect(status().isCreated());

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON).content(req))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.status").value(409));
    }

    @Test
    void addTag_sameName_differentCategory_returns201() throws Exception {
        String token = getToken("cross@test.com");

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("Java", TagCategory.OWN))))
                .andExpect(status().isCreated());

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("Java", TagCategory.SEARCHING_FOR))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.tags.length()").value(2));
    }

    @Test
    void addTag_limitExceeded_returns400() throws Exception {
        String token = getToken("limit@test.com");

        for (int i = 1; i <= 20; i++) {
            mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(json(new TagRequest("tag" + i, TagCategory.OWN))))
                    .andExpect(status().isCreated());
        }

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("extra", TagCategory.OWN))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Maximum of 20 tags reached for category OWN"));
    }

    @Test
    void addTag_blankName_returns400() throws Exception {
        String token = getToken("blank@test.com");
        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"\",\"category\":\"OWN\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors.name").isNotEmpty());
    }

    @Test
    void addTag_invalidCategory_returns400() throws Exception {
        String token = getToken("badcat@test.com");
        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Java\",\"category\":\"INVALID\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void addTag_noToken_returns401() throws Exception {
        mockMvc.perform(post(ME_TAGS)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("Java", TagCategory.OWN))))
                .andExpect(status().isUnauthorized());
    }

    // --- DELETE /me/tags/{category}/{name} ---

    @Test
    void deleteTag_existingTag_returns200WithoutIt() throws Exception {
        String token = getToken("del@test.com");

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("Java", TagCategory.OWN))))
                .andExpect(status().isCreated());

        mockMvc.perform(delete(ME_TAGS + "/OWN/Java")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tags[?(@.name=='Java')]").doesNotExist());
    }

    @Test
    void deleteTag_nonExistent_returns404() throws Exception {
        String token = getToken("ghost@test.com");
        mockMvc.perform(delete(ME_TAGS + "/OWN/Ghost")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    void deleteTag_invalidCategory_returns400() throws Exception {
        String token = getToken("baddelcat@test.com");
        mockMvc.perform(delete(ME_TAGS + "/INVALID/Java")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isBadRequest());
    }

    @Test
    void deleteTag_noToken_returns401() throws Exception {
        mockMvc.perform(delete(ME_TAGS + "/OWN/Java"))
                .andExpect(status().isUnauthorized());
    }

    // --- PUT /me/tags (bulk replace) ---

    @Test
    void replaceTags_validRequest_returnsUpdatedTags() throws Exception {
        String token = getToken("replace@test.com");

        mockMvc.perform(post(ME_TAGS).header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagRequest("OldTag", TagCategory.OWN))))
                .andExpect(status().isCreated());

        mockMvc.perform(put(ME_TAGS)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(new TagsUpdateRequest(List.of("NewTag"), List.of("WantThis")))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.tags[?(@.name=='NewTag')]").exists())
                .andExpect(jsonPath("$.tags[?(@.name=='OldTag')]").doesNotExist());
    }

    // --- register with tags ---

    @Test
    void register_withTags_returnsTagsInResponse() throws Exception {
        var req = new RegisterRequest(
                "tagged@test.com", "Tagged", "User", "password123",
                List.of("Java", "Spring"), List.of("Python")
        );
        mockMvc.perform(post(REGISTER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.user.tags[?(@.name=='Java')]").exists())
                .andExpect(jsonPath("$.user.tags[?(@.name=='Python')]").exists());
    }
}
