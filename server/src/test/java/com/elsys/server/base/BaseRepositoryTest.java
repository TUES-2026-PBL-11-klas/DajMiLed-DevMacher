package com.elsys.server.base;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

/**
 * Base for repository layer tests.
 * Boots the full context against H2 (test profile).
 * @Transactional rolls back each test automatically — no cleanup needed.
 *
 * Usage:
 *   class UserRepositoryTest extends BaseRepositoryTest {
 *       @Autowired UserRepository userRepository;
 *
 *       @Test
 *       void findByEmail_returnsUser() {
 *           userRepository.save(new User("test@test.com"));
 *           assertThat(userRepository.findByEmail("test@test.com")).isPresent();
 *       }
 *   }
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
public abstract class BaseRepositoryTest {
}
