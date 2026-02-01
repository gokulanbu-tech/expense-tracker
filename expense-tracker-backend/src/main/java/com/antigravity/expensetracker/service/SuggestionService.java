package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.dto.Suggestion;
import com.antigravity.expensetracker.model.Expense;
import com.antigravity.expensetracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class SuggestionService {

    private final ExpenseRepository expenseRepository;
    private final GeminiService geminiService;

    @Autowired
    public SuggestionService(ExpenseRepository expenseRepository, GeminiService geminiService) {
        this.expenseRepository = expenseRepository;
        this.geminiService = geminiService;
    }

    @org.springframework.cache.annotation.Cacheable(value = "suggestions", key = "#userId")
    public List<Suggestion> getSuggestions(UUID userId) {
        // Fetch expenses from the last 30 days
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        List<Expense> recentExpenses = expenseRepository.findByUserIdAndDateAfter(userId, thirtyDaysAgo);

        if (recentExpenses.isEmpty()) {
            return java.util.Collections.emptyList();
        }

        // Generate insights via Gemini
        return geminiService.generateInsights(recentExpenses);
    }
}
