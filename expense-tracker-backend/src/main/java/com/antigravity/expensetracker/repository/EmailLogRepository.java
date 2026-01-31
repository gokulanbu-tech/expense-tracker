package com.antigravity.expensetracker.repository;

import com.antigravity.expensetracker.model.EmailLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.List;

public interface EmailLogRepository extends JpaRepository<EmailLog, UUID> {
    List<EmailLog> findByUserId(UUID userId);

    boolean existsByMessageId(String messageId);

    boolean existsBySenderAndSubjectAndReceivedAt(String sender, String subject, java.time.LocalDateTime receivedAt);
}
