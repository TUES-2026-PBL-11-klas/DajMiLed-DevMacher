package com.elsys.server.base;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import static org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity;

/**
 * Base for controller (web) layer tests.
 * Boots full context in MOCK web environment — no real HTTP port.
 * Use @MockBean on the subclass to replace services with mocks.
 *
 * Usage:
 *   @SpringBootTest
 *   class UserControllerTest extends BaseControllerTest {
 *       @MockBean UserService userService;
 *
 *       @Test
 *       void getUser_returns200() throws Exception {
 *           given(userService.findById(1L)).willReturn(new UserDto(...));
 *           mockMvc.perform(get("/api/users/1")
 *                   .with(user("admin").roles("ADMIN")))
 *                  .andExpect(status().isOk())
 *                  .andExpect(jsonPath("$.id").value(1));
 *       }
 *   }
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@ActiveProfiles("test")
public abstract class BaseControllerTest {

    @Autowired
    private WebApplicationContext context;

    @Autowired
    protected ObjectMapper objectMapper;

    protected MockMvc mockMvc;

    @BeforeEach
    void setUpMockMvc() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .apply(springSecurity())
                .build();
    }
}
