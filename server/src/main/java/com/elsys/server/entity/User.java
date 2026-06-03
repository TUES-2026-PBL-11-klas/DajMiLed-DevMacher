package com.elsys.server.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "users")
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class User implements UserDetails {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false)
    private String password;

    @Column(unique = true)
    private String username;

    private String discordTag;

    private String githubLink;

    @Column(columnDefinition = "TEXT")
    private String bio;

    private String education;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_tags", joinColumns = @JoinColumn(name = "user_id"))
    private Set<UserTag> tags;

    @ManyToMany
    @JoinTable(
        name = "user_skills",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "skill_tag_id")
    )
    private Set<SkillTag> skills;

    public String getProfileUsername() {
        return username;
    }

    public void updateProfile(String username, String discordTag, String githubLink, String bio, String education) {
        this.username = username;
        this.discordTag = discordTag;
        this.githubLink = githubLink;
        this.bio = bio;
        this.education = education;
    }

    public void updateSkills(Set<SkillTag> newSkills) {
        this.skills = new HashSet<>(newSkills);
    }

    public void updateTags(Set<UserTag> newTags) {
        this.tags = new HashSet<>(newTags);
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public String getUsername() {
        return email;
    }
}
