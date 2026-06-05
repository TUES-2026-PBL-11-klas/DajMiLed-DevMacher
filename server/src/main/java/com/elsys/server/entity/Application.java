package com.elsys.server.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "applications")
@Getter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor(access = AccessLevel.PRIVATE)
public class Application {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "task_id", nullable = false)
    private ProjectTask task;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "applicant_id", nullable = false)
    private User applicant;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private ApplicationStatus status = ApplicationStatus.PENDING;

    public void updateStatus(ApplicationStatus status) {
        this.status = status;
    }

    public boolean isOwnedBy(User user) {
        return this.applicant.getId().equals(user.getId());
    }
}
