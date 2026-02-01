package com.antigravity.expensetracker.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "daily_chat_usage")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChatUsage {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private LocalDate date;

    @Column(nullable = false)
    private int requestCount = 0;
}
