package com.antigravity.expensetracker.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.time.LocalDateTime;

@Entity
@Table(name = "email_logs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class EmailLog {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 1000)
    private String subject;

    @Column(nullable = false, unique = true)
    private String messageId;

    @Column(columnDefinition = "TEXT")
    private String body;

    private String sender;

    @Column(name = "received_at")
    private LocalDateTime receivedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
