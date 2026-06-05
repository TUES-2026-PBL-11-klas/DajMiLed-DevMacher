package com.elsys.server.repository;

import com.elsys.server.entity.ProjectTask;
import com.elsys.server.entity.SkillTag;
import com.elsys.server.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Set;

public interface ProjectTaskRepository extends JpaRepository<ProjectTask, Long> {
    List<ProjectTask> findByProjectId(Long projectId);

    @Query("SELECT DISTINCT t.id FROM ProjectTask t JOIN t.requiredSkills s " +
           "WHERE s IN :skills AND t.project.owner <> :user")
    List<Long> findRelevantTaskIds(
            @Param("skills") Set<SkillTag> skills,
            @Param("user") User user);

    @Query("SELECT DISTINCT t FROM ProjectTask t LEFT JOIN FETCH t.requiredSkills WHERE t.id IN :ids")
    List<ProjectTask> findByIdsWithSkills(@Param("ids") List<Long> ids);
}
