package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.request.ProjectTaskRequest;
import com.elsys.server.dto.response.ProjectTaskDto;
import com.elsys.server.entity.Project;
import com.elsys.server.entity.ProjectTask;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.entity.User;
import com.elsys.server.exception.UnauthorizedAccessException;
import com.elsys.server.repository.ProjectRepository;
import com.elsys.server.repository.ProjectTaskRepository;
import com.elsys.server.repository.SkillTagRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;

class ProjectTaskServiceTest extends BaseUnitTest {

    @Mock ProjectTaskRepository projectTaskRepository;
    @Mock ProjectRepository projectRepository;
    @Mock SkillTagRepository skillTagRepository;
    @Mock SkillTagService skillTagService;
    @InjectMocks ProjectTaskService projectTaskService;

    private User createUser(Long id) {
        return User.builder().id(id).email("test@test.com").build();
    }

    private Project createProject(Long id, User owner) {
        return Project.builder()
                .id(id)
                .owner(owner)
                .title("P")
                .build();
    }

    private ProjectTask createTask(Long id, Project project) {
        return ProjectTask.builder()
                .id(id)
                .project(project)
                .title("T")
                .requiredSkills(new HashSet<>())
                .build();
    }

    @Test
    void createTask_validOwner_savesAndReturnsDto() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        ProjectTaskRequest req = new ProjectTaskRequest("Task", "Desc");
        ProjectTask task = createTask(1L, project);

        given(projectRepository.findById(1L)).willReturn(Optional.of(project));
        given(projectTaskRepository.save(any(ProjectTask.class))).willReturn(task);

        ProjectTaskDto result = projectTaskService.createTask(1L, user, req);

        assertThat(result.title()).isEqualTo("T");
    }

    @Test
    void createTask_notOwner_throwsException() {
        User user1 = createUser(1L);
        User user2 = createUser(2L);
        Project project = createProject(1L, user1);
        ProjectTaskRequest req = new ProjectTaskRequest("Task", "Desc");

        given(projectRepository.findById(1L)).willReturn(Optional.of(project));

        assertThatThrownBy(() -> projectTaskService.createTask(1L, user2, req))
                .isInstanceOf(UnauthorizedAccessException.class);
    }

    @Test
    void updateTask_validOwner_updatesAndReturnsDto() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        ProjectTask task = createTask(1L, project);
        ProjectTaskRequest req = new ProjectTaskRequest("New Task", "New Desc");

        given(projectTaskRepository.findById(1L)).willReturn(Optional.of(task));
        given(projectTaskRepository.save(task)).willReturn(task);

        ProjectTaskDto result = projectTaskService.updateTask(1L, user, req);

        assertThat(task.getTitle()).isEqualTo("New Task");
    }

    @Test
    void deleteTask_validOwner_deletes() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        ProjectTask task = createTask(1L, project);

        given(projectTaskRepository.findById(1L)).willReturn(Optional.of(task));

        projectTaskService.deleteTask(1L, user);

        then(projectTaskRepository).should().delete(task);
    }

    @Test
    void addSkillToTask_validIds_addsSkill() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        ProjectTask task = createTask(1L, project);
        SkillTag skill = SkillTag.builder().id(1L).name("Skill").build();

        given(projectTaskRepository.findById(1L)).willReturn(Optional.of(task));
        given(skillTagRepository.findById(1L)).willReturn(Optional.of(skill));
        given(projectTaskRepository.save(task)).willReturn(task);

        projectTaskService.addSkillToTask(1L, 1L, user);

        assertThat(task.getRequiredSkills()).contains(skill);
    }

    @Test
    void getTasksByProject_existingProject_returnsList() {
        User user = createUser(1L);
        Project project = createProject(1L, user);
        ProjectTask task = createTask(1L, project);

        given(projectRepository.existsById(1L)).willReturn(true);
        given(projectTaskRepository.findByProjectId(1L)).willReturn(List.of(task));

        List<ProjectTaskDto> result = projectTaskService.getTasksByProject(1L);

        assertThat(result).hasSize(1);
    }
}
