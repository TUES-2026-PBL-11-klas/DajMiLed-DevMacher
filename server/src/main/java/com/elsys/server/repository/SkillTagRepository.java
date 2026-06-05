package com.elsys.server.repository;

import com.elsys.server.entity.SkillTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SkillTagRepository extends JpaRepository<SkillTag, Long> {
    Optional<SkillTag> findByName(String name);
    boolean existsByName(String name);
    List<SkillTag> findByNameContainingIgnoreCase(String query);
}
