package com.antigravity.expensetracker.repository;

import com.antigravity.expensetracker.model.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, UUID> {
    List<Expense> findByUserId(UUID userId);

    List<Expense> findByUserIdAndMerchantAndAmountAndDateBetween(
            UUID userId,
            String merchant,
            java.math.BigDecimal amount,
            java.time.LocalDateTime startDate,
            java.time.LocalDateTime endDate);

    List<Expense> findTop5ByUserIdAndMerchantOrderByDateDesc(UUID userId, String merchant);

    List<Expense> findByUserIdAndDateAfter(UUID userId, java.time.LocalDateTime date);
}
