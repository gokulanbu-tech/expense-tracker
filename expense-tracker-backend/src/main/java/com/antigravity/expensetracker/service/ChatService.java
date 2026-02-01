package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.dto.ChatResponse;
import com.antigravity.expensetracker.model.Bill;
import com.antigravity.expensetracker.model.DailyChatUsage;
import com.antigravity.expensetracker.model.Expense;
import com.antigravity.expensetracker.repository.BillRepository;
import com.antigravity.expensetracker.repository.DailyChatUsageRepository;
import com.antigravity.expensetracker.repository.ExpenseRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ChatService {

    private final DailyChatUsageRepository dailyChatUsageRepository;
    private final ExpenseRepository expenseRepository;
    private final BillRepository billRepository;
    private final GeminiService geminiService;

    private static final int DAILY_LIMIT = 10;

    public ChatService(DailyChatUsageRepository dailyChatUsageRepository,
            ExpenseRepository expenseRepository,
            BillRepository billRepository,
            GeminiService geminiService) {
        this.dailyChatUsageRepository = dailyChatUsageRepository;
        this.expenseRepository = expenseRepository;
        this.billRepository = billRepository;
        this.geminiService = geminiService;
    }

    @Transactional
    public ChatResponse processUserMessage(UUID userId, String userMessage, List<String> history) {
        LocalDate today = LocalDate.now();
        DailyChatUsage usage = dailyChatUsageRepository.findByUserIdAndDate(userId, today)
                .orElse(new DailyChatUsage(null, userId, today, 0));

        if (usage.getRequestCount() >= DAILY_LIMIT) {
            return new ChatResponse(
                    "You have reached your daily limit of " + DAILY_LIMIT
                            + " messages. Please try again tomorrow! (This is to manage AI costs)",
                    0);
        }

        // Build Context
        String context = buildFinancialContext(userId);

        // Build History Context
        StringBuilder historyContext = new StringBuilder();
        if (history != null && !history.isEmpty()) {
            historyContext.append("\nPREVIOUS CHAT HISTORY:\n");
            // Limit to last 4 messages to save context window
            int start = Math.max(0, history.size() - 4);
            for (int i = start; i < history.size(); i++) {
                historyContext.append(history.get(i)).append("\n");
            }
        }

        // System Prompt
        String systemPrompt = "You are a specialized financial assistant for the Expense Tracker app.\n" +
                "Today's Date: " + today + "\n" +
                "RULES:\n" +
                "1. Answer ONLY based on the provided data context below. If the answer isn't there, say you don't know.\n"
                +
                "2. If the user mentions a specific person name, assume it is a Merchant or Beneficiary in their transactions. Only refuse if they explicitly ask for another App User's private account data.\n"
                +
                "3. Be concise, friendly, and helpful.\n" +
                "4. Currencies is in INR (₹) unless specified otherwise.\n" +
                "\nDATA CONTEXT:\n" + context +
                historyContext.toString();

        // Call AI
        String aiResponse = geminiService.chatWithData(systemPrompt, userMessage);

        // Update Usage
        usage.setRequestCount(usage.getRequestCount() + 1);
        dailyChatUsageRepository.save(usage);

        return new ChatResponse(aiResponse, DAILY_LIMIT - usage.getRequestCount());
    }

    public int getRemainingQuota(UUID userId) {
        LocalDate today = LocalDate.now();
        DailyChatUsage usage = dailyChatUsageRepository.findByUserIdAndDate(userId, today)
                .orElse(new DailyChatUsage(null, userId, today, 0));
        return Math.max(0, DAILY_LIMIT - usage.getRequestCount());
    }

    private String buildFinancialContext(UUID userId) {
        // Fetch last 60 days expenses to capture full previous month
        LocalDateTime startRange = LocalDateTime.now().minusDays(60);
        List<Expense> expenses = expenseRepository.findByUserIdAndDateAfter(userId, startRange);

        // Fetch all bills (we filter for unpaid in memory for simplicity or usage of
        // stream)
        List<Bill> bills = billRepository.findByUserId(userId);
        List<Bill> unpaidBills = bills.stream().filter(b -> !b.getIsPaid()).collect(Collectors.toList());

        StringBuilder sb = new StringBuilder();
        sb.append("--- RECENT EXPENSES (Last 60 Days) ---\n");
        if (expenses.isEmpty()) {
            sb.append("No recent expenses found.\n");
        } else {
            // Limit to 100 recent items
            List<Expense> limitedExpenses = expenses.subList(0, Math.min(expenses.size(), 100));
            for (Expense e : limitedExpenses) {
                sb.append(String.format("- %s: %.2f on %s (Category: %s, Merchant: %s)\n",
                        e.getDate().toLocalDate(), e.getAmount(), e.getMerchant(), e.getCategory(), e.getMerchant()));
            }
        }

        sb.append("\n--- UNPAID BILLS ---\n");
        if (unpaidBills.isEmpty()) {
            sb.append("No unpaid bills.\n");
        } else {
            for (Bill b : unpaidBills) {
                sb.append(String.format("- %s: %.2f due on %s (Merchant: %s)\n",
                        b.getCategory(), b.getAmount(), b.getDueDate().toLocalDate(), b.getMerchant()));
            }
        }

        return sb.toString();
    }
}
