package com.elsys.server.repository;

import com.elsys.server.base.BaseRepositoryTest;
import com.elsys.server.entity.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;

import static org.assertj.core.api.Assertions.*;

class UserRepositoryTest extends BaseRepositoryTest {

    @Autowired
    UserRepository userRepository;

    private User buildUser(String email) {
        return User.builder()
                .email(email).firstName("John").lastName("Doe")
                .password("hashed_password").build();
    }

    @Test
    void findByEmail_existingEmail_returnsUser() {
        userRepository.save(buildUser("john@test.com"));

        assertThat(userRepository.findByEmail("john@test.com"))
                .isPresent()
                .get()
                .extracting(User::getEmail)
                .isEqualTo("john@test.com");
    }

    @Test
    void findByEmail_unknownEmail_returnsEmpty() {
        assertThat(userRepository.findByEmail("nobody@test.com")).isEmpty();
    }

    @Test
    void existsByEmail_existingEmail_returnsTrue() {
        userRepository.save(buildUser("exists@test.com"));
        assertThat(userRepository.existsByEmail("exists@test.com")).isTrue();
    }

    @Test
    void existsByEmail_unknownEmail_returnsFalse() {
        assertThat(userRepository.existsByEmail("nobody@test.com")).isFalse();
    }

    @Test
    void save_duplicateEmail_throwsDataIntegrityViolation() {
        userRepository.saveAndFlush(buildUser("dup@test.com"));
        assertThatThrownBy(() -> userRepository.saveAndFlush(buildUser("dup@test.com")))
                .isInstanceOf(DataIntegrityViolationException.class);
    }
}
