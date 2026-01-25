package com.antigravity.expensetracker.repository;

import com.antigravity.expensetracker.model.SmsMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.Optional;

public interface SmsMessageRepository extends JpaRepository<SmsMessage, UUID> {
    Optional<SmsMessage> findByMessageId(String messageId);

    java.util.List<SmsMessage> findBySenderNumber(String senderNumber);
}
