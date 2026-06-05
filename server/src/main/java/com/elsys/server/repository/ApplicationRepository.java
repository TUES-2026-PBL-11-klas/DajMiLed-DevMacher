package com.elsys.server.repository;

import com.elsys.server.entity.Application;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ApplicationRepository extends JpaRepository<Application, Long> {
    List<Application> findByTaskId(Long taskId);
    List<Application> findByApplicantId(Long applicantId);
    boolean existsByTaskIdAndApplicantId(Long taskId, Long applicantId);
}
