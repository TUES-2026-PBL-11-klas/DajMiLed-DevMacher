package com.elsys.server.config;

import com.elsys.server.entity.SkillTag;
import com.elsys.server.repository.SkillTagRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {

    private static final List<String> DEFAULT_SKILLS = List.of(
            "Flutter", "Dart", "React", "Vue", "Angular", "TypeScript",
            "JavaScript", "Python", "Java", "Kotlin", "Swift", "Go",
            "Rust", "C++", "Spring Boot", "Django", "FastAPI", "Node.js",
            "PostgreSQL", "MySQL", "MongoDB", "Redis", "Docker", "Kubernetes",
            "AWS", "Firebase", "UI/UX", "Figma", "Git"
    );

    private final SkillTagRepository skillTagRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (skillTagRepository.count() > 0) return;

        List<SkillTag> seeds = DEFAULT_SKILLS.stream()
                .map(name -> SkillTag.builder().name(name).build())
                .toList();
        skillTagRepository.saveAll(seeds);
    }
}
