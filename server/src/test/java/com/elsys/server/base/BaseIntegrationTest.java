package com.elsys.server.base;

import org.junit.jupiter.api.BeforeEach;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClient;

/**
 * Base for full end-to-end integration tests.
 * Boots the entire context on a real random port against H2.
 * @Transactional rolls back DB state after each test.
 *
 * Usage:
 *   class AuthFlowIntegrationTest extends BaseIntegrationTest {
 *
 *       @Test
 *       void register_thenLogin_returns200() {
 *           var response = restClient.post()
 *               .uri("/api/auth/register")
 *               .body(new RegisterRequest("user@test.com", "pass"))
 *               .retrieve()
 *               .toEntity(TokenResponse.class);
 *           assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
 *       }
 *   }
 */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Transactional
public abstract class BaseIntegrationTest {

    @LocalServerPort
    protected int port;

    protected RestClient restClient;

    @BeforeEach
    void setUpRestClient() {
        restClient = RestClient.builder()
                .baseUrl("http://localhost:" + port)
                .build();
    }
}
