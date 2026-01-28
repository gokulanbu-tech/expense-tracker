package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.model.Bill;
import com.antigravity.expensetracker.model.Expense;
import com.antigravity.expensetracker.repository.BillRepository;
import com.antigravity.expensetracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class BillService {

    @Autowired
    private BillRepository billRepository;

    @Autowired
    private ExpenseRepository expenseRepository;

    public List<Bill> getAllBills(UUID userId) {
        if (userId != null) {
            return billRepository.findByUserId(userId);
        }
        return billRepository.findAll();
    }

    public Bill createBill(Bill bill) {
        // Ensure defaults
        if (bill.getFrequency() == null)
            bill.setFrequency("MONTHLY");
        if (bill.getType() == null)
            bill.setType("Debit");

        // Auto-detect isPaid? No, strictly manual creation implies starting fresh
        // usually.
        return billRepository.save(bill);
    }

    @Transactional
    public Bill markAsPaid(UUID billId) {
        Bill bill = billRepository.findById(billId)
                .orElseThrow(() -> new RuntimeException("Bill not found"));

        LocalDateTime now = LocalDateTime.now();
        // Constraint: Allow paying only if today is after or equal to due date?
        // User request: "bills can ba able mark as after due date only"
        // Interpretation: Can pay if today >= dueDate.
        if (now.toLocalDate().isBefore(bill.getDueDate().toLocalDate())) {
            throw new RuntimeException(
                    "Bill cannot be marked as paid before the due date: " + bill.getDueDate().toLocalDate());
        }

        // 1. Create/Validate Expense
        createOrLinkExpense(bill);

        // 2. Mark Current Cycle as Paid
        bill.setLastPaidDate(now);

        // 3. Handle Recurrence (Advance Date)
        handleRecurrence(bill);

        return billRepository.save(bill);
    }

    // ... createOrLinkExpense ...
    private void createOrLinkExpense(Bill bill) {
        LocalDateTime start = bill.getDueDate().minusDays(5);
        LocalDateTime end = bill.getDueDate().plusDays(5);

        List<Expense> matches = expenseRepository.findByUserIdAndMerchantAndAmountAndDateBetween(
                bill.getUser().getId(),
                bill.getMerchant(),
                bill.getAmount(),
                start,
                end);

        if (!matches.isEmpty()) {
            Expense existing = matches.get(0);
            existing.setNotes(existing.getNotes() + " (Linked to Bill: " + bill.getCategory() + ")");
            expenseRepository.save(existing);
        } else {
            Expense expense = new Expense();
            expense.setUser(bill.getUser());
            expense.setAmount(bill.getAmount());
            expense.setCurrency("INR");
            expense.setMerchant(bill.getMerchant());
            expense.setCategory(bill.getCategory());
            expense.setType(bill.getType());
            expense.setNotes("Auto-generated from Bill: " + bill.getNote());
            expense.setDate(LocalDateTime.now());
            expense.setSource("Bill Auto-Pay");

            expenseRepository.save(expense);
        }
    }

    private void handleRecurrence(Bill bill) {
        // Assuming Monthly for now as per "subscription"
        // If frequency is flexible, handle it.
        if ("MONTHLY".equalsIgnoreCase(bill.getFrequency())) {
            bill.setDueDate(bill.getDueDate().plusMonths(1));
        } else if ("WEEKLY".equalsIgnoreCase(bill.getFrequency())) {
            bill.setDueDate(bill.getDueDate().plusWeeks(1));
        } else if ("YEARLY".equalsIgnoreCase(bill.getFrequency())) {
            bill.setDueDate(bill.getDueDate().plusYears(1));
        }

        // The bill represents the *next* payment now.
        // It is naturally unpaid.
        bill.setIsPaid(false);
    }

    public boolean processExpenseForBillPayment(Expense expense) {
        List<Bill> bills = billRepository.findByUserId(expense.getUser().getId());
        for (Bill bill : bills) {
            if (isMatch(bill, expense)) {
                handleRecurrence(bill);
                billRepository.save(bill);

                // Link expense
                if (expense.getNotes() == null)
                    expense.setNotes("");
                if (!expense.getNotes().contains("Linked to Bill")) {
                    expense.setNotes(expense.getNotes() + " (Linked to Bill: " + bill.getCategory() + ")");
                    expenseRepository.save(expense);
                }
                System.out.println("Bill paid via transaction match: " + bill.getMerchant());
                return true;
            }
        }
        return false;
    }

    private boolean isMatch(Bill bill, Expense expense) {
        // Merchant match (fuzzy)
        String bMerch = bill.getMerchant().toLowerCase();
        String eMerch = expense.getMerchant().toLowerCase();

        boolean merchantMatch = bMerch.equals(eMerch) || eMerch.contains(bMerch) || bMerch.contains(eMerch);
        if (!merchantMatch)
            return false;

        // Approx amount match (within 10 units)
        if (expense.getAmount().subtract(bill.getAmount()).abs().doubleValue() > 10.0) {
            return false;
        }

        // Date match (within 7 days of due date)
        LocalDateTime bDate = bill.getDueDate();
        LocalDateTime eDate = expense.getDate();

        // Check if closer to this due date than next month?
        // Just check +/- 7 buffer
        return eDate.isAfter(bDate.minusDays(7)) && eDate.isBefore(bDate.plusDays(7));
    }

    // Notification Scheduler: Runs every day at 9 AM
    @Scheduled(cron = "0 0 9 * * ?")
    public void sendBillNotifications() {
        LocalDateTime inTwoDays = LocalDateTime.now().plusDays(2);

        // Find bills due on this specific date (ignoring time)
        List<Bill> bills = billRepository.findAll(); // Optimization: Custom query

        for (Bill bill : bills) {
            if (bill.getDueDate().toLocalDate().isEqual(inTwoDays.toLocalDate())) {
                // Send Notification
                String message = "You have subscribed to " + bill.getMerchant() + " and " + bill.getAmount()
                        + " will be debited on "
                        + bill.getDueDate().format(java.time.format.DateTimeFormatter.ISO_DATE);
                System.out.println("PUSH NOTIFICATION: " + message);
                // Integration with Notification Service would go here
            }
        }
    }

    public void deleteBill(UUID id) {
        billRepository.deleteById(id);
    }

    public Bill updateBill(UUID id, Bill billDetails) {
        return billRepository.findById(id).map(bill -> {
            bill.setMerchant(billDetails.getMerchant());
            bill.setAmount(billDetails.getAmount());
            bill.setCategory(billDetails.getCategory());
            bill.setDueDate(billDetails.getDueDate());
            bill.setNote(billDetails.getNote());
            bill.setFrequency(billDetails.getFrequency());
            // We usually don't update User or ID
            return billRepository.save(bill);
        }).orElseThrow(() -> new RuntimeException("Bill not found"));
    }
}
