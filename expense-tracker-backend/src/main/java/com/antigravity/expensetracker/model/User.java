package com.antigravity.expensetracker.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.UUID;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(name = "first_name")
    private String firstName;

    @Column(name = "last_name")
    private String lastName;

    @Column(name = "mobile_number", unique = true, nullable = false)
    private String mobileNumber;

    @Column(nullable = false)
    private String password;

    @Column(name = "monthly_budget")
    private Double monthlyBudget = 50000.0;

    private String currency = "INR";

    @Column(name = "dark_mode")
    private Boolean darkMode = true;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
