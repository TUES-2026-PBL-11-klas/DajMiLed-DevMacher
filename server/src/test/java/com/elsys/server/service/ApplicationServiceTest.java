package com.elsys.server.service;

import com.elsys.server.base.BaseUnitTest;
import com.elsys.server.dto.request.ApplicationStatusRequest;
import com.elsys.server.dto.response.ApplicationDto;
import com.elsys.server.entity.Application;
import com.elsys.server.entity.ApplicationStatus;
import com.elsys.server.entity.Project;
import com.elsys.server.entity.ProjectTask;
import com.elsys.server.entity.User;
import com.elsys.server.exception.DuplicateResourceException;
import com.elsys.server.exception.UnauthorizedAccessException;
import com.elsys.server.repository.ApplicationRepository;
import com.elsys.server.repository.ProjectTaskRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.then;

class ApplicationServiceTest extends BaseUnitTest {

    @Mock ApplicationRepository applicationRepository;
    @Mock ProjectTaskRepository projectTaskRepository;
    @InjectMocks ApplicationService applicationService;

    private User createUser(Long id) {
        return User.builder().id(id).email("test@test.com").build();
    }

    private ProjectTask createTask(Long id, Project project) {
        return ProjectTask.builder()
                .id(id)
                .project(project)
                .title("Task")
                .build();
    }

    private Application createApplication(Long id, ProjectTask task, User applicant) {
        return Application.builder()
                .id(id)
                .task(task)
                .applicant(applicant)
                .status(ApplicationStatus.PENDING)
                .build();
    }

    @Test
    void apply_validTask_savesAndReturnsDto() {
        User user = createUser(1L);
        Project project = Project.builder().owner(createUser(2L)).build();
        ProjectTask task = createTask(1L, project);
        Application app = createApplication(1L, task, user);

        given(projectTaskRepository.findById(1L)).willReturn(Optional.of(task));
        given(applicationRepository.existsByTaskIdAndApplicantId(1L, 1L)).willReturn(false);
        given(applicationRepository.save(any(Application.class))).willReturn(app);

        ApplicationDto result = applicationService.apply(1L, user);

        assertThat(result.status()).isEqualTo("PENDING");
        assertThat(result.applicantId()).isEqualTo(1L);
    }

    @Test
    void apply_alreadyApplied_throwsException() {
        User user = createUser(1L);
        Project project = Project.builder().owner(createUser(2L)).build();
        ProjectTask task = createTask(1L, project);

        given(projectTaskRepository.findById(1L)).willReturn(Optional.of(task));
        given(applicationRepository.existsByTaskIdAndApplicantId(1L, 1L)).willReturn(true);

        assertThatThrownBy(() -> applicationService.apply(1L, user))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    void updateStatus_ownerOfProject_updatesAndReturnsDto() {
        User owner = createUser(2L);
        Project project = Project.builder().owner(owner).build();
        ProjectTask task = createTask(1L, project);
        User applicant = createUser(1L);
        Application app = createApplication(1L, task, applicant);
        ApplicationStatusRequest req = new ApplicationStatusRequest(ApplicationStatus.ACCEPTED);

        given(applicationRepository.findById(1L)).willReturn(Optional.of(app));
        given(applicationRepository.save(app)).willReturn(app);

        ApplicationDto result = applicationService.updateStatus(1L, owner, req);

        assertThat(app.getStatus()).isEqualTo(ApplicationStatus.ACCEPTED);
    }

    @Test
    void updateStatus_notOwnerOfProject_throwsException() {
        User notOwner = createUser(3L);
        Project project = Project.builder().owner(createUser(2L)).build();
        ProjectTask task = createTask(1L, project);
        User applicant = createUser(1L);
        Application app = createApplication(1L, task, applicant);
        ApplicationStatusRequest req = new ApplicationStatusRequest(ApplicationStatus.ACCEPTED);

        given(applicationRepository.findById(1L)).willReturn(Optional.of(app));

        assertThatThrownBy(() -> applicationService.updateStatus(1L, notOwner, req))
                .isInstanceOf(UnauthorizedAccessException.class);
    }

    @Test
    void withdraw_applicant_deletesApplication() {
        User applicant = createUser(1L);
        Project project = Project.builder().owner(createUser(2L)).build();
        ProjectTask task = createTask(1L, project);
        Application app = createApplication(1L, task, applicant);

        given(applicationRepository.findById(1L)).willReturn(Optional.of(app));

        applicationService.withdraw(1L, applicant);

        then(applicationRepository).should().delete(app);
    }

    @Test
    void getByTask_existingTask_returnsList() {
        User applicant = createUser(1L);
        Project project = Project.builder().owner(createUser(2L)).build();
        ProjectTask task = createTask(1L, project);
        Application app = createApplication(1L, task, applicant);

        given(projectTaskRepository.existsById(1L)).willReturn(true);
        given(applicationRepository.findByTaskId(1L)).willReturn(List.of(app));

        List<ApplicationDto> result = applicationService.getByTask(1L);

        assertThat(result).hasSize(1);
    }
}
