package com.antigravity.expensetracker.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "expenses")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Expense {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private BigDecimal amount;

    private String currency = "INR";

    private String category;
    private String merchant;

    @Column(nullable = false)
    private LocalDateTime date;

    private String source = "Manual"; // SMS, Mail, Manual
    private String type = "Purchase"; // Purchase, Transfer, Withdrawal, BillPayment
    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private User user;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
