package com.elsys.server.service;

import com.elsys.server.dto.request.ProjectRequest;
import com.elsys.server.dto.response.ProjectDto;
import com.elsys.server.dto.response.ProjectTaskDto;
import com.elsys.server.dto.response.UserSummaryDto;
import com.elsys.server.entity.Project;
import com.elsys.server.entity.User;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.exception.UnauthorizedAccessException;
import com.elsys.server.repository.ProjectRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectService {
    private final ProjectRepository projectRepository;
    private final ProjectTaskService projectTaskService;

    public ProjectDto toDto(Project project) {
        UserSummaryDto ownerDto = new UserSummaryDto(
                project.getOwner().getId(),
                project.getOwner().getEmail(),
                project.getOwner().getFirstName(),
                project.getOwner().getLastName(),
                project.getOwner().getProfileUsername()
        );
        List<ProjectTaskDto> tasks = project.getTasks() == null ? List.of() :
                project.getTasks().stream().map(projectTaskService::toDto).toList();

        return new ProjectDto(
                project.getId(),
                ownerDto,
                project.getTitle(),
                project.getDescription(),
                project.getCreatedAt(),
                tasks
        );
    }

    @Transactional
    public ProjectDto createProject(User currentUser, ProjectRequest request) {
        Project project = Project.builder()
                .owner(currentUser)
                .title(request.title())
                .description(request.description())
                .build();
        return toDto(projectRepository.save(project));
    }

    @Transactional
    public ProjectDto updateProject(Long projectId, User currentUser, ProjectRequest request) {
        Project project = getProjectAndVerifyOwner(projectId, currentUser);
        project.updateDetails(request.title(), request.description());
        return toDto(projectRepository.save(project));
    }

    @Transactional
    public void deleteProject(Long projectId, User currentUser) {
        Project project = getProjectAndVerifyOwner(projectId, currentUser);
        projectRepository.delete(project);
    }

    @Transactional(readOnly = true)
    public ProjectDto getProject(Long projectId) {
        return toDto(findProjectOrThrow(projectId));
    }

    @Transactional(readOnly = true)
    public List<ProjectDto> getAllProjects() {
        return projectRepository.findAll().stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public List<ProjectDto> getProjectsByOwner(Long ownerId) {
        return projectRepository.findByOwnerId(ownerId).stream().map(this::toDto).toList();
    }

    private Project findProjectOrThrow(Long projectId) {
        return projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", projectId));
    }

    private Project getProjectAndVerifyOwner(Long projectId, User currentUser) {
        Project project = findProjectOrThrow(projectId);
        if (!project.isOwnedBy(currentUser)) {
            throw new UnauthorizedAccessException("You are not the owner of this project");
        }
        return project;
    }
}
