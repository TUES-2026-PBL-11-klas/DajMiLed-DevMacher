package com.elsys.server.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "project_tasks")
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class ProjectTask {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "project_id", nullable = false)
    private Project project;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Builder.Default
    @ManyToMany
    @JoinTable(
        name = "task_skills",
        joinColumns = @JoinColumn(name = "task_id"),
        inverseJoinColumns = @JoinColumn(name = "skill_tag_id")
    )
    private Set<SkillTag> requiredSkills = new HashSet<>();

    public void updateDetails(String title, String description) {
        this.title = title;
        this.description = description;
    }

    public void addSkill(SkillTag skill) {
        this.requiredSkills.add(skill);
    }

    public void removeSkill(SkillTag skill) {
        this.requiredSkills.remove(skill);
    }
}
