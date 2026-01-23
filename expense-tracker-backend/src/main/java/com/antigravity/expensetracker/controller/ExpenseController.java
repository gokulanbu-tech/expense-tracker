package com.antigravity.expensetracker.controller;

import com.antigravity.expensetracker.model.Expense;
import com.antigravity.expensetracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/expenses")
@CrossOrigin(origins = "http://localhost:5173", methods = { RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT,
        RequestMethod.DELETE, RequestMethod.OPTIONS })
public class ExpenseController {

    @Autowired
    private ExpenseRepository expenseRepository;

    @GetMapping
    public List<Expense> getAllExpenses(@RequestParam(required = false) UUID userId) {
        if (userId != null) {
            return expenseRepository.findByUserId(userId);
        }
        return expenseRepository.findAll();
    }

    @PostMapping
    public Expense createExpense(@RequestBody Expense expense) {
        return expenseRepository.save(expense);
    }

    @PutMapping("/{id}")
    public Expense updateExpense(@PathVariable UUID id, @RequestBody Expense expense) {
        return expenseRepository.findById(id).map(existingExpense -> {
            existingExpense.setAmount(expense.getAmount());
            existingExpense.setCategory(expense.getCategory());
            existingExpense.setMerchant(expense.getMerchant());
            existingExpense.setDate(expense.getDate());
            existingExpense.setNotes(expense.getNotes());
            existingExpense.setType(expense.getType());
            existingExpense.setSource(expense.getSource());
            return expenseRepository.save(existingExpense);
        }).orElseThrow(() -> new RuntimeException("Expense not found"));
    }

    @DeleteMapping("/{id}")
    public void deleteExpense(@PathVariable UUID id) {
        expenseRepository.deleteById(id);
    }
}
