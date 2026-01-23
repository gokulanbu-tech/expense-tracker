package com.antigravity.expensetracker.repository;

import com.antigravity.expensetracker.model.Bill;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;
import java.util.List;

public interface BillRepository extends JpaRepository<Bill, UUID> {
    List<Bill> findByUserId(UUID userId);
}
