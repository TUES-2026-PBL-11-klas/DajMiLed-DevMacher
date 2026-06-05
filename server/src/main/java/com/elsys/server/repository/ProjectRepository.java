package com.elsys.server.repository;

import com.elsys.server.entity.Project;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProjectRepository extends JpaRepository<Project, Long> {

    @Query("SELECT p.id FROM Project p ORDER BY p.createdAt DESC")
    List<Long> findPagedIds(Pageable pageable);

    @Query("SELECT DISTINCT p FROM Project p JOIN FETCH p.owner LEFT JOIN FETCH p.tasks t LEFT JOIN FETCH t.requiredSkills WHERE p.id IN :ids")
    List<Project> findByIdsWithDetails(@Param("ids") List<Long> ids);

    @Query("SELECT DISTINCT p FROM Project p JOIN FETCH p.owner LEFT JOIN FETCH p.tasks t LEFT JOIN FETCH t.requiredSkills WHERE p.owner.id = :ownerId")
    List<Project> findByOwnerIdWithDetails(@Param("ownerId") Long ownerId);

    @Query("SELECT DISTINCT p FROM Project p JOIN FETCH p.owner LEFT JOIN FETCH p.tasks t LEFT JOIN FETCH t.requiredSkills WHERE p.id = :id")
    Optional<Project> findByIdWithDetails(@Param("id") Long id);
}
