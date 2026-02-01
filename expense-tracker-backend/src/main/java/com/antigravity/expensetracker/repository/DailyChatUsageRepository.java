package com.antigravity.expensetracker.repository;

import com.antigravity.expensetracker.model.DailyChatUsage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

public interface DailyChatUsageRepository extends JpaRepository<DailyChatUsage, UUID> {
    Optional<DailyChatUsage> findByUserIdAndDate(UUID userId, LocalDate date);
}
