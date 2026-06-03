package com.elsys.server.service;

import com.elsys.server.dto.request.ProjectTaskRequest;
import com.elsys.server.dto.response.ProjectTaskDto;
import com.elsys.server.dto.response.SkillTagDto;
import com.elsys.server.entity.Project;
import com.elsys.server.entity.ProjectTask;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.entity.User;
import com.elsys.server.exception.ResourceNotFoundException;
import com.elsys.server.exception.UnauthorizedAccessException;
import com.elsys.server.repository.ProjectRepository;
import com.elsys.server.repository.ProjectTaskRepository;
import com.elsys.server.repository.SkillTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectTaskService {
    private final ProjectTaskRepository projectTaskRepository;
    private final ProjectRepository projectRepository;
    private final SkillTagRepository skillTagRepository;
    private final SkillTagService skillTagService;

    public ProjectTaskDto toDto(ProjectTask task) {
        List<SkillTagDto> skills = task.getRequiredSkills() == null ? List.of() :
                task.getRequiredSkills().stream()
                        .map(skillTagService::toDto)
                        .toList();
        return new ProjectTaskDto(task.getId(), task.getTitle(), task.getDescription(), skills);
    }

    @Transactional
    public ProjectTaskDto createTask(Long projectId, User currentUser, ProjectTaskRequest request) {
        Project project = getProjectAndVerifyOwner(projectId, currentUser);
        ProjectTask task = ProjectTask.builder()
                .project(project)
                .title(request.title())
                .description(request.description())
                .build();
        return toDto(projectTaskRepository.save(task));
    }

    @Transactional
    public ProjectTaskDto updateTask(Long taskId, User currentUser, ProjectTaskRequest request) {
        ProjectTask task = getTaskAndVerifyOwner(taskId, currentUser);
        task.updateDetails(request.title(), request.description());
        return toDto(projectTaskRepository.save(task));
    }

    @Transactional
    public void deleteTask(Long taskId, User currentUser) {
        ProjectTask task = getTaskAndVerifyOwner(taskId, currentUser);
        projectTaskRepository.delete(task);
    }

    @Transactional(readOnly = true)
    public ProjectTaskDto getTask(Long taskId) {
        return toDto(findTaskOrThrow(taskId));
    }

    @Transactional(readOnly = true)
    public List<ProjectTaskDto> getTasksByProject(Long projectId) {
        if (!projectRepository.existsById(projectId)) {
            throw new ResourceNotFoundException("Project", projectId);
        }
        return projectTaskRepository.findByProjectId(projectId).stream().map(this::toDto).toList();
    }

    @Transactional
    public ProjectTaskDto addSkillToTask(Long taskId, Long skillId, User currentUser) {
        ProjectTask task = getTaskAndVerifyOwner(taskId, currentUser);
        SkillTag skill = skillTagRepository.findById(skillId)
                .orElseThrow(() -> new ResourceNotFoundException("SkillTag", skillId));
        task.addSkill(skill);
        return toDto(projectTaskRepository.save(task));
    }

    @Transactional
    public ProjectTaskDto removeSkillFromTask(Long taskId, Long skillId, User currentUser) {
        ProjectTask task = getTaskAndVerifyOwner(taskId, currentUser);
        SkillTag skill = skillTagRepository.findById(skillId)
                .orElseThrow(() -> new ResourceNotFoundException("SkillTag", skillId));
        task.removeSkill(skill);
        return toDto(projectTaskRepository.save(task));
    }

    private ProjectTask findTaskOrThrow(Long taskId) {
        return projectTaskRepository.findById(taskId)
                .orElseThrow(() -> new ResourceNotFoundException("ProjectTask", taskId));
    }

    private ProjectTask getTaskAndVerifyOwner(Long taskId, User currentUser) {
        ProjectTask task = findTaskOrThrow(taskId);
        if (!task.getProject().isOwnedBy(currentUser)) {
            throw new UnauthorizedAccessException("You are not the owner of this project");
        }
        return task;
    }

    private Project getProjectAndVerifyOwner(Long projectId, User currentUser) {
        Project project = projectRepository.findById(projectId)
                .orElseThrow(() -> new ResourceNotFoundException("Project", projectId));
        if (!project.isOwnedBy(currentUser)) {
            throw new UnauthorizedAccessException("You are not the owner of this project");
        }
        return project;
    }
}
