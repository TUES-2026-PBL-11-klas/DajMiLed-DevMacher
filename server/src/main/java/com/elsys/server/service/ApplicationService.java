package com.elsys.server.service;

import com.elsys.server.dto.request.ApplicationStatusRequest;
import com.elsys.server.dto.response.ApplicationDto;
import com.elsys.server.entity.Application;
import com.elsys.server.entity.ProjectTask;
import com.elsys.server.entity.User;
import com.elsys.server.exception.DuplicateResourceException;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.exception.UnauthorizedAccessException;
import com.elsys.server.repository.ApplicationRepository;
import com.elsys.server.repository.ProjectTaskRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ApplicationService {
    private final ApplicationRepository applicationRepository;
    private final ProjectTaskRepository projectTaskRepository;

    public ApplicationDto toDto(Application application) {
        return new ApplicationDto(
                application.getId(),
                application.getTask().getId(),
                application.getApplicant().getId(),
                application.getStatus().name()
        );
    }

    @Transactional
    public ApplicationDto apply(Long taskId, User currentUser) {
        ProjectTask task = projectTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("ProjectTask", taskId));
        if (applicationRepository.existsByTaskIdAndApplicantId(taskId, currentUser.getId())) {
            throw new DuplicateResourceException("You have already applied to this task");
        }
        Application application = Application.builder()
                .task(task)
                .applicant(currentUser)
                .build();
        return toDto(applicationRepository.save(application));
    }

    @Transactional
    public ApplicationDto updateStatus(Long applicationId, User currentUser, ApplicationStatusRequest request) {
        Application application = findOrThrow(applicationId);
        if (!application.getTask().getProject().isOwnedBy(currentUser)) {
            throw new UnauthorizedAccessException("You are not the owner of this project");
        }
        application.updateStatus(request.status());
        return toDto(applicationRepository.save(application));
    }

    @Transactional
    public void withdraw(Long applicationId, User currentUser) {
        Application application = findOrThrow(applicationId);
        if (!application.isOwnedBy(currentUser)) {
            throw new UnauthorizedAccessException("You are not the applicant");
        }
        applicationRepository.delete(application);
    }

    @Transactional(readOnly = true)
    public List<ApplicationDto> getByTask(Long taskId) {
        if (!projectTaskRepository.existsById(taskId)) {
            throw new ResourceNotFoundException("ProjectTask", taskId);
        }
        return applicationRepository.findByTaskId(taskId).stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public ApplicationDto getById(Long applicationId) {
        return toDto(findOrThrow(applicationId));
    }

    @Transactional(readOnly = true)
    public List<ApplicationDto> getMyApplications(Long userId) {
        return applicationRepository.findByApplicantId(userId).stream().map(this::toDto).toList();
    }

    private Application findOrThrow(Long applicationId) {
        return applicationRepository.findById(applicationId)
                .orElseThrow(() -> new ResourceNotFoundException("Application", applicationId));
    }
}
