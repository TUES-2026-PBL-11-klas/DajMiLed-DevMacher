package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.request.ProjectRequest;
import com.elsys.server.dto.response.ProjectDto;
import com.elsys.server.entity.Project;
import com.elsys.server.entity.User;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.exception.UnauthorizedAccessException;
import com.elsys.server.repository.ProjectRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;

class ProjectServiceTest extends BaseUnitTest {

    @Mock ProjectRepository projectRepository;
    @Mock ProjectTaskService projectTaskService;
    @InjectMocks ProjectService projectService;

    private User createUser(Long id) {
        return User.builder()
                .id(id)
                .email("test" + id + "@test.com")
                .firstName("John")
                .lastName("Doe")
                .build();
    }

    private Project createProject(Long id, User owner) {
        return Project.builder()
                .id(id)
                .owner(owner)
                .title("Project Title")
                .description("Desc")
                .createdAt(LocalDateTime.now())
                .tasks(List.of())
                .build();
    }

    @Test
    void createProject_savesAndReturnsDto() {
        User user = createUser(1L);
        ProjectRequest request = new ProjectRequest("Title", "Desc");
        Project project = createProject(1L, user);
        
        given(projectRepository.save(any(Project.class))).willReturn(project);

        ProjectDto result = projectService.createProject(user, request);

        assertThat(result.title()).isEqualTo("Project Title");
        assertThat(result.description()).isEqualTo("Desc");
        assertThat(result.owner().id()).isEqualTo(1L);
    }

    @Test
    void updateProject_validOwner_updatesAndReturnsDto() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        ProjectRequest request = new ProjectRequest("New Title", "New Desc");
        
        given(projectRepository.findById(1L)).willReturn(Optional.of(project));
        given(projectRepository.save(any(Project.class))).willReturn(project);

        ProjectDto result = projectService.updateProject(1L, user, request);

        assertThat(result.title()).isEqualTo("New Title");
        assertThat(result.description()).isEqualTo("New Desc");
    }

    @Test
    void updateProject_notOwner_throwsException() {
        User user1 = createUser(1L);
        User user2 = createUser(2L);
        Project project = createProject(1L, user1);
        ProjectRequest request = new ProjectRequest("New Title", "New Desc");
        
        given(projectRepository.findById(1L)).willReturn(Optional.of(project));

        assertThatThrownBy(() -> projectService.updateProject(1L, user2, request))
                .isInstanceOf(UnauthorizedAccessException.class);
    }

    @Test
    void getProject_existingId_returnsDto() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        
        given(projectRepository.findById(1L)).willReturn(Optional.of(project));

        ProjectDto result = projectService.getProject(1L);

        assertThat(result.title()).isEqualTo("Project Title");
    }

    @Test
    void getProject_nonExistingId_throwsException() {
        given(projectRepository.findById(1L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> projectService.getProject(1L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void deleteProject_validOwner_deletesProject() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        
        given(projectRepository.findById(1L)).willReturn(Optional.of(project));

        projectService.deleteProject(1L, user);

        then(projectRepository).should().delete(project);
    }

    @Test
    void getAllProjects_returnsList() {
        User user = createUser(1L);
        Project project = createProject(1L, user);

        given(projectRepository.findPagedIds(any())).willReturn(List.of(1L));
        given(projectRepository.count()).willReturn(1L);
        given(projectRepository.findByIdsWithDetails(List.of(1L))).willReturn(List.of(project));

        var result = projectService.getAllProjects(0, 10);

        assertThat(result.content()).hasSize(1);
        assertThat(result.content().getFirst().title()).isEqualTo("Project Title");
    }
}
