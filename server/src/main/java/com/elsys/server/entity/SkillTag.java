package com.elsys.server.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.Objects;

@Entity
@Table(name = "skill_tags", indexes = @Index(name = "idx_skill_tag_name", columnList = "name"))
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class SkillTag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String name;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SkillTag skillTag = (SkillTag) o;
        return Objects.equals(id, skillTag.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
