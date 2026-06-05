package com.elsys.server.repository;

import com.elsys.server.entity.ProjectTask;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProjectTaskRepository extends JpaRepository<ProjectTask, Long> {
    List<ProjectTask> findByProjectId(Long projectId);
}
