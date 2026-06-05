package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.entity.User;
import com.elsys.server.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.BDDMockito.given;

class UserDetailsServiceImplTest extends BaseUnitTest {

    @Mock UserRepository userRepository;
    @InjectMocks UserDetailsServiceImpl userDetailsService;

    @Test
    void loadUserByUsername_existingUser_returnsUserDetails() {
        User user = User.builder().email("test@test.com").build();
        given(userRepository.findByEmailWithSkills("test@test.com")).willReturn(Optional.of(user));

        UserDetails result = userDetailsService.loadUserByUsername("test@test.com");

        assertThat(result.getUsername()).isEqualTo("test@test.com");
    }

    @Test
    void loadUserByUsername_nonExistingUser_throwsException() {
        given(userRepository.findByEmailWithSkills("test@test.com")).willReturn(Optional.empty());

        assertThatThrownBy(() -> userDetailsService.loadUserByUsername("test@test.com"))
                .isInstanceOf(UsernameNotFoundException.class);
    }
}
