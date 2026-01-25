package com.antigravity.expensetracker.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.time.LocalDateTime;

@Entity
@Table(name = "sms_messages", uniqueConstraints = {
        @UniqueConstraint(columnNames = { "message_id" })
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SmsMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "message_id", nullable = false, unique = true)
    private String messageId; // Client-provided unique ID for idempotency

    @Column(nullable = false, length = 2000)
    private String content;

    @Column(name = "sender_number", nullable = false)
    private String senderNumber;

    @Column(name = "recipient_number", nullable = false)
    private String recipientNumber;

    @Column(name = "device_timestamp", nullable = false)
    private LocalDateTime deviceTimestamp;

    @Column(name = "attachment_info")
    private String attachmentInfo;

    @Column(name = "encryption_status")
    private String encryptionStatus;

    @Column(name = "delivery_status")
    private String deliveryStatus;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
